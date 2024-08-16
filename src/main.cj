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


    @Delegate(let world2:String by lazy { "world" })
}


main(): Int64 {
    var demo = Demo()
    println(demo.world)
    println(demo.world)
    println(demo.world2)

    return 0
}
