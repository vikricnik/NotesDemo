//
//  Targets.swift
//  BSCDemo
//
//  Created by dies irae on 30/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import Moya

protocol NoteType: Identifiable {
    var title: String { get }
}

struct Note: NoteType {
    let id: Int
    let title: String

    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}

extension Note: Encodable {

    enum CodingKeys: String, CodingKey {
        case
        id,
        title
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
    }
}

extension Note: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
    }
}

enum NotesTarget {
    case
    getList,
    create(Note),
    detail(Note),
    update(Note),
    delete(Note)
}

extension NotesTarget: TargetType {
    var baseURL: URL { URL(string: "https://private-9aad-note10.apiary-mock.com/")! }

    var path: String {
        switch self {
        case .getList:
            return "notes"
        case .create:
            return "notes"
        case .detail(let note):
            return "notes/\(note.id)"
        case .update(let note):
            return "notes/\(note.id)"
        case .delete(let note):
            return "notes/\(note.id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getList:
            return .get
        case .create:
            return .post
        case .detail:
            return .get
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .getList:
            return .requestPlain
        case .create(let encodable):
            return .requestJSONEncodable(encodable)
        case .detail:
            return .requestPlain
        case .update(let encodable):
            return .requestJSONEncodable(encodable)
        case .delete:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        switch self {
        case .getList,
             .delete:
            return nil
        case .create,
             .detail,
             .update:
            return ["Content-Type": "application/json"]
        }
    }


}
