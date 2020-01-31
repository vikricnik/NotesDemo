//
//  AppError.swift
//  BSCDemo
//
//  Created by dies irae on 30/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import Moya

public enum AppError: Error {
    case moyaError(Moya.MoyaError)
}
