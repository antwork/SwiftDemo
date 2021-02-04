//
//  weakunknowned.swift
//  SwiftDemo
//
//  Created by luyouon 2021/2/4.
//

import Foundation

class Student {
    var name: String
    
    var card: StudentCard?
    
    init(name: String) {
        self.name = name
        self.card = StudentCard(student: self)
        print("init Student")
    }
    
    deinit {
        print("deinit Student")
    }
}

class StudentCard {
    unowned var student: Student
    
    init(student: Student) {
        self.student = student
        print("init StudentCard")
    }
    
    deinit {
        print("deinit StudentCard")
    }
}


class Student1 {
    var name: String
    
    var card: StudentCard1?
    
    init(name: String) {
        self.name = name
        self.card = StudentCard1(student: self)
        print("init Student1")
    }
    
    deinit {
        print("deinit Student1")
    }
}

class StudentCard1 {
    weak var student: Student1?
    
    init(student: Student1?) {
        self.student = student
        print("init StudentCard1")
    }
    
    deinit {
        print("deinit StudentCard1")
    }
}

class ModelA1 {
    weak var modelB: ModelB?
    
    deinit { print("ModelA1 is being deinitialized") }
}

class ModelA2 {
    unowned var modelB: ModelB?
    
    deinit { print("ModelA2 is being deinitialized") }
}

class ModelB {
    deinit { print("ModelB is being deinitialized") }
}

class WeakUnownedDemo {
    
    var stu: Student?
    var stu1: Student1?
    
    func run() {
        
        // 示例1: 展示weak的作用
        // weak属性在关联对象被释放后, 将其值设置为nil
        // 所以weak标记的属性必须是可选值<Optional>
        var modelB1:ModelB? = ModelB()
        let modelA1:ModelA1? = ModelA1()
        print("modelA1.modelB:\(String(describing: modelA1?.modelB))") // modelA1.modelB:nil
        modelA1?.modelB = modelB1
        print("modelA1.modelB:\(String(describing: modelA1?.modelB))") // modelA1.modelB:Optional(SwiftDemo.ModelB)
        modelB1 = nil
        print("modelA1.modelB:\(String(describing: modelA1?.modelB))") // modelA1.modelB:nil

        // 示例2: unknowned应该翻译为"不能在我之前释放"
        // 假设unknowned属性在当前对象之前释放了, 当前对象引用它就会崩溃, 因为当前对象并没有将属性设置为nil
        // 指针指向了一个野指针
        var modelB2: ModelB? = ModelB()
        let modelA2: ModelA2? = ModelA2()
        print("modelA2.modelB:\(String(describing: modelA2?.modelB))")  // modelA2.modelB:nil
        modelA2?.modelB = modelB2
        print("modelA2.modelB:\(String(describing: modelA2?.modelB))") // modelA2.modelB:Optional(SwiftDemo.ModelB)
        modelB2 = nil
        // print("modelA2.modelB:\(String(describing: modelA2?.modelB))") // Fatal error: Attempted to read an unowned reference but object 0x600002a14020 was already deallocated

        // 示例3: 不论是weak还是unowned, 在没有互相引用的情况下
        // 当主体对象释放后, 属性对象也会在没有其他对象强引用的情况下进行释放
        let modelB3:ModelB? = ModelB()
        var modelA3:ModelA1? = ModelA1()
        print("modelA3.modelB:\(String(describing: modelA3?.modelB))") // modelA1.modelB:nil
        modelA3?.modelB = modelB3
        print("modelA1.modelB:\(String(describing: modelA3?.modelB))") // modelA1.modelB:Optional(SwiftDemo.ModelB)
        modelA3 = nil
        // 输出: ModelA1 is being deinitialized
        print("-----modelA3 = nil End------")
        // 当前作用域结束后, 由于没有对象强引用ModelB3, ModelB3也将释放: ModelB is being deinitialized

        let modelB4: ModelB? = ModelB()
        var modelA4: ModelA2? = ModelA2()
        print("modelA4.modelB:\(String(describing: modelA4?.modelB))")  // modelA2.modelB:nil
        modelA4?.modelB = modelB4
        print("modelA4.modelB:\(String(describing: modelA4?.modelB))") // modelA2.modelB:Optional(SwiftDemo.ModelB)
        modelA4 = nil
        print("-----modelA4 = nil End------")
        // 当前作用域结束后, 由于没有对象强引用ModelB4, ModelB4也将释放: ModelB is being deinitialized
        
        // 使用unowned引用学生
        // 学生可能没有卡(如丢卡), 卡片一定要有学生
        stu = Student(name: "Bill")
        print("name:\(String(describing: stu?.name)) card:\(String(describing: stu?.card))")
        stu = nil
        print("part I ends")

        // 使用weak引用学生
        stu1 = Student1(name: "Bill")
        print("name:\(String(describing: stu1?.name)) card:\(String(describing: stu1?.card))") // name:Optional("Bill") card:Optional(SwiftDemo.StudentCard1)
        stu1 = nil
        print("part II ends")
    }
}
