//
//  AgillicSDK.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

typealias AgillicSDKResponse = (Result<String, NSError>) -> Void

public class Agillic : NSObject, SPRequestCallback {
    
    private let registrationEndpoint = "https://api-eu1.agillic.net";
    private var snowplowEndpoint = "snowplowtrack-eu1.agillic.net";
    private var auth: Auth? = nil;
    private(set) public var tracker: AgillicTracker? = nil
    private var clientAppId: String? = nil
    private var clientAppVersion: String? = nil
    private var solutionId : String? = nil
    private var pushNotificationToken: String?
    private var recipientId: String?
    private var count = 0
    private var requestCallback : AgillicRequestCallback? = nil
    public let logger = AgillicLogger()
    
    // MARK: - Initializer & Usage methods
    
    /**
    Returns a global instance of AgillicSDK, it needs to be configured in other to be used.
     */
    public static var shared: Agillic = Agillic()
    
    private override init() {
        super.init()
    }
    
    /**
     Configure the AgillicSDK Instance with values from your Agillic solutions.

     - Parameter apiKey: Your personal Agillic API Key
     - Parameter apiSecret: Your personal Agillic API Key
     - Parameter solutionId: Your personal Agillic Solution ID
    
     All values can be obtained in your Agillic Solution, see Agillic documention how to obtain these values.
     */
    public func configure(apiKey: String, apiSecret: String, solutionId: String) {
        self.auth = BasicAuth(user: apiKey, password: apiSecret);
        self.clientAppId = SPUtilities.getAppId()
        self.clientAppVersion = SPUtilities.getAppVersion()
        self.solutionId = solutionId
    }
    
