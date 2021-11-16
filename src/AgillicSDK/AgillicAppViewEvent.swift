//
//  AgillicAppViewEvent.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

public class AgillicAppViewEvent : AgillicEvent {
    var screenId: String
    var screenName: String
    var type: String?
    var previousScreenId: String?
    
    public init(screenName: String? = nil, type: String? = nil, previousScreenId: String? = nil) {
        self.screenId = SPUtilities.getUUIDString()!
        self.screenName = screenName != nil ? screenName! : screenId
        self.type = type
        self.previousScreenId = previousScreenId
    }
    
    func buildSnowplowPVEvent() -> SPPageView? {
        let event = SPPageView.build({ (builder : SPPageViewBuilder?) -> Void in
            
//            builder!.setName(self.screenName)
//            builder!.setScreenId(self.screenId)
//            builder!.setType(self.type)
//            builder!.setPreviousScreenId(self.previousScreenId)
            
        })
        
        return event;
    }
    
    func buildSnowplowEvent() -> SPScreenView? {
        let event = SPScreenView.build({ (builder : SPScreenViewBuilder?) -> Void in
            builder!.setName(self.screenName)
            builder!.setScreenId(self.screenId)
            builder!.setType(self.type)
            builder!.setPreviousScreenId(self.previousScreenId)
            
        })
        
        return event;
    }

    public override func track(_ tracker: SPTracker) {
         tracker.trackScreenViewEvent(buildSnowplowEvent())
    }

}
