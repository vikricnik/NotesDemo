//
//  Result+Extensions.swift
//  BSCDemo
//
//  Created by dies irae on 30/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import Moya
import enum Result.Result

public extension Moya.Response {

    func mapDecodable<T: Decodable>(ofType type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func mapDecodable<T: Decodable>(ofType type: Set<T>.Type) throws -> Set<T> {
        let decoder = JSONDecoder()
        return try decoder.decode([String: Set<T>].self, from: data).first?.value ?? []
    }

    func mapDecodable<T: Decodable>(ofType type: [T].Type) throws -> [T] {
        let decoder = JSONDecoder()
        return try decoder.decode([String: [T]].self, from: data).first?.value ?? []
    }

    func mapDecodable<T: Decodable>() throws -> T {
        return try mapDecodable(ofType: T.self)
    }

}

public extension Result where Value: Response, Error == MoyaError {

    func tryMap<D: Decodable>(to decodable: D.Type) -> Result<D, AppError> {

        switch self {
        case .success(let data):
            do {
                let process = try data.map(D.self)
                return Result<D, AppError>(value: process)
            } catch let error {
                return Result<D, AppError>(error: AppError.moyaError(MoyaError.objectMapping(error, data)))
            }
        case .failure(let error):
            return Result<D, AppError>(error: AppError.moyaError(error))
        }

    }

    func tryMap<D: Decodable>(to decodable: [D].Type) -> Result<[D], AppError> {
        switch self {
        case .success(let data):
            do {
                let process = try data.map([D].self)
                return Result<[D], AppError>(value: process)
            } catch let error {
                return Result<[D], AppError>(error: AppError.moyaError(MoyaError.objectMapping(error, data)))
            }
        case .failure(let error):
            return Result<[D], AppError>(error: AppError.moyaError(error))
        }
    }

    func tryMap() -> Result<Void, AppError> {
        switch self {
        case .success:
            return .success(())
        case .failure(let error):
            return Result<Void, AppError>(error: AppError.moyaError(error))
        }
    }

}
