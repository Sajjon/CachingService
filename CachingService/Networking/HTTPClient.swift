//
//  HTTPClient.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-09-04.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation
//import Basics
import RxSwift
import Alamofire
//import Disk
import SwiftyBeaver

public protocol HTTPClientProtocol {
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
    
    public init(
        environments: EnvironmentsProtocol,
        httpHeaderStore: HTTPHeaderStoreProtocol = HTTPHeaderStore()
    ) {
        oauthHandler = OAuth2Handler(
            environments: environments,
            httpHeaderStore: httpHeaderStore
        )
    }
    
    public init(
        baseUrlString: String,
        httpHeaderStore: HTTPHeaderStoreProtocol = HTTPHeaderStore()
        ) {
        oauthHandler = OAuth2Handler(
            baseUrlString: baseUrlString,
            httpHeaderStore: httpHeaderStore
        )
    }
}

extension HTTPClient: HTTPClientProtocol {}
public extension HTTPClient {
    func makeRequest<Model>(request: Router) -> Observable<Model?> where Model: Codable {
        return Single.create { single in
            let dataRequest = self.sessionManager.request(request)
            log.debug(dataRequest.debugDescription)
            dataRequest.validate().responseDecodableObject(queue: nil, keyPath: request.keyPath, decoder: JSONDecoder()) { (response: DataResponse<Model>) in
                switch response.result {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    log.error("Request failed, error: `\(error)`")
                    single(.error(error))
                }
            }
            return Disposables.create()
        }
        .asObservable()
    }
    
    func makeRequest(request: Router) -> Observable<()> {
        return Single.create { single in
            let request = self.sessionManager.request(request)
            log.debug(request.debugDescription)
            request.validate().response {
                (response: DefaultDataResponse) in
                guard
                    response.error == nil,
                    response.data != nil
                    else {
                        let error = response.error ?? ServiceError.api(.httpGeneric)
                        log.error("Request failed - error: \(error)")
                        single(.error(error))
                        return
                }
                single(.success(()))
            }
            return Disposables.create()
        }
        .asObservable()
    }
}
