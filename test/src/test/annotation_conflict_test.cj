package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

//fix: 这里直接在类上面标注@Test宏似乎是有冲突！！
class TestAnnotationClass {
    let delegate = StringDelegate()

    @Delegate[delegate]
    @Anno[6]
    public var varVar: String = ""
}

@Test
class AnnotationConflictTest {

    @TestCase
    func test(){
        let test = TestAnnotationClass()
        let info = TypeInfo.of(test)
        @Assert(info.getInstanceProperty("varVar").findAnnotation<Anno>().isSome())
        
    }

}