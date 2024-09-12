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

import std.sync.ReentrantMutex
import std.sync.AtomicReference
import std.reflect.*

/**
  承载一个具有延迟初始化的值。使用 lazy 函数创建 Lazy 类型的实例
 */
public interface ILazy<T> {
    prop value: T

    func isInitialized(): Bool
}

public abstract class LazyProp<T> <: ILazy<T> {}

/**
  扩展实现ToString
 */
extend<T> LazyProp<T> <: ToString where T <: ToString {
    public func toString(): String {
        return if (isInitialized()) {
            value.toString()
        } else {
            "Lazy value not initialized yet."
        }
    }
}

/**
  扩展实现委托
 */
extend<T> LazyProp<T> <: ReadOnlyProperty<T> {
    public operator func ()(property: DelegateProperty): T {
        return value
    }
}

/**
  使用指定的初始化函数 `initializer`，创建一个新的 `Lazy` 实例。
 */
public func lazy<T>(initializer: () -> T): LazyProp<T> {
    return SynchronizedLazyImpl(initializer)
}

/**
  返回一个已经初始化的lazy对象
 */
public func lazyOf<T>(value: T): LazyProp<T> {
    return InitializedLazyImpl(value)
}

private class InitializedLazyImpl<T> <: LazyProp<T> {
    private var _value: T
    public InitializedLazyImpl(value: T) {
        this._value = value
    }
    public override prop value: T {
        get() {
            return _value
        }
    }

    public override func isInitialized(): Bool {
        return true
    }
}

/**
  标记未初始化的类
 */
class Uninitialized {}
/**
  标记未初始化的对象
 */
let UNINITIALIZED_VALUE = Uninitialized()

private class SynchronizedLazyImpl<T> <: LazyProp<T> {
    private var initializer: ?(() -> T)
    public SynchronizedLazyImpl(initializer: () -> T) {
        this.initializer = initializer
    }
    private var _value: AtomicReference<Box<Any>> = AtomicReference(Box<Any>(UNINITIALIZED_VALUE))

    let lock = ReentrantMutex()

    public override prop value: T {
        get() {
            let _v1 = _value.load().value
            if (!(_v1 is Uninitialized)) {
                return (_v1 as T).getOrThrow()
            }

            return synchronized(lock) {
                let _v2 = _value.load().value
                if (!(_v2 is Uninitialized)) {
                    (_v2 as T).getOrThrow()
                } else {
                    let typedValue = initializer.getOrThrow()()
                    _value.store(Box<Any>(typedValue))
                    initializer = None
                    typedValue
                }
            }
        }
    }

    public override func isInitialized(): Bool {
        return !(_value is Uninitialized)
    }
}
