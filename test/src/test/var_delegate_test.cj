package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

/**
 测试变量委托
 */
@Test
class VarDelegateTest {
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
    @Delegate[delegate]
    var varVar: String
    @TestCase
    func testVar() {
        @Assert(varVar == defStr + "@get")

        varVar = "test"

        @Assert(delegate.str == "test@set")

        @Assert(varVar == "test@set@get")
    }

    //测试let变量
    @Delegate[delegate]
    let letVar: String
    @TestCase
    func testLetVar() {
        @Assert(letVar == defStr + "@get")

        // cannot assign to immutable value
        //letVar = "test"
    }

    //测试静态var变量
    @Delegate[staticdelegate]
    static var staticVarVar: String
    @TestCase
    func testStaticVar() {
        @Assert(staticVarVar == defStr + "@get")

        staticVarVar = "test"

        @Assert(staticdelegate.str == "test@set")

        @Assert(staticVarVar == "test@set@get")
    }

    //测试静态let变量
    @Delegate[staticdelegate]
    static let staticLetVar: String
    @TestCase
    func testStaticLetVar() {
        @Assert(staticLetVar == defStr + "@get")

        // cannot assign to immutable value
        //staticLetVar = "test"
    }
}
