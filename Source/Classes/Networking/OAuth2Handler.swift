//
//  OAuth2Handler.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-10-16.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation
//import Basics
//import Extensions
import Alamofire

private typealias RefreshCompletion = (_ succeeded: Bool, _ tokens: AuthTokensConvertible?) -> Void

final class OAuth2Handler: RequestAdapter, RequestRetrier {
    
    private lazy var refreshTokenSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        let sessionManager = SessionManager(configuration: configuration)
        sessionManager.adapter = self
        return sessionManager
    }()
    
    let httpHeaderStore: HTTPHeaderStoreProtocol
    private let baseUrlString: String
    
    private let lock = NSLock()

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    public init(
        baseUrlString: String,
        httpHeaderStore: HTTPHeaderStoreProtocol
        ) {
        self.baseUrlString = baseUrlString
        self.httpHeaderStore = httpHeaderStore
    }
    
    public convenience init(
        environments: EnvironmentsProtocol,
        httpHeaderStore: HTTPHeaderStoreProtocol
        ) {
        self.init(baseUrlString: environments.value(for: .baseUrl), httpHeaderStore: httpHeaderStore)
    }
    
    // MARK: - RequestAdapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if urlRequest.url?.host == nil {
            urlRequest.prependUrl(prefix: baseUrlString)
        }
        httpHeaderStore.injectHeaders(to: &urlRequest)
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        log.debug("RequestRetrier not implemented")
        completion(false, 0)
//        lock.lock() ; defer { lock.unlock() }
//        log.warning("Retrying request that failed with error: \(error)")
//        log.debug(request.debugDescription)
//        guard
//            let response = request.task?.response as? HTTPURLResponse,
//            response.statusCode == 401
//            else { completion(false, 0.0); return }
//        requestsToRetry.append(completion)
//        guard !isRefreshing else { log.verbose("Already refreshing"); return }
//        refreshTokens { [weak self] succeeded, tokens in
//            guard let `self` = self else { return }
//            self.lock.lock() ; defer { self.lock.unlock() }
//            guard let tokens = tokens else { fatalError("refresh failed, what to do?") }
//            do {
//                try self.safeKeyValueStore.save(value: tokens.accessToken, for: .token(.authentication))
//                try self.safeKeyValueStore.save(value: tokens.refreshToken, for: .token(.refresh))
//            } catch { fatalError("Failed to save tokens to keychain, error: \(error)") }
//            self.requestsToRetry.forEach { $0(succeeded, 0.0) }
//            self.requestsToRetry.removeAll()
//        }
    }
}

// MARK: - Private Methods
//private extension OAuth2Handler {
//
//    func refreshTokens(done: @escaping RefreshCompletion) {
//        guard !isRefreshing else { return }
//
//        isRefreshing = true
//        let refreshRequest = RefreshTokenRequest(userId: userID, refreshToken: refreshToken)
//        let router = LoginRouter.refresh(refreshRequest, inTeam: teamID)
//        refreshTokenSessionManager
//            .request(router)
//            .validate()
//            .responseDecodableObject { (response: DataResponse<AuthTokensConvertible>) in
//                switch response.result {
//                case .success(let authTokenConvertible):
//                    log.debug("Successfully refreshed token")
//                    done(true, authTokenConvertible)
//                case .failure:
//                    log.error("Failed to refresh token")
//                    done(false, nil)
//                }
//        }
//    }
//}

