package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*
import std.collection.*

/**
 测试变量、属性委托
 */
@Test
class MapSubtypeDelegateTest {
    //被委托的对象
    let delegate = HashMap<String, Any>()

    //被委托的静态对象
    static let staticdelegate = HashMap<String, Any>()

    //重置被委托的静态成员
    @BeforeEach
    func resetDelegate() {
        delegate.clear()
        staticdelegate.clear()
    }

    //测试mut prop 
    @Delegate[delegate]
    mut prop mutProp: String {
    }
    @TestCase
    func testMutProp() {
        //默认空会报错
        let e: ?NoneValueException = @ExpectThrows[NoneValueException](mutProp)
        @Assert(e.isSome())

        mutProp = "test"

        @Assert(delegate["mutProp"] as String == "test")

        delegate["mutProp"] = "test2"
        @Assert(mutProp == "test2")
    }

    //测试prop
    @Delegate[delegate]
    prop immutProp: String {
    }
    @TestCase
    func testImmutProp() {
        //默认空会报错
        let e: ?NoneValueException = @ExpectThrows[NoneValueException](immutProp)

        @Assert(e.isSome())

        delegate["immutProp"] = "test"
        @Assert(immutProp == "test")
    }

    //测试静态mut prop 变量
    @Delegate[staticdelegate]
    mut static prop staticMutProp: String {
    }
    @TestCase
    func testStaticMutProp() {
        //默认空会报错
        let e: ?NoneValueException = @ExpectThrows[NoneValueException](staticMutProp)

        @Assert(e.isSome())

        staticMutProp = "test"
        @Assert(staticdelegate["staticMutProp"] as String == "test")

        staticdelegate["staticMutProp"] = "test2"
        @Assert(staticMutProp == "test2")
    }

    //测试静态prop变量
    @Delegate[staticdelegate]
    static prop staticImmutProp: String {
    }
    @TestCase
    func testStaticImmutProp() {
        //默认空会报错
        let e: ?NoneValueException = @ExpectThrows[NoneValueException](staticImmutProp)

        @Assert(e.isSome())

        staticdelegate["staticImmutProp"] = "test"
        @Assert(staticImmutProp == "test")
    }
}
