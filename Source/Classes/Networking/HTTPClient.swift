//
//  HTTPClient.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-09-04.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import CodableAlamofire
import SwiftyBeaver

public protocol HTTPClientProtocol {
    var reachability: ReachabilityServiceConvertible { get }
    
    func makeRequest<Model>(request: Router, jsonDecoder: JSONDecoder) -> Observable<Model?> where Model: Codable

    func makeFireForgetRequest(request: Router) -> Observable<()>
    func download<Downloadable>(request: Router) -> Observable<Downloadable> where Downloadable: DataConvertible
    func uploadImage<UploadResponse>(_ image: UIImage, router: Router, jsonDecoder: JSONDecoder) -> Observable<UploadResponse> where UploadResponse : Decodable
}

public final class HTTPClient {
    
    //MARK: Variables
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.adapter = oauthHandler
        sessionManager.retrier = oauthHandler
        return sessionManager
    }()
    
    private let oauthHandler: OAuth2Handler
    public let reachability: ReachabilityServiceConvertible
    
    public init(
        reachability: ReachabilityServiceConvertible,
        environments: EnvironmentsProtocol,
        httpHeaderStore: HTTPHeaderStoreProtocol = HTTPHeaderStore()
        ) {
        
        self.reachability = reachability
        
        oauthHandler = OAuth2Handler(
            environments: environments,
            httpHeaderStore: httpHeaderStore
        )
    }
    
    public init(
        reachability: ReachabilityServiceConvertible,
        baseUrlString: String,
        httpHeaderStore: HTTPHeaderStoreProtocol = HTTPHeaderStore()
        ) {
        
        self.reachability = reachability
        
        oauthHandler = OAuth2Handler(
            baseUrlString: baseUrlString,
            httpHeaderStore: httpHeaderStore
        )
    }
}

extension HTTPClient: HTTPClientProtocol {}
public extension HTTPClient {
    
    func makeRequest<Model>(request: Router, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> Observable<Model?> where Model: Codable {
        return makeRequest(request: request, jsonDecoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy))
    }
    
    func makeRequest<Model>(request: Router, jsonDecoder: JSONDecoder = JSONDecoder(dateDecodingStrategy: .iso8601)) -> Observable<Model?> where Model: Codable {
        return Single.create { single in
            let dataRequest = self.sessionManager.request(request)
            log.debug(dataRequest.debugDescription)
            let validated = dataRequest.validate()
            
            validated.responseString { guard case .success(let s) = $0.result else { return }; log.verbose("responseString: `\(s)`") }
            validated.responseJSON { guard case .success(let s) = $0.result else { return }; log.verbose("responseJSON: `\(s)`") }
            
            validated.responseDecodableObject(queue: nil, keyPath: request.keyPath, decoder: jsonDecoder) { (response: DataResponse<Model>) in
                switch response.result {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    let apiError: ServiceError.APIError = error.apiError
                    log.error("Request failed, error: `\(error)`")
                    single(.error(apiError))
                }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
            }
            .asObservable()
    }
    
    func makeFireForgetRequest(request: Router) -> Observable<()> {
        return Single.create { single in
            let dataRequest = self.sessionManager.request(request)
            log.debug(dataRequest.debugDescription)
            dataRequest.validate().response { (response: DefaultDataResponse) in
                guard
                    response.error == nil,
                    response.data != nil
                    else {
                        let apiError: ServiceError.APIError = response.error.apiError
                        log.error("Request failed - error: \(response.error!)")
                        single(.error(apiError))
                        return
                }
                single(.success(void))
            }
            return Disposables.create {
                dataRequest.cancel()
            }
            }
            .asObservable()
    }
    
    func download<Downloadable>(request: Router) -> Observable<Downloadable> where Downloadable: DataConvertible {
        return Single.create { single in
            let downloadRequest = self.sessionManager.request(request)
            log.debug(downloadRequest.debugDescription)
            downloadRequest.validate().responseData { response in
                guard
                    let data = response.result.value,
                    let downloadable = Downloadable(data: data)
                    else {
                        let apiError: ServiceError.APIError
                        if let genericError = response.error {
                            apiError = genericError.apiError
                            log.error("Failed to download, error: `\(genericError)`")
                        } else {
                            apiError = ServiceError.APIError.httpGeneric
                        }
                        single(.error(apiError))
                        return
                }
                single(.success(downloadable))
            }
            return Disposables.create {
                downloadRequest.cancel()
            }
            }
            .asObservable()
    }
    
    //swiftlint:disable:next function_body_length
    func uploadImage<UploadResponse>(_ image: UIImage, router: Router) -> Observable<UploadResponse> where UploadResponse : Decodable {
        return uploadImage(image, router: router, jsonDecoder: JSONDecoder(dateDecodingStrategy: .iso8601))
    }
    
    func uploadImage<UploadResponse>(_ image: UIImage, router: Router, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> Observable<UploadResponse> where UploadResponse : Decodable {
        return uploadImage(image, router: router, jsonDecoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy))
    }
    
    func uploadImage<UploadResponse>(_ image: UIImage, router: Router, jsonDecoder: JSONDecoder) -> Observable<UploadResponse> where UploadResponse : Decodable {
        return Single.create { single in
            guard
                let fileData = UIImagePNGRepresentation(image),
                let request = try? router.asURLRequest(),
                case let parameters = ["size": fileData.count],
                var encodedRequest = try? URLEncoding.queryString.encode(request, with: parameters)
                else {
                    single(.error(ServiceError.api(.encoding)))
                    return Disposables.create()
            }
            encodedRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            encodedRequest.setValue("\(fileData.count)", forHTTPHeaderField: "Content-Length")
            
            self.sessionManager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(fileData, withName: "file", fileName: "avatar.png", mimeType: "image/png")
            }, with: encodedRequest,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    request.responseDecodableObject(queue: nil, keyPath: router.keyPath, decoder: jsonDecoder) { (response: DataResponse<UploadResponse>) in
                        switch response.result {
                        case .success(let value):
                            single(.success(value))
                        case .failure(let error):
                            log.error("Request failed, error: `\(error)`")
                            single(.error(ServiceError.api(.encoding)))
                        }
                    }
                case .failure(let error):
                    log.error("Encoding failed with error: \(error)")
                    single(.error(ServiceError.api(.encoding)))
                }
            })
            return Disposables.create()
            }
            .asObservable()
    }
}
