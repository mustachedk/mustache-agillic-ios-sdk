# Agillic SDK for iOS

The Agillic SDK enables you to utilize the Agillic platform from within your iOS App. 
The SDK currently includes the following functionality:

 * Device registation by known recipients
 * Register Push Notification Tokens to a known recipient
 * Track recipient behavior, which can be used in [Target Groups](https://support.agillic.com/hc/en-gb/articles/360007001991-All-You-Need-to-Know-About-Target-Groups)
 
Read more about the Agillic Platform on the [official Agillic website](https://agillic.com).

Or dive into the [Developer portal](https://developers.agillic.com).

## Installation

See the subsections below for details about the different installation methods.
1. [Swift Package Manager](docs/SwiftPackageManager.md)
1. [Standard pod install](README.md#standard-pod-install)
1. [Installing manually from the GitHub repo](README.md#manually-from-github)

### Standard pod install

The Agillic SDK is available through [CocoaPods](https://cocoapods.org). 
To install it, simply add the following line to your Podfile:

```ruby
pod 'MustacheAgillicSDK'
```

### Manually from github

Download/clone this https://github.com/Nets-mobile-acceptance/Netaxept-iOS-SDK.git
Unzip PiaSDKFramework.zip to obtain Pia.framework.
Drag and drop Pia.framework to your project.
Go to your project target at Build Phases.
Add Pia.framework to Link Binary With Libraries.
Add Pia.framework to Embedded Binaries from the General tab.
Xcode 11+ users can now replace Pia.framework in Xcode-Targets Frameworks, Libraries and Embedded Contents with Pia.XCFramework for iOS and iOS Simulator architectures.

## Using the Agillic SDK

Create an instance of the Agillic SDK. No configuration except authentication is required for normal use. Authentication must be done before registration (or with registerWithAuthentication):

```swift
let agillicSDK = MobileSDK()
agillicSDK.setAuth(BasicAuth(user: key, password: secret))
AgillicTracker tracker = agillicSDK.register(clientAppId: clientAppId, clientAppVersion: clientVersion, 
                                             solutionId: solutionId, userID: recipientId , 
                                             pushNotificationToken: token, completion: completionHandler)        
```
For each unique Application view setup a constant UUID and view/screen name and use the returned AgillicTracker to send App View tracking to the Agillic Platform on this App view usage:

```
let event = AppViewEvent(self.uuid.uuidString, screenName: screenView)
tracker?.track(event)
```
The screenView is the value that can be matched in the Condition Editor and the suggested name convention to use some hierarchical app/sublevel-1/sublevel-2/...
