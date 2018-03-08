//
//  ErrorMessage.swift
//  Shopify
//
//  Created by Jaime Landazuri on 10/10/2017.
//  Copyright © 2017 Kite.ly. All rights reserved.
//

struct CommonLocalizedStrings {
    static let somethingWentWrong = NSLocalizedString("GenericError/Something Went Wrong", value: "Something went wrong", comment: "Generic error message")
    static let alertOK = NSLocalizedString("Generic/OKButtonTitle", value: "OK", comment: "Acknowledgement to an alert dialog")
    static let retry = NSLocalizedString("Generic/RetryButtonTitle", value: "Retry", comment: "Button title to retry operation")
    static let cancel = NSLocalizedString("Generic/CancelButtonTitle", value: "Cancel", comment: "Cancel an action")
    static let checkConnectionAndRetry = NSLocalizedString("Generic/CheckConnectionAndRetry", value: "Please check your internet connectivity and try again.", comment: "Message instructing the user to check their Internet connection.")
    static func serviceAccessError(serviceName: String) -> String {
        return NSLocalizedString("Generic/AccessError", value: "There was an error when trying to access \(serviceName)", comment: "Generic error when trying to access a social service eg Instagram/Facebook")
    }
}


/// Simplifies error handling at VC level keeping messages independent from the API client.
struct ErrorMessage: Error {
    private(set) var title: String?
    private(set) var text: String!
    private(set) var type: MessageType!
    
    init(title: String? = nil, text: String) {
        self.title = title
        self.text = text
        self.type = .error
    }
    
    init?(_ error: Error?, _ title: String? = nil) {
        guard let error = error else { return nil }
        
        if let apiError = error as? APIClientError {
            self.init(apiError, title)
        } else {
            self.init(title: title, text: (error as NSError).localizedDescription)
        }
    }
    
    init?(_ error: APIClientError?, _ title: String? = nil) {
        guard let error = error else { return nil }
        
        self.title = title
        switch error {
        case .connection:
            self.title = NSLocalizedString("ConnectionErrorTitle", value: "You Appear to be Offline", comment: "Connection error title")
            text = NSLocalizedString("ConnectionErrorMessage", value: "Please check your internet connectivity and try again.", comment: "Connection error Message")
            type = .info
        case .server(let code, let message) where code == 500 && message == "":
            self.title = NSLocalizedString("ServerMaintenanceErrorTitle", value: "Server Maintenance", comment: "Server maintenance error title")
            text = NSLocalizedString("ServerMaintenanceErrorMessage", value: "We'll be back and running as soon as possible!", comment: "Server maintenance error message")
            type = .error
        case .server(_, let message) where message != "":
            text = message
            type = .error
        default:
            text = CommonLocalizedStrings.somethingWentWrong
            type = .error
        }
    }
}

