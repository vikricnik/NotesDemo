//
//  BSCDemoTests.swift
//  BSCDemoTests
//
//  Created by dies irae on 29/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import XCTest
@testable import BSCDemo
import enum Result.Result

class BSCDemoTests: XCTestCase {

    let gw: NotesGatewayType = NetworkSessionStub.default

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let getlist = XCTestExpectation(description: "getlist")
        let create = XCTestExpectation(description: "create")
        let detail = XCTestExpectation(description: "detail")
        let update = XCTestExpectation(description: "update")
        let delete = XCTestExpectation(description: "delete")

        let note = Note(id: -1, title: "")

        _ = gw.request(target: .getList,
                       callbackQueue: .main,
                       progress: nil,
                       completion: { (result: Result<[Note], AppError>) in
            getlist.fulfill()
        })

        _ = gw.request(target: .create(note),
                       callbackQueue: .main,
                       progress: nil,
                       completion: { (result: Result<Note, AppError>) in
            create.fulfill()
        })

        _ = gw.request(target: .detail(note),
                       callbackQueue: .main,
                       progress: nil,
                       completion: { (result: Result<Note, AppError>) in
            detail.fulfill()
        })

        _ = gw.request(target: .update(note),
                       callbackQueue: .main,
                       progress: nil,
                       completion: { (result: Result<Note, AppError>) in
            update.fulfill()
        })

        _ = gw.request(target: .delete(note),
                       callbackQueue: .main,
                       progress: nil,
                       completion: { (result: Result<(), AppError>) in
            delete.fulfill()
        })

        wait(for: [getlist, create, detail, update, delete], timeout: 5.0)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
