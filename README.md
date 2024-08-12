
---

# CStorage

CStorage is a Swift library that provides a custom property wrapper `@Memory` for persisting and managing stateful data in SwiftUI applications. This wrapper allows developers to easily store and retrieve values that conform to `Codable` and `Equatable`, leveraging `UserDefaults` for persistence.

## Features

- **Simple Data Persistence**: Store and retrieve data in `UserDefaults` using a property wrapper.
- **SwiftUI Integration**: Designed to work seamlessly within SwiftUI views, supporting state management and UI updates.
- **Type Safety**: Ensures that only `Codable` and `Equatable` types are used, promoting safer code.
- **Customizable**: Define your own storage keys and default values for flexible data handling.

## Installation

### Swift Package Manager

CStorage can be integrated into your project using the Swift Package Manager (SPM). Here's how:

1. Open your Xcode project.
2. Go to `File` -> `Add Packages...`.
3. Enter the URL of the CStorage repository.
4. Choose the appropriate version and add the package to your project.

## Usage

### 1. Define a Memorized Class

To use CStorage, start by defining a class that conforms to the `Memorized` protocol. This class will manage the data you wish to persist.

```swift
import CStorage

final class ScoreMemory: Memorized {
    static let key = "score"
    static let defaultValue: Test = .init(name: "", age: 0, volumes: [])
}

struct Test: Codable, Equatable {
    var name: String
    var age: Int
    var volumes: [Double]
}
```

- **`key`**: A unique identifier for the stored data.
- **`defaultValue`**: A default value that will be used if no value is found in `UserDefaults`.

### 2. Use the `@Memory` Property Wrapper in a SwiftUI View

The `@Memory` property wrapper allows you to easily store and retrieve data in your SwiftUI views. Here’s an example of how to use it:

```swift
import SwiftUI
import CStorage

struct ContentView: View {
    @Memory(ScoreMemory.self) var score
    @ObservedObject var vm = ViewModel()

    var body: some View {
        VStack {
            Text("Score: \(score.age)")
            
            Button("Test") {
                vm.test()
            }

            Button("Increase Score") {
                score.age += 20
            }
        }
        .padding()
    }
}

class ViewModel: ObservableObject {
    func test() {
        var current = ScoreMemory.readData()
        current.age = -20
        ScoreMemory.writeData(current)
    }
}
```

- **`@Memory(ScoreMemory.self) var score`**: This line initializes the `score` property with the value stored under the `key` defined in `ScoreMemory`. If no value is found, it uses the `defaultValue`.

- **UI Updates**: The `@Memory` property wrapper is fully integrated with SwiftUI’s state management system, ensuring that the UI updates automatically when the stored value changes.

### 3. Reading and Writing Data in ViewModel

In cases where you need to manually read or write data, such as in a `ViewModel`, you can do so using the methods `readData` and `writeData` provided by the `Memorized` protocol.

```swift
class ViewModel: ObservableObject {
    func test() {
        var current = ScoreMemory.readData() // Read the current value
        current.age = -20 // Modify the value
        ScoreMemory.writeData(current) // Save the new value
    }
}
```

### Important Considerations

- **Usage Restriction**: The `@Memory` property wrapper should only be used within SwiftUI views. This is because the wrapper is designed to work with SwiftUI’s state management system, which ensures that any changes to the stored data are reflected in the UI. Using `@Memory` outside of SwiftUI views, such as in regular classes or non-SwiftUI contexts, can lead to unexpected behavior, including failure to update the UI or synchronize data properly.

- **Thread Safety**: `@Memory` is not inherently thread-safe. Accessing and modifying stored data should be done on the main thread when interacting with SwiftUI. If you need to perform operations on a background thread, ensure that appropriate synchronization mechanisms are in place to avoid data races.

- **Data Size and Complexity**: Since `UserDefaults` is used for storage, be mindful of the size and complexity of the data you store. While `UserDefaults` is suitable for small to moderately sized data, it is not designed for large datasets or complex object graphs. Storing large or deeply nested structures can lead to performance issues.

- **Default Values**: When no value is found in `UserDefaults` under the specified key, the `defaultValue` specified in your `Memorized` class will be used. Ensure that your default values are meaningful and align with the expected behavior of your app.

### Example Projects

Here are a few example use cases where CStorage can be applied:

#### User Settings Storage

Store and manage user settings, such as theme preferences or notification settings, that need to persist across app sessions.

```swift
final class UserSettings: Memorized {
    static let key = "userSettings"
    static let defaultValue: Settings = .init(isDarkMode: false, notificationsEnabled: true)
}

struct Settings: Codable, Equatable {
    var isDarkMode: Bool
    var notificationsEnabled: Bool
}

struct SettingsView: View {
    @Memory(UserSettings.self) var settings

    var body: some View {
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
        Toggle("Notifications", isOn: $settings.notificationsEnabled)
    }
}
```

#### High Scores in a Game

Keep track of high scores in a simple game, ensuring that the scores persist between app launches.

```swift
final class HighScoreMemory: Memorized {
    static let key = "highScores"
    static let defaultValue: [Int] = []
}

struct HighScoreView: View {
    @Memory(HighScoreMemory.self) var highScores

    var body: some View {
        List(highScores, id: \.self) { score in
            Text("Score: \(score)")
        }
    }
}
```

### License

CStorage is released under the MIT license. See [LICENSE](LICENSE) for details.

### Contributions

Contributions are welcome! Feel free to open an issue or submit a pull request if you have suggestions for improvements or new features.

### Conclusion

CStorage offers a straightforward way to manage persistent state in SwiftUI applications. By leveraging `@Memory`, developers can ensure that their app’s state is preserved across sessions, all while enjoying the simplicity and power of SwiftUI’s declarative UI framework. Use CStorage to enhance your app's user experience with minimal effort and maximum efficiency.

---

This README provides a detailed guide on using CStorage, including how to install it, how to define and use the `@Memory` property wrapper, important considerations, and some practical examples. This should serve as a useful reference for anyone looking to integrate CStorage into their SwiftUI projects.
