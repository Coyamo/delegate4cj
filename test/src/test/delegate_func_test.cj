package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

@Test
class DelegateFuncTest {
    @Delegate[notNone<String>()]
    var str: String

    @TestCase
    func get() {
        let e: ?IllegalStateException = @ExpectThrows[IllegalStateException](str)
        @Assert(e.isSome())

        str = "test"

        @Assert(str == "test")
    }

    var observableNewStr = ""
    @Delegate[observable("hello") { property, oldValue, newValue => 
        observableNewStr = oldValue + newValue 
    }]
    var observableStr: String

    @TestCase
    func observable() {
        @Assert(observableStr == "hello")
        observableStr = " world"
        @Assert(observableStr == " world")
        @Assert(observableNewStr == "hello world")
    }

    var vetoableNewStr = ""
    @Delegate[vetoable("hello") { property, oldValue, newValue => 
        if(newValue == "world") { 
            return false 
        } 
        vetoableNewStr = oldValue + newValue 
        true 
    }]
    var vetoableStr: String

    @TestCase
    func vetoable() {
        @Assert(vetoableStr == "hello")
        vetoableStr = "world"
        @Assert(vetoableStr == "hello")
        vetoableStr = " cangjie"
        @Assert(vetoableNewStr == "hello cangjie")
    }
}
