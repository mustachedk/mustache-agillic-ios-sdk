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
    private var tracker: SPTracker?
    private var clientAppId: String = "N/A"
    private var clientAppVersion: String = "N/A"
    private var solutionId : String? = nil
    private var pushNotificationToken: String?
    private var registrationEndpoint: String?
    private var userId: String?
    private var count = 0
    private var requestCallback : AgillicRequestCallback? = nil
    public func setAuth(_ auth: Auth) {
        self.auth = auth;
    }
    
    public func setAPI(_ api: String) {
        registrationEndpoint = String(format: urlFormat, api );
    }

    
    public override init() {
        super.init()
        setAPI("");
    }
    
    
    public func setDevAPI() {
        setAPI("dev");
    }

    public func setTestAPI() {
        setAPI("test");
    }
    
    public func setCollectorEndpoint(_ urlString: String) -> Bool{
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
    public func usePostProtocol(_ usePost: Bool) {
        methodType = usePost == true ? .post : .get
    }

    public func setRequestCallback(_ callback: AgillicRequestCallback) {
        requestCallback = callback;
    }

    public func getTracker(_ url: String, method: SPRequestOptions, userId: String, appId: String) -> SPTracker {
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
        subject!.setUserId(userId)
        let newTracker = SPTracker.build({ (builder : SPTrackerBuilder?) -> Void in
            builder!.setEmitter(emitter)
            builder!.setAppId(appId)
            //builder!.setTrackerNamespace(self.kNamespace)
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

    public func register(apiKey: String, apiSecret: String,
                         clientAppId: String, clientAppVersion: String,
                         solutionId: String, userID: String,
                         pushNotificationToken: String?,
                         completionHandler: ((String? , Error?) -> Void)?) -> AgillicTracker
    {
        setAuth(BasicAuth(user: apiKey, password: apiSecret));
        return register(clientAppId: clientAppId, clientAppVersion: clientAppVersion, solutionId: solutionId, userID: userID, pushNotificationToken: pushNotificationToken, completionHandler: completionHandler)
    }


    public func register(clientAppId: String, clientAppVersion: String,
                  solutionId: String, userID: String,
                  pushNotificationToken: String?,
                  completionHandler: ((String? , Error?) -> Void)?) -> AgillicTracker
    {
        self.clientAppId = clientAppId
        self.clientAppVersion = clientAppVersion
        self.solutionId = solutionId
        self.userId = userID
        self.pushNotificationToken = pushNotificationToken

        tracker = getTracker(collectorEndpoint, method: methodType, userId: userID, appId: solutionId)
        let agiTracker = AgillicTracker(tracker!);
        createMobileRegistration(completionHandler)
        return agiTracker;
        
    }
    
    func createMobileRegistration(_ completion: ((String?, Error?) -> Void)?) {
        let fullRegistrationUrl = String(format: "%@/register/%@", self.registrationEndpoint!, self.userId!)
        guard let endpointUrl = URL(string: fullRegistrationUrl) else {
            NSLog("Failed to create registration URL %@", fullRegistrationUrl);
            guard completion != nil else {
                return
            }
            completion!(nil, NSError(domain: "registration", code: -1, userInfo: ["message" : "Bad URL"]))
            return
        }
        
        // Make JSON to send to send to server
        let json : [String:String] = ["appInstallationId": tracker!.getSessionUserId(),
                                      "clientAppId": self.clientAppId,
                                      "clientAppVersion": self.clientAppVersion,
                                      "osName" : SPUtilities.getOSType(),
                                      "osVersion" : SPUtilities.getOSVersion(),
                                      "pushNotificationToken" :
                                        self.pushNotificationToken != nil ? self.pushNotificationToken! : "",
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
                            completionHandler(nil, NSError(domain: "registration", code: -1, userInfo: ["message" : "Failed after 3 attempt: " + error.localizedDescription ]));
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
    
    public func getXDimension(_ resolution: String) -> String {
        let slices = resolution.split(separator:"x")
        return String(slices.first ?? "?")
    }

    public func getYDimension(_ resolution: String) -> String {
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

@objc public protocol Auth {
    @objc func getAuthInfo() -> String
}

public class BasicAuth : NSObject, Auth {
    var authInfo: String
    @objc public init(user : String, password: String) {
        let userPw = user + ":" + password;
        authInfo = "Basic " + userPw.data(using: .utf8)!.base64EncodedString();
    }
    
    public func getAuthInfo() -> String {
        return authInfo;
    }
}
