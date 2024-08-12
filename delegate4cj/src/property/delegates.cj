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

/**
  返回一个属性委托，用于处理一个可读写的属性，该属性具有非 None 的值，但不是在对象构造期间初始化，而是在稍后的时间点初始化。在初始值尚未被分配之前尝试读取该属性会导致异常。
 */
public func notNone<T>(): NotNoneVar<T> {
    return NotNoneVar<T>()
}

/**
  返回一个属性委托，用于处理一个可读写的属性，当该属性发生变化时会调用指定的回调函数。
  @param onChanged 在属性值更改后被调用的回调。当此回调被调用时，属性的值已经发生了改变。
 */
public func observable<T>(
    initialValue: T,
    onChanged: (property: DelegateProperty, oldValue: T, newValue: T) -> Unit
): ReadWriteProperty<T> {
    return DefaultObservableProperty<T>(initialValue, onChanged, None)
}

/**
  返回一个属性委托，用于处理一个可读写的属性，当该属性发生变化时会调用指定的回调函数，并允许该回调函数拦截修改。
  @param onChanged 尝试在更改属性值之前被调用的回调。当此回调被调用时，属性的值还未发生改变。如果回调返回 true，则属性的值将被设置为新值；如果回调返回 false，则新值将被丢弃，属性保持其旧值不变。
 */
public func vetoable<T>(
    initialValue: T,
    onChanged: (property: DelegateProperty, oldValue: T, newValue: T) -> Bool
): ReadWriteProperty<T> {
    return DefaultObservableProperty<T>(initialValue, None, onChanged)
}

private class DefaultObservableProperty<T> <: ObservableProperty<T> {
    private let observableOnChanged: ?(property: DelegateProperty, oldValue: T, newValue: T) -> Unit
    private let vetoableOnChanged: ?(property: DelegateProperty, oldValue: T, newValue: T) -> Bool

    public init(
        initialValue: T,
        observableOnChanged: ?(property: DelegateProperty, oldValue: T, newValue: T) -> Unit,
        vetoableOnChanged: ?(property: DelegateProperty, oldValue: T, newValue: T) -> Bool
    ) {
        super(initialValue)
        this.observableOnChanged = observableOnChanged
        this.vetoableOnChanged = vetoableOnChanged
    }
    public override func beforeChange(property: DelegateProperty, oldValue: T, newValue: T): Bool {
        vetoableOnChanged?(property, oldValue, newValue) ?? true
    }

    public override func afterChange(property: DelegateProperty, oldValue: T, newValue: T): Unit {
        observableOnChanged?(property, oldValue, newValue)
    }
}

public class NotNoneVar<T> <: ReadWriteProperty<T> where T <: Any {
    private var value: ?T = None

    public operator override func ()(property: DelegateProperty): T {
        if (let Some(value) <- value) {
            return value
        }
        throw IllegalStateException("Property ${property.name} should be initialized before get.")
    }

    public operator override func ()(value: T, property: DelegateProperty) {
        this.value = value
    }
}
