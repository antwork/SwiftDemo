//
//  Wrapper.swift
//  PropertyWrapperDemo
//
//  Created by qiang xu on 2021/2/4.
//  Copyright © 2021 ziu. All rights reserved.
//

import Cocoa

@propertyWrapper
enum LazyA<Value> {
    case uninitialized(() -> Value)
    case initialized(Value)
    
    init(wrappedValue: @autoclosure @escaping () -> Value) {
        self = .uninitialized(wrappedValue)
    }
    
    var wrappedValue: Value {
        mutating get {
            print("getter")
            switch self {
            case .uninitialized(let initializer):
                let value = initializer()
                self = .initialized(value)
                
                return value
            case .initialized(let value):
                return value
            }
        }
        set {
            print("setter")
            self = .initialized(newValue)
        }
    }
}

@propertyWrapper
class UserDefaultWrapper<Value> {
    
    private var key: String
    
    private var defaultValue: Value?
    
    init(key: String, defaultValue: Value? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value? {
        get {
            let std = UserDefaults.standard
            return std.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let std = UserDefaults.standard
            if (newValue == nil) {
                std.removeObject(forKey: key)
            } else {
                std.setValue(newValue, forKey: key)
            }
            std.synchronize()
        }
    }
}

@propertyWrapper
class RangeWrapper<Value: Comparable> {
    private var _min: Value?
    private var _max: Value?
    private var _value: Value?
    private var _wrappedValue: Value
    
    init(wrappedValue: Value,  min: Value? = nil, max: Value? = nil) {
        self._min = min
        self._max = max
        self._wrappedValue = wrappedValue
        update(value: wrappedValue)
    }
    
    var wrappedValue: Value {
        get {
            return self._value ?? _wrappedValue
        }
        set {
            update(value: newValue)
        }
    }
    
    func update(value newValue: Value) {
        if let min = _min, newValue < min {
            self._value = min
        } else if let max = _max, newValue > max {
            self._value = max
        } else {
            self._value = newValue
        }
    }
}

class USDemoClass {
    @UserDefaultWrapper(key: "money", defaultValue: 1) var money: Int?
    
    @UserDefaultWrapper(key: "age") var age: Int?
}

class RangeClass {
    @RangeWrapper(min: 1, max: 100) var age: Int = 3
    
    @RangeWrapper(min: 1) var money: Int = 3
    
    @RangeWrapper(max: 60) var minute: Int = 0
}

class WrapperDemo {
    @LazyA var item:String = "Hello"
    
    func run() {
        // 示例1: 使用PropertyWrapper来表示Lazy属性
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // 此时未初始self.item
            print("3s later")
            print(self.item)    // Hello
            self.item = "world"
            print(self.item)    // world
        }
        
        // 示例2: 使用PropertyWrapper获取UserDefault中的值
        let value1 = USDemoClass()
        print("value1.money: \(value1.money ?? 0)") // value1.money: 1
        print("value1.age: \(String(describing: value1.age))") // value1.age: nil
        value1.money = 2
        value1.age = 18
        print("value1.money: \(value1.money ?? 0)") // value1.money: 2
        print("value1.money: \(value1.age ?? 0)") // value1.age: 18
        
        // 示例3: 使用PropertyWrapper限定范围
        let value2 = RangeClass();
        print(value2.age);      // 3
        print(value2.money);    // 3
        print(value2.minute);   // 0
        
        value2.age = -1;
        print(value2.age);      // 1
        value2.age = 101;
        print(value2.age);      // 100
        value2.age = 30;
        print(value2.age);      // 30
        
        value2.money = -1;
        print(value2.money);    // 1
        value2.money = 101;
        print(value2.money);    // 101
        value2.money = 30;
        print(value2.money);    // 30
        
        value2.minute = -1;
        print(value2.minute);   // -1
        value2.minute = 101;
        print(value2.minute);   // 60
        value2.minute = 30;
        print(value2.minute);   // 30
    }
}

