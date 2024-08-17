package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

/**
 测试变量委托
 */
@Test
class ByVarTest {
    let defStr = "string"
    //被委托的对象
    let delegate = StringDelegate()

    //被委托的静态对象
    static let staticdelegate = StringDelegate()

    //重置被委托的静态成员
    @BeforeEach
    func resetDelegate() {
        delegate.str = defStr
        staticdelegate.str = defStr
    }

    //测试var变量
    @Delegate(
        var varVar: String by delegate
    )
    @TestCase
    func testVar() {
        @Assert(varVar == defStr + "@get")

        varVar = "test"

        @Assert(delegate.str == "test@set")

        @Assert(varVar == "test@set@get")
    }

    //测试let变量
    @Delegate(let letVar: String by delegate)
    
    @TestCase
    func testLetVar() {
        @Assert(letVar == defStr + "@get")

        // cannot assign to immutable value
        //letVar = "test"
    }

    //测试静态var变量
    @Delegate(
        static var staticVarVar: String by staticdelegate
    )
    
    @TestCase
    func testStaticVar() {
        @Assert(staticVarVar == defStr + "@get")

        staticVarVar = "test"

        @Assert(staticdelegate.str == "test@set")

        @Assert(staticVarVar == "test@set@get")
    }

    //测试静态let变量
    @Delegate(static let staticLetVar: String by staticdelegate)
    
    @TestCase
    func testStaticLetVar() {
        @Assert(staticLetVar == defStr + "@get")

        // cannot assign to immutable value
        //staticLetVar = "test"
    }
}
