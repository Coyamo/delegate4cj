package delegateDemo

import delegate.macros.*
import std.collection.*
import std.reflect.*
import std.ast.*
import std.sync.AtomicReference
import std.random.*


class Demo{
    
    @Delegate[lazy {
        println("hello")
        "world"
    }]
    let world:String

}

main(): Int64 {
    var demo = Demo()
    println(demo.world)
    println(demo.world)

    var clazz = {

    }()
    return 0
}
