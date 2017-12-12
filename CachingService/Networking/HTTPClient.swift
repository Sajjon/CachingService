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
import SwiftyBeaver

public protocol HTTPClientProtocol {
    var reachability: ReachabilityServiceConvertible { get }
    func makeRequest<Model>(request: Router) -> Observable<Model?> where Model: Codable
    func makeRequest(request: Router) -> Observable<()>
}


public final class HTTPClient {
    
    //MARK: Variables
    private lazy var sessionManager: Alamofire.SessionManager = {
        let sessionManager = Alamofire.SessionManager()
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

extension ServiceError.APIError {
    init?(error: Error?) {
        guard
            let genericError = error,
            case let nsError = genericError as NSError,
            case let urlErrorCode = URLError.Code(rawValue: nsError.code),
            urlErrorCode == .notConnectedToInternet
            else { return nil }
        self = .noNetwork
    }
}

extension Error {
    var apiError: ServiceError.APIError {
        return ServiceError.APIError(error: self) ?? .httpGeneric
    }
}

private extension Optional where Wrapped == Error {
    var apiError: ServiceError.APIError {
        switch self {
        case .some(let wrapped): return wrapped.apiError
        case .none: return .httpGeneric
        }
    }
}

extension HTTPClient: HTTPClientProtocol {}
public extension HTTPClient {
    func makeRequest<Model>(request: Router) -> Observable<Model?> where Model: Codable {
        return Single.create { single in
            let dataRequest = self.sessionManager.request(request)
            log.debug(dataRequest.debugDescription)
            dataRequest.validate().responseJSONDecodable() { (response: DataResponse<Model>) in
                switch response.result {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    let apiError: ServiceError.APIError = error.apiError
                    log.error("Request failed, error: `\(apiError)`")
                    single(.error(apiError))
                }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }
        .asObservable()
    }
    
    func makeRequest(request: Router) -> Observable<()> {
        return Single.create { single in
            let dataRequest = self.sessionManager.request(request)
            log.debug(dataRequest.debugDescription)
            dataRequest.validate().response { (response: DefaultDataResponse) in
                guard
                    response.error == nil,
                    response.data != nil
                    else {
                        let apiError: ServiceError.APIError = response.error.apiError
                        log.error("Request failed - error: \(apiError)")
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
}
