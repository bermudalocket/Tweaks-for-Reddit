//
//  Debugger.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/3/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import os

fileprivate let infoLog = OSLog(subsystem: "TfR", category: "info")

public func log(_ message: String) {
    os_log(.default, log: infoLog, "[TfR] %{public}s", message)
}

public enum LogService {
    case background
    case defaults
    case keychain
    case appStore

    var format: StaticString {
        switch self {
            case .appStore: return "[TfR][] %{public}s"
            case .background: return "[TfR][👀] %{public}s"
            case .defaults: return "[TfR][⚙️] %{public}s"
            case .keychain: return "[TfR][🔑] %{public}s"
        }
    }
}

public func logService(_ message: String, service: LogService) {
    os_log(.default, log: infoLog, service.format, message)
}

public func mockLog(_ message: String, level: OSLogType = .default) {
    os_log(level, log: infoLog, "[TfR][🔸 - mocked] %{public}s", message)
}

public func logSend(_ message: String) {
    os_log(.default, log: infoLog, "[TfR][🟩] %{public}s", message)
}

public func error(_ message: String) {
    os_log(.error, log: infoLog, "[TfR][🟥] %{public}s", message)
}

public func logReducer(_ message: String) {
    os_log(.default, log: infoLog, "[TfR][🟪] %{public}s", message)
}
