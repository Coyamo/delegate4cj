/**
 * Copyright (c) 2024 Cosp
 * Delegate4cj is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *             http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */
package delegate.property

import std.collection.{HashMap, TreeMap}
import std.collection.concurrent.ConcurrentHashMap

/**
 * 扩展ConcurrentHashMap支持属性委托
 */
extend<V> ConcurrentHashMap<String, V> <: ReadWriteProperty<V> {
    /**
     * 委托读取的函数
     */
    public operator func ()(property: DelegateProperty): V {
        return this[property.name]
    }

    /**
     * 委托写的函数
     */
    public operator func ()(value: V, property: DelegateProperty): Unit {
        this[property.name] = value
    }
}
/**
 * 扩展HashMap支持属性委托
 */
extend<V> HashMap<String, V> <: ReadWriteProperty<V> {
    /**
     * 委托读取的函数
     */
    public operator func ()(property: DelegateProperty): V {
        return this[property.name]
    }

    /**
     * 委托写的函数
     */
    public operator func ()(value: V, property: DelegateProperty): Unit {
        this[property.name] = value
    }
}

/**
 * 扩展TreeMap支持属性委托
 */
extend<V> TreeMap<String, V> <: ReadWriteProperty<V> {
    /**
     * 委托读取的函数
     */
    public operator func ()(property: DelegateProperty): V {
        return this[property.name]
    }

    /**
     * 委托写的函数
     */
    public operator func ()(value: V, property: DelegateProperty): Unit {
        this[property.name] = value
    }
}
