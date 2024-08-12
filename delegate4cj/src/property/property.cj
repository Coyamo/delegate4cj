/**
 * Copyright 2010-2024 JetBrains s.r.o. and Kotlin Programming Language contributors.
 * Use of this source code is governed by the Apache 2.0 license that can be found in the LICENSE-APACHE-V2 file.
 *
 * Copyright (c) 2024 Cosp
 * Delegate4cj is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *             http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */
package delegate.property

import std.reflect.*
/**
   标注只读类型属性、变量委托需要实现的函数
 */
public interface ReadOnlyProperty<T> {
    /**
       委托读取的函数
     */
    operator func ()(property: DelegateProperty): T
}

/**
   标注读写类型属性、变量委托需要实现的函数
 */
public interface ReadWriteProperty<T> {
    /**
       委托读取的函数
     */
    operator func ()(property: DelegateProperty): T

    /**
       委托写的函数
     */
    operator func ()(value: T, property: DelegateProperty): Unit
}

public abstract class ObservableProperty<T> <: ReadWriteProperty<T> {
    private var value: T
    public init(initialValue: T) {
        this.value = initialValue
    }

    /**
       在内容改变之前回调
     */
    protected open func beforeChange(property: DelegateProperty, oldValue: T, newValue: T): Bool {
        return true
    }

    /**
       在内容改变以后回调
     */
    protected open func afterChange(property: DelegateProperty, oldValue: T, newValue: T): Unit {}

    public operator func ()(property: DelegateProperty): T {
        return value
    }

    /**
       委托写的函数
     */
    public operator func ()(value: T, property: DelegateProperty): Unit {
        let oldValue = this.value
        if (!beforeChange(property, oldValue, value)) {
            return
        }
        this.value = value
        afterChange(property, oldValue, value)
    }
}

/**
   描述属性的信息
 */
public struct DelegateProperty {
    /**
       属性的名字
     */
    public let name: String
    public let propType: TypeInfo
    public let isStatic: Bool
    public let optional: Bool
    public let mutable: Bool
    public let getter: Option<() -> ?Any>
    public let setter: Option<(?Any) -> Unit>

    public init(name: String, propType: TypeInfo, isStatic: Bool, optional: Bool, mutable: Bool,
        getter: Option<() -> ?Any>, setter: Option<(?Any) -> Unit>) {
        this.name = name
        this.propType = propType
        this.isStatic = isStatic
        this.optional = optional
        this.mutable = mutable
        this.getter = getter
        this.setter = setter
    }

    public init(name: String, propType: TypeInfo, isStatic: Bool, optional: Bool, mutable: Bool) {
        this(name, propType, isStatic, optional, mutable, None, None)
    }

    /**
      安全获取getter的返回值
      @param T 真实的类型，不要带Option
     */
    public func getValue<T>(): ?T {
        try {
            if (let Some(fun) <- getter) {
                if (let Some(ret) <- fun()) {
                    return ret as T
                }
            }
        } catch (_: NoneValueException) {}

        return None
    }

    public func setValue<T>(v: T) {
        setter?(v)
    }
}
