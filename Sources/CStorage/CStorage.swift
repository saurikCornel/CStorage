import Foundation
import SwiftUI

public protocol Memorized {
    associatedtype Value: Codable & Equatable
    static var key: String { get }
    static var defaultValue: Value { get }
}

@propertyWrapper
public struct Memory<Value: Codable & Equatable> {
    public let key: String
    private var value: Value

    public init<T: Memorized>(_ type: T.Type) where T.Value == Value {
        self.key = type.key
        self.value = UserDefaults.standard.decode(Value.self, forKey: key) ?? type.defaultValue
    }

    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            UserDefaults.standard.encode(value, forKey: key)
        }
    }
}

public extension UserDefaults {
    func decode<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func encode<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }
}

public final class ScoreMemory: Memorized {
    public static let key = "score"
    public static let defaultValue: Test = .init(name: "", age: 0, volumes: [])
}

public struct Test: Codable, Equatable {
    public var name: String
    public var age: Int
    public var volumes: [Double]

    public init(name: String, age: Int, volumes: [Double]) {
        self.name = name
        self.age = age
        self.volumes = volumes
    }
}
