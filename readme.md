# Delegate4cj 委托

一个基于宏的变量及属性委托库，适用于 仓颉 编程语言。
## 问卷
不知道也没有人使用这个库-.-   
这里想调查下那种委托的编写方式更加可以被接受呢，欢迎在issue回复

[问卷地址](https://gitcode.com/Cosp/delegate4cj/issues/5)
## 特性
1. 变量委托：将`let`、`var`修饰的变量被转换为属性实现属性委托
2. 属性委托：将属性的实现细节委托给另一个对象处理
3. 内置委托实现：`notNone`、`observable`、`vetoable`、`lazy`
4. 委托DSL：支持使用`by`实现委托如`@Delegate(var varVar: String by delegate)`
5. todo：函数委托与类委托（规划中）

## 开发计划
[ ] 属性\变量委托 80%

[ ] 函数委托

[ ] 类委托

## 使用文档
### 导入包
使用注解需要导入`delegate.macros.*`

导入这个会自动导入以下两个包
```cj
import std.reflect.TypeInfo
import delegate.property.*
```
### 实现被委托对象 

在使用属性/变量委托前，需要定义实现被委托对象。

这里约定重载对象的`()`运算符实现数据的读写，

约定实现`operator func ()(property:DelegateProperty): T`来从被委托的对象获取数据，

约定使用`operator func ()(value: T, property:DelegateProperty): Unit`把数据传递给被委托的对象。

比如实现一个委托字符串读写的类：
```cj
class StringDelegate {
    private var str:String = "默认委托字符串"

    public operator func ()(property:DelegateProperty): String {
        return str
    }
    public operator func ()(v:String, property:DelegateProperty) {
       str = v + "-set-delegate"
    }
}
```
为了规范约束，这里定义了两个接口来限定接口`ReadOnlyProperty<T>`、`ReadWriteProperty<T>`

对于只读的属性，可以实现以下接口：
```cj
/**
    标注只读类型属性、变量委托需要实现的函数
*/
public interface ReadOnlyProperty<T> {
    /**
        委托读取的函数
    */
    operator func ()(property:DelegateProperty): T
}

```
对于可读写的类型可以实现以下接口
```cj
/**
    标注读写类型属性、变量委托需要实现的函数
*/
public interface ReadWriteProperty<T> {
    /**
        委托读取的函数
    */
    operator func ()(): T

    /**
        委托写的函数
    */
    operator func ()(value: T, property:DelegateProperty): Unit
}

```
所以之前给出的例子可以写为：
```cj
class StringDelegate <: ReadWriteProperty<String> {
    private var str:String = "默认委托字符串"

    public operator override func ()(property:DelegateProperty): String {
        return str
    }
    public operator override func ()(v:String, property:DelegateProperty) {
       str = v + "-set-delegate"
    }
}
```
### DSL
`delegate4cj`提供了一个简易的DSL实现委托，在属性、变量定义后直接使用自定义的`by`关键字加上被委托对象：  
```cj
@Delegate(
    var varVar: String by delegate
)
```
当然以下写法也是ok的：  
```cj
@Delegate(
    mut prop p1: String by delegate
)

@Delegate(
    mut prop p2: String {} by delegate
)


@Delegate(
    mut prop p3: String {
        get(){ return "get"}
        set(v){}
    } by delegate
)
```
除了使用DSL的方式还可以使用宏参数的方式实现委托，后面的例子都以宏参数的方式为例，但是都可以转换为DSL方式实现(扩展委托宏如`@Lazy`除外)。
  
    
### 属性委托 
使用`@Delegate`宏标注在属性上，把被委托对象作为参数传入即可，注意属性后面的`{}`可以省略，如果实现了`get`和`set`会被委托的对象替换，被替换的getter/setter会保存在`DelegateProperty`结构中。

```cj
class TestProp {
    
    @Delegate[StringDelegate()]
    public prop normalProp: String {}

    @Delegate[StringDelegate()]
    public mut prop mutProp: String {}

    @Delegate[StringDelegate()]
    public static prop normalStaticProp: String {}
    
    @Delegate[StringDelegate()]
    public static mut prop mutStaticProp: String {}

    @Delegate[StringDelegate()]
    mut prop prop2Option:?String {
        get(){
            return "hello"
        }
        set(v){
            temp2 = v
        }
    }
}
```
### 变量委托
使用`@Delegate`宏标注在变量上，把被委托对象作为参数传入即可，变量会被转换为属性以实现委托。注意如果这里设置了默认值，会被转换为getter保存在`DelegateProperty`结构中。

**变量委托的副作用**：  
如果带有默认值类型不为值的语句如`let num:Int = Random().nextInt64()`,在不使用委托的情况下值是不会再变的，使用委托后转换的默认getter会在每次调用生成一个随机数。
```cj
class TestVar {
    @Delegate[StringDelegate()]
    public var normalVar: String 

    @Delegate[StringDelegate()]
    public let letVar: String 

    @Delegate[StringDelegate()]
    public static var normaStaticlVar: String 

    @Delegate[StringDelegate()]
    public static let letStaticVar: String 
}
```
### Map类型委托
对于标准库的`HashMap<String, V>`、`ConcurrentHashMap<String, V>`和`TreeMap<String, V>`使用扩展实现了属性委托。其他类似数据结构都可以通过扩展实现委托。

限制：map中的key的名字要与类中的属性名字保持一致，且map的键类型须为字符串,值类型为属性的类型或更大范围的类型。


使用方法：
```cj
class Test {
  
    let map = HashMap<String, String>()

    init() {
        map.put("key", "key value")
    }

    @Delegate[map]
    var key:String
}
```
### 内置委托
#### notNone
`notNone`委托实现确保委托的变量不能为空，可以用于延迟设置对象等场景。如果没有设置就获取会抛出`IllegalStateException`异常。

使用例子
```cj
class Demo {
    @Delegate[notNone<String>()]
    var str: String
}
```
这里提供了一个简化调用的宏`@NotNone`，要求`@NotNone`在`@Delegate`上面且`@Delegate`不需要参数。
```cj
class Demo {
    @NotNone
    @Delegate
    var str: String
}
```
#### observable
`observable`委托实现对对象的监听，在值被设置之后触发回调。委托时需要指定初始值和实现回调。
```cj
class Demo {
    @Delegate[observable("hello") { property, oldValue, newValue => 
        //...
    }]
    var observableStr: String
}    

```
这里提供了一个简化调用的宏`@Observable`，要求`@Observable`在`@Delegate`上面且`@Delegate`不需要参数。`@Observable`接受一个无名的函数调用，传入初始值和回调。
```cj
class Demo {
    @Observable[("hello"){ property, oldValue, newValue => 
        // ...
    }]
    @Delegate
    var observableStr: String
}
```
#### vetoable
`vetoable`委托实现对对象的监听，在值被设置之前触发回调，并且根据回调返回的`Bool`值确定是否拦截设置，如果防护`true`则表示允许设置。委托时需要指定初始值和实现回调。
```cj
class Demo {
    @Delegate[vetoable("hello") { property, oldValue, newValue => 
        // ...
        true 
    }]
    var vetoableStr: String
}    

```
这里提供了一个简化调用的宏`@Vetoable`，要求`@Vetoable`在`@Delegate`上面且`@Delegate`不需要参数。`@Vetoable`接受一个无名的函数调用，传入初始值和回调。
```cj
class Demo {
    @Vetoable[("hello") { property, oldValue, newValue => 
        // ...
        true 
    }]
    @Delegate
    var vetoableStr: String
}
```
#### lazy
用于实现懒加载，在实际调用的时候去初始化加载，且只加载一次
```cj
class LazyTest {

    let lazyVal = lazy {
        println("init")
        "hello"
    }

    @Delegate[lazyVal]
    let string:String
}
```
这里提供了`@Lazy`宏简化调用,要求`@Lazy`在`@Delegate`上面且`@Delegate`不需要参数。`@Lazy`接受一个lambda调用。
```cj
    @Lazy[{
        count++
        "hello"
    }]
    @Delegate
    let stringMacro:String
```

## 宏、注解冲突解决
因为是使用宏修改原有代码，所以如果同时使用其他宏或者注解可能会导致Token解析异常，需要明确宏的作用适当调整使用位置，可以兼容部分其他注解和宏。
## 原理
使用宏替换掉，变量和属性的读写。变量会被转换为属性以实现委托。对于属性，为了保持`get`和`set`是使用的同一个委托对象，会创建一个以`_`开头的中间`private`对象。
## License
本开源库受Kotlin标准库启发衍生开发，使用仓颉语言实现。  
需要遵守Kotlin的[Apache License (Version 2.0)](http://www.apache.org/licenses/)开源协议  
同时本开源库使用[MulanPSL2](http://license.coscl.org.cn/MulanPSL2)
