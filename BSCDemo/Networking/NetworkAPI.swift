//
//  NetworkAPI.swift
//  BSCDemo
//
//  Created by dies irae on 29/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import enum Result.Result

protocol NetworkSessionType {
    func request(target: NotesTarget,
                 callbackQueue: DispatchQueue?,
                 progress: Moya.ProgressBlock?,
                 completion: @escaping Completion) -> Cancellable
}

class NetworkSession: NetworkSessionType {

    private(set) var requests = [Cancellable]()

    let provider: MoyaProvider<NotesTarget>

    static var `default`: NetworkSession {
        NetworkSession(manager: Manager.default, plugins: [])
    }

    init(manager: Manager, plugins: [PluginType]) {
        provider = MoyaProvider(
            manager: manager,
            plugins: [NetworkLoggerPlugin()] + plugins
        )
    }

    deinit {
        requests.forEach {
            $0.cancel()
        }
        requests.removeAll()
    }

    func request(target: NotesTarget,
                 callbackQueue: DispatchQueue?,
                 progress: Moya.ProgressBlock?,
                 completion: @escaping Completion) -> Cancellable {
        let req = provider.request(target,
                                callbackQueue: callbackQueue,
                                progress: progress,
                                completion: { result in
                                    guard let response = try? result.get()
                                        else {
                                            completion(result)
                                            return
                                    }

                                    if (try? response.filterSuccessfulStatusAndRedirectCodes()) != nil {
                                        completion(result)
                                    } else {
                                        completion(.failure(.statusCode(response)))
                                    }
        })
        requests.append(req)
        return req
    }
}
