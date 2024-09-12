package delegateTest.test

import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

@Test
class AnnotationConflictTest {

    // let delegate = StringDelegate()

    // @Delegate[delegate]
    // @Anno[6]
    // public var varVar: String = ""

    @TestCase
    func test(){
        let info = TypeInfo.of(this)
        @Assert(1==1)
        
    }

}