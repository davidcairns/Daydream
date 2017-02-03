# Daydream

Daydream lets you use the [Daydream View](https://madeby.google.com/vr/) controller with iOS devices.

Use it with [Google's Unity VR SDK](https://developers.google.com/vr/unity/) to build virtual reality games with full controller support. 
Alternatively, use it to add support for the Daydream View controller to your app just for fun.

![Daydream](https://raw.githubusercontent.com/gizmosachin/Daydream/master/Daydream.gif)

### Features
- [x] Simple API similar to the `GameController` framework
- [x] Device discovery
- [x] Support for multiple controllers
- [x] Full access to device trackpad and buttons
- [ ] Support for gyro, accelerometer, and magnetometer
- [ ] tvOS compatibility

![Pod Version](https://img.shields.io/cocoapods/v/Daydream.svg) [![Build Status](https://travis-ci.org/gizmosachin/Daydream.svg?branch=master)](https://travis-ci.org/gizmosachin/Daydream)

## Version Compatibility

Daydream is written in Swift 3.0.

## Device Discovery

**Important:** Ensure your application has a valid description set for the `NSBluetoothPeripheralUsageDescription` in your `Info.plist` file.

Then, subscribe to the `DDControllerDidConnect` notification and begin discovering Daydream View controllers:

``` swift
NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect(_:)), name: Notification.Name.DDControllerDidConnect, object: nil)
DDController.startDaydreamControllerDiscovery()
```

Stop searching for devices:
``` swift
DDController.stopDaydreamControllerDiscovery()
```

Get notified when devices disconnect:
```swift
NotificationCenter.default.addObserver(self, selector: #selector(controllerDidDisconnect(_:)), name: Notification.Name.DDControllerDidDisconnect, object: nil)
```

## Controller Support

Once a device connects, the object on the `DDControllerDidConnect` notification is the newly connected `DDController`. Alternatively, you can access all connected controllers via the static `controllers` array on `DDController`.

```swift
func controllerDidConnect(_ notification: Notification) {
	guard let controller = notification.object as? DDController else { return }
	// ...
}
```

Handle touches on the device touchpad by setting its `pointChangedHandler`:
```swift
controller.touchpad.pointChangedHandler = { (touchpad: DDControllerTouchpad, point: CGPoint) in
	print("The point changed to \(point).")
}
// ...
```

You can access all of the buttons available on any instance of `DDController`:
- `appButton`
- `homeButton`
- `volumeUpButton`
- `volumeDownButton`

Each button has the following handlers:
- `valueChangedHandler`: Receive continuous updates on the state of the button.
- `pressedChangedHandler`: Only receive updates when the pressed state of the button changes.
- `longPressHandler`: Only receive an update when the button has been pressed for one second.

For example, to continuously print the pressed state of the home button:
```swift
controller.homeButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
	print("The home button is currently \(pressed ? "pressed" : "not pressed").")
}
// ...
```

## Device Information

You can access the current battery percentage of the controller by accessing the `batteryLevel` property on `DDController`. Unfortunately, due to a hardware limitation, you can't receive continuous updates when the battery level changes. 

Subscribe to the `DDControllerDidUpdateBatteryLevel` notification and call `updateBatteryLevel()` on the desired controller.

```swift
override func viewWillAppear(_ animated: Bool) {
	super.viewWillAppear(animated)

	NotificationCenter.default.addObserver(self, selector: #selector(controllerDidUpdateBatteryLevel(_:)), name: Notification.Name.DDControllerDidUpdateBatteryLevel, object: nil)
	guard DDController.controllers.count > 0 else { return }
	guard let controller = DDController.controllers[0] else { return }
	controller.updateBatteryLevel()
}

func controllerDidUpdateBatteryLevel(_ notification: Notification) {
	guard let controller = notification.object as? DDController else { return }
	guard let battery = controller.batteryLevel else { return }
	print("The battery level is \(battery).")
}
```

You can also access the following properties on all `DDController` instances:
- `manufacturer`
- `firmwareVersion`
- `serialNumber`
- `modelNumber`
- `hardwareVersion`
- `softwareVersion`

[Please see the documentation](http://gizmosachin.github.io/Daydream/docs) and check out the sample app for an example.

## Installation

### CocoaPods

Daydream is available for installation using [CocoaPods](http://cocoapods.org/). To integrate, add the following to your Podfile`:

``` ruby
platform :ios, '9.0'
use_frameworks!

pod 'Daydream', '~> 1.0'
```

### Carthage

Daydream is also available for installation using [Carthage](https://github.com/Carthage/Carthage). To integrate, add the following to your `Cartfile`:

``` odgl
github "gizmosachin/Daydream" >= 1.0
```

### Swift Package Manager

Daydream is also available for installation using the [Swift Package Manager](https://swift.org/package-manager/). Add the following to your `Package.swift`:

``` swift
import PackageDescription

let package = Package(
    name: "MyProject",
    dependencies: [
        .Package(url: "https://github.com/gizmosachin/Daydream.git", majorVersion: 0),
    ]
)
```

### Manual

You can also simply copy the `Sources` directory into your Xcode project.

## Credits

This project wouldn't be possible without [this excellent post](https://hackernoon.com/how-i-hacked-google-daydream-controller-c4619ef318e4) from Matteo Pisani, who reverse engineered the service and characteristic parameters from the Daydream View controller.

## License

Daydream is available under the MIT license, see the [LICENSE](https://github.com/gizmosachin/Daydream/blob/master/LICENSE) file for more information.
