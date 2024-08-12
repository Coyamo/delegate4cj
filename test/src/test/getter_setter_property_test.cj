package delegateTest.test


import std.unittest.*
import std.unittest.testmacro.*
import delegate.macros.*

@Test
class GetterSetterPropertyTest {

    @Delegate[TestGetterSetterStringDelegate()]
    prop prop1:String {
        get(){
            return "hello"
        }
    }

    //属性
    @TestCase
    func testProp1(){
        @Assert(prop1 == "def@hello")
    }




    @Delegate[TestGetterSetterOptionStringDelegate()]
    prop prop1Option:?String {
        get(){
            return "hello"
        }
    }

    //Option属性
    @TestCase
    func testProp1Option(){
        @Assert(prop1Option == "def@hello")
    }



    
    var temp = ""
    @Delegate[TestGetterSetterStringDelegate()]
    mut prop prop2:String {
        get(){
            return "hello"
        }
        set(v){
            temp = v
        }
    }
    
    //可变属性
    @TestCase
    func testProp2(){
        @Assert(prop2 == "def@hello")
        prop2 = "new"
        @Assert(prop2 == "new@hello")
        @Assert(temp == "new")
    }


    var temp2:?String = "test"
    @Delegate[TestGetterSetterOptionStringDelegate()]
    mut prop prop2Option:?String {
        get(){
            return "hello"
        }
        set(v){
            temp2 = v
        }
    }
    
    //可变属性
    @TestCase
    func testProp2Option(){
        @Assert(prop2Option == "def@hello")
        prop2Option = None
        @Assert(prop2Option == "None@hello")
        @Assert(temp2.isNone())
    }

    

     @Delegate[TestGetterSetterStringDelegate()]
    var var1:String = "hello"

    //属性
    @TestCase
    func testVar1(){
        @Assert(var1 == "def@hello")
    }
}