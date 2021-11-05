//
//  AgillicSDK.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

typealias AgillicSDKResponse = (Result<String, NSError>) -> Void

@objcMembers public class AgillicMobileSDK : NSObject, SPRequestCallback {
    
    private let urlFormat = "https://api%@-eu1.agillic.net";
    private var collectorEndpoint = "snowplowtrack-eu1.agillic.net";
    private var auth: Auth? = nil;
    private var methodType : SPRequestOptions = .post
    private var protocolType : SPProtocol = .https
    private(set) public var tracker: AgillicTracker
    private var clientAppId: String? = nil
    private var clientAppVersion: String? = nil
    private var solutionId : String? = nil
    private var pushNotificationToken: String?
    private var registrationEndpoint: String?
    private var recipientId: String?
    private var count = 0
    private var requestCallback : AgillicRequestCallback? = nil
    
    
    /**
     Configure the AgillicMobileSDK Instance with values from your Agillic solutions.

     - Parameter apiKey: Your personal Agillic API Key
     - Parameter apiSecret: Your personal Agillic API Key
     - Parameter solutionId: Your personal Agillic Solution ID
    
     All values can be obtained in your Agillic Solution, see Agillic documention how to obtain these values.
     */
    public func configure(apiKey: String, apiSecret: String, solutionId: String) {
        self.auth = BasicAuth(user: apiKey, password: apiSecret);
        self.clientAppId = Bundle.main.bundleIdentifier
        self.clientAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.solutionId = solutionId
    }
    
    private static var sharedAgillicMobileSDK: AgillicMobileSDK = {
        let sharedInstance = AgillicMobileSDK()
        return sharedInstance
    }()

    // MARK: - Accessors

    /**
    Returns a global instance of AgillicMobileSDK, it needs to be configured in other to be used.
     */
    class func shared() -> AgillicMobileSDK {
        return sharedAgillicMobileSDK
    }
    
    
    private func setAPI(_ api: String) {
        registrationEndpoint = String(format: urlFormat, api );
    }
    
    public override init() {
        super.init()
        setAPI("");
    }
    
    
    private func setDevAPI() {
        setAPI("dev");
    }

    private func setTestAPI() {
        setAPI("test");
    }
    
    private func setCollectorEndpoint(_ urlString: String) -> Bool{
        guard let url = URL(string: urlString) else {
            return false;
        }
        if (url.host == nil) {
            return false;
        }
        if (url.scheme == "https") {
            protocolType = .https
        } else if (url.scheme == "http") {
            protocolType = .http
        }
        else {
            return false;
        }
        collectorEndpoint =
            (url.host != nil ? url.host! : "") +
            (url.port != nil ? ":" + String(url.port!) : "") +
            url.path;
        return true;
    }

    /* Default is POST but can be overrided to GET */
    private func usePostProtocol(_ usePost: Bool) {
        methodType = usePost == true ? .post : .get
    }

    private func setRequestCallback(_ callback: AgillicRequestCallback) {
        requestCallback = callback;
    }

    private func getTracker(_ url: String, method: SPRequestOptions, recipientId: String, solutionId: String) -> SPTracker {
        let emitter = SPEmitter.build({ (builder : SPEmitterBuilder?) -> Void in
            builder!.setUrlEndpoint(url)
            builder!.setHttpMethod(method)
            builder!.setCallback(self)
            builder!.setProtocol(self.protocolType)
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
            completionHandler!(nil, NSError(domain: "configuration error", code: 1001, userInfo: ["message" : "configuration not set"]))
            return
        }

        let spTracker = getTracker(collectorEndpoint, method: methodType, recipientId: recipientId, solutionId: solutionId)
        self.tracker = AgillicTracker(spTracker);
        createMobileRegistration(completionHandler)
    }
    
    private func createMobileRegistration(_ completion: ((String?, Error?) -> Void)?) {
        let fullRegistrationUrl = String(format: "%@/register/%@", self.registrationEndpoint!, self.recipientId!)
        guard let endpointUrl = URL(string: fullRegistrationUrl) else {
            NSLog("Failed to create registration URL %@", fullRegistrationUrl);
            guard completion != nil else {
                return
            }
            completion!(nil, NSError(domain: "registration", code: -1, userInfo: ["message" : "Bad URL"]))
            return
        }
        
        guard let clientAppId = self.clientAppId, let clientAppVersion = self.clientAppVersion else {
            completion!(nil, NSError(domain: "configuration error", code: -1, userInfo: ["message" : "configuration not set"]))
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
               NSLog("Registration JSON: %@", JSONString)
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
                    NSLog("Failed to register: %@", error.localizedDescription)
                    self!.count += 1;
                    if self!.count < 3 {
                        sleep(5000)
                        self!.createMobileRegistration(completion)
                    } else {
                        // Failed after three attempts
                        if let completionHandler = completion {
                            completionHandler(nil, NSError(domain: "registration", code: 3001, userInfo: ["message" : "Failed after 3 attempt: " + error.localizedDescription ]));
                        }
                    }
                } else {
                    let response = response as? HTTPURLResponse
                    NSLog("Register: %d", response!.statusCode)
                    if let completionHandler = completion {
                        if response!.statusCode < 400 {
                            completionHandler("\(response!.statusCode)", nil);
                        }
                        else {
                            completionHandler(nil, NSError(domain: "registration", code: response!.statusCode, userInfo: ["message" : "Failed with error code" ]));
                        }
                    }
                }
            })
            task.resume()
            NSLog("Registration sendt")
        } catch{
            NSLog("Registration Exception")
        }
    }
    
    private func getXDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.first ?? "?")
    }

    private func getYDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.last ?? "?")
    }

    public func onSuccess(withCount successCount: Int) {
        requestCallback?.onSuccess(withCount: successCount)
    }

    public func onFailure(withCount failureCount: Int, successCount: Int) {
        requestCallback?.onFailure(withCount: failureCount, successCount: successCount)
    }
}

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
