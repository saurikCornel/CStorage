import Foundation
import SwiftUI


protocol Memorized {
    associatedtype Value: Codable & Equatable
    static var key: String { get }
    static var defaultValue: Value { get }
}


@propertyWrapper
struct Memory<Value: Codable & Equatable> {
    let key: String
    private var value: Value

    init<T: Memorized>(_ type: T.Type) where T.Value == Value {
        self.key = type.key
        self.value = UserDefaults.standard.decode(Value.self, forKey: key) ?? type.defaultValue
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            UserDefaults.standard.encode(value, forKey: key)
        }
    }
}

extension UserDefaults {
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


final class ScoreMemory: Memorized {
    static let key = "score"
    static let defaultValue: Test = .init(name: "", age: 0, volumes: [])
}


struct Test: Codable, Equatable {
    var name: String
    var age: Int
    var volumes: [Double]
}
