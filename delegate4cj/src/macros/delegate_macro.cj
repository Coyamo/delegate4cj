/**
 * Copyright (c) 2024 Cosp
 * Delegate4cj is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *             http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details.
 */
macro package delegate.macros

import std.collection.*
import std.ast.*
import std.reflect.TypeInfo
import delegate.property.*

/**
  实现懒加载
  @param attrs 初始化回调。如 `{"hello"}`
 */
public macro Lazy(attrs: Tokens, input: Tokens): Tokens {
    let tokens = Tokens()
    let typeNode = getChildMessages("Delegate")
    if (typeNode.size < 1) {
        diagReport(DiagReportLevel.ERROR, input, "@Delegate required.", "Illegal expression")
        return input
    }
    let realType = Token(TokenKind.IDENTIFIER, typeNode[0].getString("realType"))
    let isOption = typeNode[0].getBool("isOption")

    let realDelegate = if (isOption) {
        quote(lazy<?$(realType)>()$(attrs) )
    } else {
        quote(lazy<$(realType)>()$(attrs) )
    }
    for (tk in input) {
        if (tk == PROP_DELEGATE_PLACEHOLER_TOKENS) {
            tokens.append(realDelegate)
        } else {
            tokens.append(tk)
        }
    }
    return tokens
}

/**
  实现非空类型委托，可以实现延迟初始化
 */
public macro NotNone(input: Tokens): Tokens {
    let tokens = Tokens()
    let typeNode = getChildMessages("Delegate")
    if (typeNode.size < 1) {
        diagReport(DiagReportLevel.ERROR, input, "@Delegate required.", "Illegal expression")
        return input
    }
    let realType = Token(TokenKind.IDENTIFIER, typeNode[0].getString("realType"))
    let isOption = typeNode[0].getBool("isOption")

    let realDelegate = if (isOption) {
        quote(notNone<?$(realType)>() )
    } else {
        quote(notNone<$(realType)>() )
    }
    for (tk in input) {
        if (tk == PROP_DELEGATE_PLACEHOLER_TOKENS) {
            tokens.append(realDelegate)
        } else {
            tokens.append(tk)
        }
    }
    return tokens
}

/**
  实现屬性可观察委托
  @param attrs 具体逻辑  如：("default value"){ property, oldValue, newValue =>  }
 */
public macro Observable(attrs: Tokens, input: Tokens): Tokens {
    let tokens = Tokens()
    let typeNode = getChildMessages("Delegate")
    if (typeNode.size < 1) {
        diagReport(DiagReportLevel.ERROR, input, "@Delegate required.", "Illegal expression")
        return input
    }
    let realType = Token(TokenKind.IDENTIFIER, typeNode[0].getString("realType"))
    let isOption = typeNode[0].getBool("isOption")

    let realDelegate = if (isOption) {
        quote(observable<?$(realType)>$(attrs))
    } else {
        quote(observable<$(realType)>$(attrs))
    }
    for (tk in input) {
        if (tk == PROP_DELEGATE_PLACEHOLER_TOKENS) {
            tokens.append(realDelegate)
        } else {
            tokens.append(tk)
        }
    }
    return tokens
}

/**
  实现屬性可拦截委托
  @param attrs 具体逻辑  如：("default value"){ property, oldValue, newValue =>  true}
 */
public macro Vetoable(attrs: Tokens, input: Tokens): Tokens {
    let tokens = Tokens()
    let typeNode = getChildMessages("Delegate")
    if (typeNode.size < 1) {
        diagReport(DiagReportLevel.ERROR, input, "@Delegate required.", "Illegal expression")
        return input
    }
    let realType = Token(TokenKind.IDENTIFIER, typeNode[0].getString("realType"))
    let isOption = typeNode[0].getBool("isOption")

    let realDelegate = if (isOption) {
        quote(vetoable<?$(realType)>$(attrs))
    } else {
        quote(vetoable<$(realType)>$(attrs))
    }
    for (tk in input) {
        if (tk == PROP_DELEGATE_PLACEHOLER_TOKENS) {
            tokens.append(realDelegate)
        } else {
            tokens.append(tk)
        }
    }
    return tokens
}
