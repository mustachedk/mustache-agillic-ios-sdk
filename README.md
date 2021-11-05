# Agillic SDK for iOS

The Agillic SDK enables you to utilize the Agillic platform from within your iOS App. 
The SDK currently includes the following functionality:

 * Device registation by known recipients
 * Register Push Notification Tokens to a known recipient
 * Track recipient behavior, which can be used in [Target Groups](https://support.agillic.com/hc/en-gb/articles/360007001991-All-You-Need-to-Know-About-Target-Groups)
 
Read more about the Agillic Platform on the [official Agillic website](https://agillic.com).
And in our [Developer portal](https://developers.agillic.com).

## Installation

See the subsections below for details about the different installation methods.
1. [Swift Package Manager](README.md#swift-package-manager)
1. [Standard pod install](README.md#standard-pod-install)

### Swift Package Manager

Add a package by selecting `File` → `Add Packages…` in Xcode’s menu bar.

---

Search for the Agillic iOS SDK using the repo's URL:
```console
https://github.com/mustachedk/mustache-agillic-ios-sdk.git
```

For further documentaion on setting up Swift Package Manger see: 
1. [Swift Package Manager](docs/SwiftPackageManager.md)

### Standard pod install

The Agillic SDK is available through [CocoaPods](https://cocoapods.org). 
To install it, simply add the following line to your Podfile:

```ruby
pod 'MustacheAgillicSDK'
```

## Initializing the Agillic SDK

In order to use AgillicSDK you have to initialize and configure it first.

You can configure your Agillic instance in code:
``AGILLIC API KEY``
``AGILLIC API SECRET``
``AGILLIC SOLUTION ID``



Initialize and configure
```swift
        AgillicMobileSDK.shared().configure(apiKey: apiKey, apiSecret: apiSecret, solutionId: solutionId)
```

AgillicMovileSDK instance is now ready for usage.



        
 



## Usage


        // Other variable, specific for your App
        let recipientId = "RECIPIENT EMAIL" // Has to match RECIPIENT.EMAIL in the Agillic Recipient Table
        var pushToken = "000000-0000-0000-0000000" // Push Token of this Device


For each unique Application view setup a constant UUID and view/screen name and use the returned AgillicTracker to send App View tracking to the Agillic Platform on this App view usage:

```
let event = AppViewEventscreenName: "app/landingpage")
tracker?.track(event)
```
The screenView is the value that can be matched in the Condition Editor and the suggested name convention to use some hierarchical app/sublevel-1/sublevel-2/...
