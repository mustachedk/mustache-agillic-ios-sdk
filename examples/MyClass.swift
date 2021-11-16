//
//  MyClass.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

class MyClass {
    
    func exmample() {
        
        // Agillic Configuration Variables
        let apiKey = "YOUR API KEY" // Agillic API Key
        let apiSecret = "YOUR API SECRET" // Agillic API Secret
        let solutionId = "YOUR SOLUTION ID" // Agillic Solution ID
        
        // Other variable, specific for your App
        let recipientId = "RECIPIENT EMAIL" // Has to match RECIPIENT.EMAIL in the Agillic Recipient Table
        var pushToken = "PUSH TOKEN" // Push Token of this Device

        // Initialize and configuration
        Agillic.shared.configure(apiKey: apiKey, apiSecret: apiSecret, solutionId: solutionId)
        
        // Configure Log Level
        Agillic.shared.logger.logLevel = .verbose
        
        // Register without PushToken
        Agillic.shared.register(recipientId: recipientId)
        
        // Register with PushToken
        Agillic.shared.register(recipientId: recipientId, pushNotificationToken: pushToken)

        // Example of AppView tracking
        let appView = AgillicAppViewEvent(screenName: "app/landingpage")
        Agillic.shared.tracker.track(appView)
        Agillic.shared.track(appView)

        Agillic.shared.tracker?.pauseTracking()
        Agillic.shared.tracker?.resumeTracking()
        
    }
    
}
