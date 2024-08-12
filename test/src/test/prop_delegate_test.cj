package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

/**
 测试变量、属性委托
 */
@Test
class PropDelegateTest {
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

    //测试mut prop 
    @Delegate[delegate]
    mut prop mutProp: String {
    }
    @TestCase
    func testMutProp() {
        @Assert(mutProp == defStr + "@get")

        mutProp = "test"

        @Assert(delegate.str == "test@set")

        @Assert(mutProp == "test@set@get")
    }

    //测试prop
    @Delegate[delegate]
    prop immutProp: String {
    }
    @TestCase
    func testImmutProp() {
        @Assert(immutProp == defStr + "@get")

        delegate.str = "test"
        @Assert(immutProp == "test@get")
        // cannot assign to immutable value
        //immutProp = "test"

    }

    //测试静态mut prop 变量
    @Delegate[staticdelegate]
    mut static prop staticMutProp: String {
    }
    @TestCase
    func testStaticMutProp() {
        @Assert(staticMutProp == defStr + "@get")

        staticMutProp = "test"

        @Assert(staticdelegate.str == "test@set")

        @Assert(staticMutProp == "test@set@get")
    }

    //测试静态prop变量
    @Delegate[staticdelegate]
    static prop staticImmutProp: String {
    }
    @TestCase
    func testStaticImmutProp() {
        @Assert(staticImmutProp == defStr + "@get")

        // cannot assign to immutable value
        // staticImmutProp = "test"
    }
}
