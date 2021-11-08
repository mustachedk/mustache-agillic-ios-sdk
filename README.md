# Agillic SDK for iOS

The Agillic SDK enables you to utilize the Agillic platform from within your iOS App. 
The SDK currently includes the following functionality:

 * Device registation by known recipients
 * Register Push Notification Tokens to a known recipient
 * Track recipient behavior, which can be used in [Target Groups](https://support.agillic.com/hc/en-gb/articles/360007001991-All-You-Need-to-Know-About-Target-Groups)
 
Read more about the Agillic Platform on the [official Agillic website](https://agillic.com).
And in our [Developer portal](https://developers.agillic.com).

## Requirements

- Requires your iOS Application to run iOS 11 or greater

## Installation

See the subsections below for details about the different installation methods.
* [Swift Package Manager](README.md#swift-package-manager)
* [Standard pod install](README.md#standard-pod-install)

### Swift Package Manager

Add a package by selecting `File` → `Add Packages…` in Xcode’s menu bar.

Search for the Agillic iOS SDK using the repo's URL:
```console
https://github.com/agillic/agillic-ios-sdk.git
```

For further documentaion on setting up the AgillicSDK with Swift Package Manger see: 
[Swift Package Manager](docs/SwiftPackageManager.md)

### Standard pod install

The Agillic SDK is available through [CocoaPods](https://cocoapods.org). 
To install it, simply add the following line to your Podfile:

```ruby
pod 'AgillicSDK'
```

## Initializing the Agillic SDK

In order to use AgillicSDK you have to initialize and configure it first.

You can configure your Agillic instance in code:
* ``AGILLIC API KEY``
* ``AGILLIC API SECRET``
* ``AGILLIC SOLUTION ID``

See how to setup your Agillic Solution and obtain these values 
in the [Agillic Solution Setup Guide](docs/AgillicSolutionSetup.md)

### Initialize in app

Start by importing the AgillicSDK Module into your AppDelegate Swift file
```swift
import AgillicSDK
```

Initialize and configure the Agillic SDK upon launch
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    Agillic.shared.configure(apiKey: "AGILLIC API KEY", apiSecret: "AGILLIC API SECRET", solutionId: "AGILLIC SOLUTION ID")
    return true
}
    
```

AgillicMobileSDK instance is now ready for usage.

## Usage

### Register App Installation

* ``RECIPIENT ID`` - Has to match RECIPIENT.EMAIL in the Agillic Recipient Table

```swift
Agillic.shared.register(recipientId: "RECIPIENT ID")
```

### Register Push Token

Register for Remote Push Notifications in your App, like you used to and implement this in your AppDelegate.
_NOTE: This requires you to have already obtained the Recipient ID and stored across app sessoins - this is currently only supported for known recipients._

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    // Register with PushToken
    Agillic.shared.register(recipientId: "RECIPIENT ID", pushNotificationToken: pushToken)
}
```

### App View tracking

Track recipient behavior with App View Tracking 

```swift
let appViewEvent = AgillicAppViewEvent(screenName: "app/landingpage")
Agillic.shared.tracker.track(appViewEvent)
```

The ``screenName`` is the value that can be matched in the Condition Editor.
The suggested name convention to use some hierarchical ``app/sublevel-1/sublevel-2/...``


## Questions and Issues

Please provide any feedback via a [GitHub
Issue](https://github.com/agillic/agillic-ios-sdk/issues/new).

