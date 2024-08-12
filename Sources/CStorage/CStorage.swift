import SwiftUI
import Combine

// Protocol for classes that will be used with MemoryState and MemoryPublished
public protocol Memorized {
    associatedtype ValueType: Codable
    static var key: String { get }
    static var defaultValue: ValueType { get }
    
    static func readData() -> ValueType
    static func writeData(_ value: ValueType)
}


// Universal key for working with any types that implement Memorized
public struct MemoryKey<T: Memorized> {
    let type: T.Type
    
    public init(type: T.Type) {
        self.type = type
    }
}

// Manager class for working with UserDefaults
public class MemoryManager {
    static let shared = MemoryManager()
    
    private let queue = DispatchQueue(label: "MemoryManagerQueue", attributes: .concurrent)
    
    private init() {}
    
    func getValue<T: Memorized>(forKey key: MemoryKey<T>) -> T.ValueType where T.ValueType: Codable {
        let type = key.type
        if let data = UserDefaults.standard.data(forKey: type.key),
           let value = try? JSONDecoder().decode(T.ValueType.self, from: data) {
            return value
        } else {
            let defaultValue = type.defaultValue
            queue.async(flags: .barrier) {
                if let encoded = try? JSONEncoder().encode(defaultValue) {
                    UserDefaults.standard.set(encoded, forKey: type.key)
                }
            }
            return defaultValue
        }
    }
    
    func setValue<T: Memorized>(_ value: T.ValueType, forKey key: MemoryKey<T>) where T.ValueType: Codable {
        let type = key.type
        queue.async(flags: .barrier) {
            if let encoded = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(encoded, forKey: type.key)
            }
        }
    }
}


@propertyWrapper
public struct Memory<T: Memorized>: DynamicProperty where T.ValueType: Codable {
    @StateObject private var subscriptionManager: SubscriptionManager<T>

    public init(_ type: T.Type) {
        let key = MemoryKey(type: type)
        let initialValue = MemoryManager.shared.getValue(forKey: key)
        _subscriptionManager = StateObject(wrappedValue: SubscriptionManager(key: key, initialValue: initialValue))
    }
    
    public var wrappedValue: T.ValueType {
        get {
            subscriptionManager.value
        }
        nonmutating set {
            subscriptionManager.updateValue(newValue)
        }
    }
}


public class SubscriptionManager<T: Memorized>: ObservableObject where T.ValueType: Codable {
    let key: MemoryKey<T>
    @Published var value: T.ValueType
    private var cancellable: AnyCancellable?

    public init(key: MemoryKey<T>, initialValue: T.ValueType) {
        self.key = key
        self.value = initialValue
        subscribeToChanges()
    }
    
    private func subscribeToChanges() {
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.updateValueFromUserDefaults()
            }
    }
    
    private func updateValueFromUserDefaults() {
        let updatedValue = MemoryManager.shared.getValue(forKey: key)
        if !self.areValuesEqual(value, updatedValue) {
            DispatchQueue.main.async {
                self.value = updatedValue
            }
        }
    }

    public func updateValue(_ newValue: T.ValueType) {
        if !areValuesEqual(value, newValue) {
            self.value = newValue
            MemoryManager.shared.setValue(newValue, forKey: key)
        }
    }

    private func areValuesEqual(_ lhs: T.ValueType, _ rhs: T.ValueType) -> Bool {
        do {
            let lhsData = try JSONEncoder().encode(lhs)
            let rhsData = try JSONEncoder().encode(rhs)
            return lhsData == rhsData
        } catch {
            return false
        }
    }

    deinit {
        cancellable?.cancel()
    }
}

extension Equatable {
    func equals(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}


// Add convenience methods to the protocol
extension Memorized {
    public static func readData() -> ValueType {
        return MemoryManager.shared.getValue(forKey: MemoryKey(type: self))
    }
    
    public static func writeData(_ value: ValueType) {
        MemoryManager.shared.setValue(value, forKey: MemoryKey(type: self))
    }
}
