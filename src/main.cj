package delegateDemo

import delegate.macros.*
import std.collection.*
import std.reflect.*
import std.ast.*
import std.sync.AtomicReference
import std.random.*


class Demo{

    @Delegate(
        let world:String by lazy {
            println("hello")
            "world"
        }
    )
}


main(): Int64 {
    var demo = Demo()

    println(demo.world)
    println(demo.world)

    return 0
}
