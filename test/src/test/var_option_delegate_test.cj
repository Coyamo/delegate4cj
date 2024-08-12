package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

/**
 测试Option类型变量委托
 */
@Test
class VarOptionDelegateTest {
    //被委托的对象
    let delegate = StringOptionDelegate()

    //被委托的静态对象
    static let staticdelegate = StringOptionDelegate()

    //重置被委托的静态成员
    @BeforeEach
    func resetDelegate() {
        delegate.str = None
        staticdelegate.str = None
    }

    //测试var变量
    @Delegate[delegate]
    var varVar: ?String

    @TestCase
    func testVar() {
        @Assert(varVar == "None@get")

        varVar = "test"

        @Assert(delegate.str == "test@set")

        @Assert(varVar == "test@set@get")

        varVar = None

        @Assert(varVar == "None@set@get")
    }

    //测试let变量
    @Delegate[delegate]
    let letVar: ?String
    @TestCase
    func testLetVar() {
        @Assert(letVar == "None@get")
        delegate.str = "test"
        @Assert(letVar == "test@get")
        // cannot assign to immutable value
        //letVar = "test"
    }

    //测试静态var变量
    @Delegate[staticdelegate]
    static var staticVarVar: ?String
    @TestCase
    func testStaticVar() {
        @Assert(staticVarVar == "None@get")

        staticVarVar = "test"

        @Assert(staticdelegate.str == "test@set")

        @Assert(staticVarVar == "test@set@get")

        staticVarVar = None
        @Assert(staticVarVar == "None@set@get")
    }

    //测试静态let变量
    @Delegate[staticdelegate]
    static let staticLetVar: ?String
    @TestCase
    func testStaticLetVar() {
        @Assert(staticLetVar == "None@get")
        staticdelegate.str = "test"
        @Assert(staticLetVar == "test@get")
        // cannot assign to immutable value
        //staticLetVar = "test"
    }
}