    /**
     Register this app installation into the Agillic solutiion.
     Crate a new entry in the AGILLIC_REGISTRAION OTM Table in Recipient doesn't already have a Regration.
     
     - precondition: AgillicMobileSDK.shared().configure(:) must be called prior to this.
     - precondition: Recipient needs to exist in the Agillic Solution to in order successfully register installation

     - Parameter recipientId: This is mapped to the Recipient.Email in the Agillic Solution.
     - Parameter pushNotificationToken: No description
     - Parameter completionHandler: success/failure callback
    
     - Throws: Error code: 1001 - solutionID missing
    Error code: 1002 - recipientId missing
     \n Error code: 3001 - registration Failed after 3 attempts
     
     Anonymous Registaions are not yet supported.
     */
    public func register(recipientId: String,
                  pushNotificationToken: String? = nil,
                  completionHandler: ((String? , Error?) -> Void)? = nil)
    {
        self.recipientId = recipientId
        self.pushNotificationToken = pushNotificationToken
    
        guard let solutionId = self.solutionId else {
            let errorMsg = "Configuration not set"
            let error = NSError(domain: "configuration error", code: 1001, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completionHandler?(nil, error)
            return
        }

        let spTracker = getTracker(recipientId: recipientId, solutionId: solutionId)
        self.tracker = AgillicTracker(spTracker);
        createMobileRegistration(completionHandler)
    }
    
    
    // MARK: - Tracking
    
    public func track(_ event : AgillicEvent) {
        guard let tracker = self.tracker else {
            let errorMsg = "Configuration not set"
            self.logger.log(errorMsg, level: .error)
            return
        }
        tracker.track(event)
    }
    
    public func handlePushNotificationOpened() {
        // create event with
        let pushEvent = AgillicAppViewEvent(screenName: "push/open/xxxx")
        self.track(pushEvent)

    }

    // MARK: - Internal functionality

    private func getTracker(recipientId: String, solutionId: String) -> SPTracker {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setUrlEndpoint(self.snowplowEndpoint)
            builder!.setHttpMethod(SPRequestOptions.post)
            builder!.setCallback(self)
            builder!.setProtocol(SPProtocol.https)
            builder!.setEmitRange(500)
            builder!.setEmitThreadPoolSize(20)
            builder!.setByteLimitPost(52000)
        })
        let subject = SPSubject(platformContext: true, andGeoContext: true)
        subject!.setUserId(recipientId)
        let newTracker = SPTracker.build({ (builder : SPTrackerBuilder?) -> Void in
            builder!.setEmitter(emitter)
            builder!.setAppId(solutionId)
            builder!.setBase64Encoded(false)
            builder!.setSessionContext(true)
            builder!.setSubject(subject)
            builder!.setLifecycleEvents(true)
            builder!.setAutotrackScreenViews(true)
            builder!.setScreenContext(true)
            builder!.setApplicationContext(true)
            builder!.setExceptionEvents(true)
            builder!.setInstallEvent(true)
        })
        return newTracker!
    }
    
    private func createMobileRegistration(_ completion: ((String?, Error?) -> Void)?) {
        let fullRegistrationUrl = String(format: "%@/register/%@", self.registrationEndpoint, self.recipientId!)
        guard let endpointUrl = URL(string: fullRegistrationUrl) else {
            let errorMsg = "Failed to create registration \(fullRegistrationUrl)"
            let error = NSError(domain: "registration", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion?(nil, error)
            return
        }
        
        guard let clientAppId = self.clientAppId, let clientAppVersion = self.clientAppVersion else {
            let errorMsg = "configuration not set"
            let error = NSError(domain: "configuration error", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion!(nil, error)
            return
        }
        
        guard let tracker = self.tracker else {
            let errorMsg = "tracker not configrued"
            let error = NSError(domain: "tracker", code: -1, userInfo: ["message" : errorMsg])
            self.logger.log(errorMsg, level: .error)
            completion?(nil, error)
            return
        }

        // Make JSON to send to send to server
        let json : [String:String] = ["appInstallationId": tracker.getSPTracker().getSessionUserId(),
                                      "clientAppId": clientAppId,
                                      "clientAppVersion": clientAppVersion,
                                      "osName" : SPUtilities.getOSType(),
                                      "osVersion" : SPUtilities.getOSVersion(),
                                      "pushNotificationToken" : self.pushNotificationToken ?? "",
                                      "deviceModel": SPUtilities.getDeviceModel(),
                                      "modelDimX" :  getXDimension(SPUtilities.getResolution()),
                                      "modelDimY" :  getYDimension(SPUtilities.getResolution())]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            // Convert to a string and print
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
                self.logger.log("Registration JSON: \(JSONString)", level: .debug)
            }
    
            var request = URLRequest(url: endpointUrl)
            let authorization = auth!.getAuthInfo()
            request.httpMethod = "PUT"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(authorization, forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                if let error = error {
                    self?.logger.log("Failed to register: \(error.localizedDescription)", level: .error)
                    self?.count += 1;
                    if self!.count < 3 {
                        // Make 3 attempts
                        sleep(5000)
                        self?.createMobileRegistration(completion)
                    } else {
                        // Failed after three attempts
                        let errorMsg =  "Failed after 3 attempt: " + error.localizedDescription
                        let error = NSError(domain: "registration", code: 3001, userInfo: ["message" : errorMsg])
                        self?.logger.log(errorMsg, level: .error)
                        self?.count = 0
                        completion?(nil, error)
                    }
                } else {
                    let response = response as? HTTPURLResponse
                    if response!.statusCode < 400 {
                        let message = "Register success response code: \(response!.statusCode)"
                        self?.logger.log(message, level: .debug)
                        completion?(message, nil)
                    }
                    else {
                        let errorMsg = "Register failed with error code: \(response!.statusCode)"
                        let error = NSError(domain: "registration", code: -1, userInfo: ["message" : errorMsg])
                        self?.logger.log(errorMsg, level: .error)
                        completion?(nil, error)
                    }
                }
            })
            task.resume()
            self.logger.log("Registration sent", level: .debug)
        } catch{
            self.logger.log("Registration exception", level: .debug)
        }
    }
    
    // MARK: - Logging
    
    public func setLogLevel(_ logLevel: AgillicLogLevel) -> Void {
        self.logger.logLevel = logLevel
        switch logLevel {
        case .verbose:
            self.tracker?.tracker.setLogLevel(.verbose)
        case .debug:
            self.tracker?.tracker.setLogLevel(.debug)
        case .warning,
            .error:
            self.tracker?.tracker.setLogLevel(.error)
        case .off:
            self.tracker?.tracker.setLogLevel(.off)
        }
    }
    
    
    // MARK: - Util
    
    private func getXDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.first ?? "?")
    }

    private func getYDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.last ?? "?")
    }

    // MARK: - SPRequestCallback
    
    public func onSuccess(withCount successCount: Int) {
        requestCallback?.onSuccess(withCount: successCount)
    }

    public func onFailure(withCount failureCount: Int, successCount: Int) {
        requestCallback?.onFailure(withCount: failureCount, successCount: successCount)
    }
}

// MARK: - Auth
@objc private protocol Auth {
    @objc func getAuthInfo() -> String
}

private class BasicAuth : NSObject, Auth {
    var authInfo: String
    @objc public init(user : String, password: String) {
        let userPw = user + ":" + password;
        authInfo = "Basic " + userPw.data(using: .utf8)!.base64EncodedString();
    }
    
    public func getAuthInfo() -> String {
        return authInfo;
    }
}

// MARK: - Logger
    
public class AgillicLogger {
     
    public var logLevel: AgillicLogLevel = .off

    public func log(_ msg: String, level: AgillicLogLevel) {
        
        if self.logLevel <= level {
            NSLog(msg)
        }
    }
    
}

public enum AgillicLogLevel: Int, Comparable {
    case verbose
    case debug
    case warning
    case error
    case off

    // Implement Comparable
    public static func < (a: AgillicLogLevel, b: AgillicLogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}
