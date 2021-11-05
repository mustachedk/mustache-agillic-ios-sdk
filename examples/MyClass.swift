//
//  MyClass.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

class MyClass {
    
    func exmample() {
        
        // Agillic Configuration Variables
        let key = "YOUR API KEY" // Agillic API Key
        let secret = "YOUR API SECRET" // Agillic API Secret
        let solutionId = "YOUR SOLUTION ID" // Agillic Solution ID
        let clientAppId = "APP BUNDLE ID" // App Bundle ID
        let clientVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

        // Other variable, specific for your App
        let recipientId = "fl@mustache.dk" // User Identifier (email, memberID or the ID created for the Reciept)
        var pushToken = "" // Push Token

        
        AgillicMobileSDK.shared().configure(apiKey: "YOUR API KEY", apiSecret: "YOUR API SECRET")
        
        AgillicMobileSDK.shared().configure(apiKey: <#T##String#>, apiSecret: <#T##String#>, clientAppId: <#T##String#>, clientAppVersion: <#T##String#>, solutionId: <#T##String#>)
        
        AgillicMobileSDK.shared().register(
            clientAppId: "CLIENT APP ID", clientAppVersion: "CLIENT APP VERSION", solutionId: "SOLUTION ID", userID: "RECIPIENT ID", pushNotificationToken: "PUSH TOKEN IF ANY", completionHandler: nil)
        
        let appView = AgillicAppViewEvent(screenName: "app/landingpage")
        AgillicMobileSDK.shared().tracker.track(appView)
        
    }
    
}
