package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

/**
 测试变量委托
 */
@Test
class ByOtherTest {
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
        mut prop varVar: String {} by delegate
    )
    @TestCase
    func testVar() {
        @Assert(varVar == defStr + "@get")

        varVar = "test"

        @Assert(delegate.str == "test@set")

        @Assert(varVar == "test@set@get")
    }

    //测试var变量
    @Delegate(
        mut prop varVar2: String {
            get(){
                return "get"
            }

            set(v){
                
            }
        } by delegate
    )
    @TestCase
    func testVar2() {
        @Assert(varVar2 == defStr + "@get")

        varVar2 = "test"

        @Assert(delegate.str == "test@set")

        @Assert(varVar2 == "test@set@get")
    }
}
