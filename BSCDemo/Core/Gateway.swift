//
//  Gateway.swift
//  BSCDemo
//
//  Created by dies irae on 30/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import enum Result.Result

protocol NotesGatewayType {
    func request<D: Decodable>(target: NotesTarget,
                               callbackQueue: DispatchQueue?,
                               progress: Moya.ProgressBlock?,
                               completion: @escaping (Result<D, AppError>) -> Void) -> Cancellable
    func request<D: Decodable>(target: NotesTarget,
                               callbackQueue: DispatchQueue?,
                               progress: Moya.ProgressBlock?,
                               completion: @escaping (Result<[D], AppError>) -> Void) -> Cancellable
    func request(target: NotesTarget,
                 callbackQueue: DispatchQueue?,
                 progress: Moya.ProgressBlock?,
                 completion: @escaping (Result<Void, AppError>) -> Void) -> Cancellable
}

extension NetworkSession: NotesGatewayType {
    func request<D>(target: NotesTarget,
                    callbackQueue: DispatchQueue?,
                    progress: ProgressBlock?,
                    completion: @escaping (Result<D, AppError>) -> Void) -> Cancellable where D : Decodable {
        return request(target: target,
                       callbackQueue: callbackQueue,
                       progress: progress,
                       completion: {
                        completion($0.tryMap(to: D.self))
        })
    }

    func request<D>(target: NotesTarget,
                    callbackQueue: DispatchQueue?,
                    progress: ProgressBlock?,
                    completion: @escaping (Result<[D], AppError>) -> Void) -> Cancellable where D : Decodable {
        return request(target: target,
                       callbackQueue: callbackQueue,
                       progress: progress,
                       completion: {
                        completion($0.tryMap(to: [D].self))
        })

    }

    func request(target: NotesTarget,
                 callbackQueue: DispatchQueue?,
                 progress: ProgressBlock?,
                 completion: @escaping (Result<Void, AppError>) -> Void) -> Cancellable {
        return request(target: target,
                       callbackQueue: callbackQueue,
                       progress: progress,
                       completion: {
                        completion($0.tryMap())
        })

    }


}
