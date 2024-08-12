package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*
import std.sync.*

@Test
class LazyTest {

    static var count = 0
 

    let lazyVal = lazy<String> {
        count++
        return "hello"
    }

    
    let lazyOptVal = lazy<?String> {
        count++
        return None
    }

    @BeforeEach
    func resetDelegate() {
        count = 0
    }


    @Delegate[lazyVal]
    let string:String

    @TestCase
    func testString(){
        @Assert(count == 0)
        @Assert(string == "hello")
        @Assert(count == 1)
        let tmp = string
        @Assert(count == 1)
    }


    @Delegate[lazyOptVal]
    let stringOpt:?String

    @TestCase
    func testStringOpt(){
        @Assert(count == 0)
        @Assert(stringOpt.isNone())
        @Assert(count == 1)
        let tmp = stringOpt
        @Assert(count == 1)
    }



    @Lazy[{
        count++
        return "hello"
    }]
    @Delegate
    let stringMacro:String

    @TestCase
    func testStringMacro(){
        @Assert(count == 0)
        @Assert(stringMacro == "hello")
        @Assert(count == 1)
        let tmp = stringMacro
        @Assert(count == 1)
    }
}