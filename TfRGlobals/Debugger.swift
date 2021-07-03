//
//  Debugger.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 6/3/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import os

fileprivate let infoLog = OSLog(subsystem: "TfR", category: "info")

public func log(_ message: String) {
    os_log(.default, log: infoLog, "[TfR] %s", message)
}

public enum LogService {
    case defaults
    case keychain

    var format: StaticString {
        switch self {
            case .defaults: return "[TfR][⚙️] %s"
            case .keychain: return "[TfR][🔑] %s"
        }
    }
}

public func logService(_ message: String, service: LogService) {
    os_log(.default, log: infoLog, service.format, message)
}

public func mockLog(_ message: String, level: OSLogType = .default) {
    os_log(level, log: infoLog, "[TfR][🔸 - mocked] %s", message)
}

public func logSend(_ message: String) {
    os_log(.default, log: infoLog, "[TfR][🟩] %s", message)
}

public func error(_ message: String) {
    os_log(.error, log: infoLog, "[TfR][🟥] %s", message)
}

public func logReducer(_ message: String) {
    os_log(.default, log: infoLog, "[TfR][🟪] %s", message)
}

class Debugger: ObservableObject {

    private let log = OSLog(subsystem: "Extension", category: "test")

    public static let shared = Debugger()

    @Published var status: DebuggerStatus = .idle
    enum DebuggerStatus {
        case idle
        case sending
        case sent
    }

    private let path = "debug.log"

    private lazy var url = URL(fileURLWithPath: path)

    private init() {
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        }
        url = URL(fileURLWithPath: path)
    }

    func log(_ message: String) {
        os_log(.error, log: log, "[TfR] %s", message)
        guard let data = message.data(using: .utf8) else {
            return
        }
        try? data.write(to: url, options: .atomicWrite)
    }

    func upload() {
        guard let content = FileManager.default.contents(atPath: path),
              let str = String(data: content, encoding: .utf8) else {
            return
        }
        status = .sending
        let url = URL(string: "https://www.bermudalocket.com/submit-debug-logs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = DebuggerPayload(message: str).data
        URLSession.shared.dataTask(with: request) { _, _, _ in
            self.status = .sent
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(3))) {
                self.status = .idle
            }
        }.resume()
    }

    struct DebuggerPayload: Codable {

        let identifier: UUID
        let message: String

        init(message: String) {
            identifier = Redditweaks.identifier
            self.message = message
        }

        var data: Data? {
            try? JSONEncoder().encode(self)
        }

    }

}
