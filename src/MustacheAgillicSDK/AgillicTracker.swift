//
//  AgillicTracker.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

@objcMembers public class AgillicTracker : NSObject {
    var tracker: SPTracker
    var enabled = true

    @objc public init(_ tracker: SPTracker) {
        self.tracker = tracker
    }
    
    public func track(_ event : AgillicEvent) {
        if (enabled) {
            event.track(tracker)
        }
    }
    
    public func getSPTracker() -> SPTracker {
        return tracker
    }

    public func pauseTracking() {
        enabled = false
    }

    public func resumeTracking() {
        enabled = false
    }
    
    public func isTracking() -> Bool {
        return enabled
    }
}
