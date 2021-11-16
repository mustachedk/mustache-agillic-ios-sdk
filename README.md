# Agillic SDK for iOS

The Agillic SDK enables you to utilize the Agillic platform from within your iOS App.
The SDK currently includes the following functionality:

 * Register devices used by a recipient in your mobile application.
 * Register a recipient token required to send a Push Notification to a device using Apple PN on iOS or Firebase Cloud Messaging for Android. When registered, this token will allow sending push notifications to recipients via the Agillic Dashboard.
 * Track recipient events. Tracking can be paused and resumed when requested by the user. Tracked events can be used to define [Target Groups](https://support.agillic.com/hc/en-gb/articles/360007001991-All-You-Need-to-Know-About-Target-Groups) in the Agillic Dashboard which can be used to direct targeted marketing and other communication.

Read more about the Agillic Platform on the [official Agillic website](https://agillic.com).
And in our [Developer portal](https://developers.agillic.com).


Agillic SDK for Android can be found here: 


## Requirements

- Requires minimum iOS 11+

## Installation

See the subsections below for details about the different installation methods.
* [Swift Package Manager](README.md#swift-package-manager)
* [Import Manually](README.md#import-manually)

### Swift Package Manager

Add a package by selecting `File` → `Add Packages…` in Xcode’s menu bar.

Search for the Agillic iOS SDK using the repo's URL:
```console
https://github.com/agillic/agillic-ios-sdk.git
```

For detailed documentaion on setting up the Agillic SDK with Swift Package Manger see: 
[Swift Package Manager](docs/SwiftPackageManager.md)

### Import Manually

* Download this repository by selecting `Code` → `Download ZIP`.
* Open Downloads and locate ./src/AgillicSDK folder
* Drag and drop the AgillicSDK to your project
* Make sure to check `Copy items if needed` and Add to your App Target.
* The Agillic SDK are dependant on the Snowplow iOS Tracker SDK version 1.7.1 and FMDB (OUT OF SCOPE)

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

Your Agillic SDK instance is now ready for usage.

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

Please provide any feedback via a [GitHub Issue](https://github.com/agillic/agillic-ios-sdk/issues/new).

## Copyright and license

Agillic SDK for iOS is available under the Apache 2.0 license. See [LICENSE](LICENSE) file for more info.

```
   Copyright 2021 Agillic

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

