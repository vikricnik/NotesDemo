//
//  NetworkSessionStub.swift
//  BSCDemoTests
//
//  Created by dies irae on 31/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
@testable import BSCDemo
import Moya
import Alamofire

class NetworkSessionStub: NetworkSession {

    let stubbingProvider: MoyaProvider<NotesTarget>
    override init(manager: Manager, plugins: [PluginType]) {
        self.stubbingProvider = MoyaProvider<NotesTarget>(stubClosure: MoyaProvider.immediatelyStub)
        super.init(manager: manager, plugins: plugins)
    }

    override func request(target: NotesTarget, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable {
        let req = stubbingProvider.request(target,
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
        return req
    }
}
