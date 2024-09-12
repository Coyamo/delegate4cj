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
public import std.reflect.TypeInfo
public import delegate.property.*

/**
 被委托对象占位符，用于使用扩展功能的宏替换实际被委托的对象
 */
let PROP_DELEGATE_PLACEHOLER_TOKENS = Token(TokenKind.IDENTIFIER, "_PROP_DELEGATE_PLACEHOLER_TOKENS_")

/**
 生成委托具体展开实现的Tokens
 @param attrs 被委托的对象
 */
private func genDelegateTokens(attrs: Tokens, input: Tokens): Tokens {
    let decl = guessDecl(input)
    return match (decl) {
        //变量
        case decl: VarDecl =>
            let varDecl = var2Prop(decl)
            delegateProp(attrs, varDecl)
        //属性
        case decl: PropDecl => delegateProp(attrs, decl)

        //带注解的类型
        case decl: MacroExpandDecl =>
            let (annotations, realDecl) = getAnnotatedRealDecl(decl)
            let delegate = match (realDecl) {
                case realDecl: VarDecl =>
                    let realVarDecl = var2Prop(realDecl)
                    delegateProp(attrs, annotations, realVarDecl)
                case realDecl: PropDecl => delegateProp(attrs, annotations, realDecl)
                case _ =>
                    diagReport(DiagReportLevel.ERROR, input, "Unsupported @Delegate usage.", "Illegal expression")
                    realDecl.toTokens()
            }
            delegate
        case _ =>
            diagReport(DiagReportLevel.ERROR, input, "Unsupported @Delegate usage.", "Illegal expression")
            input
    }
}

/**
  如果解析失败，尝试补全decl
*/
private func guessDecl(input: Tokens): Decl {
    let string = input.toString()
    return try{
        let newTokens = input.copy()
        // 猜测是属性定义 
        if(string.contains("prop ") && !string.contains("{") && !string.contains("}")){
            //不带{}的情况
            newTokens.append(quote({}))
        }
        parseDecl(newTokens)
    } catch (e:Exception) {
        parseDecl(input)
    }    
}

private const BY_KEY = " by "

private func maybeDelegateDecl(input: Tokens):Bool{
    let tokens = input.toString()

    let maybeVar = tokens.contains("var ") || tokens.contains("let ")
    let maybeProp = tokens.contains("prop ") 
    
    if(!maybeProp && !maybeVar){
        return false
    }

    return tokens.contains(BY_KEY) 
}

/**
  解析自定义语法委托定义
*/
private func parseDelegateDecl(input: Tokens):(Tokens,Tokens){
    let tokens = input.toString()
    if(let Some(index) <- tokens.lastIndexOf(BY_KEY)){
        let decl = cangjieLex(tokens[..index], true)
        let delegate = cangjieLex(tokens[index + BY_KEY.size..], true)
        return (delegate, decl)
    }
    throw ParseASTException("parsing delegate decl error.")
}

extend Tokens {
    public func copy() : Tokens {
        let copy = Tokens()
        copy.append(this)
        return copy
    }
}

/**
  委托标记，需要配合其他注解实现委托功能
 */
public macro Delegate(input: Tokens): Tokens {
    let (attrs, tokens)  = if(maybeDelegateDecl(input)){
        parseDelegateDecl(input)
    } else {
        (PROP_DELEGATE_PLACEHOLER_TOKENS.toTokens(), input)
    }
    return genDelegateTokens(attrs, tokens)
}

/**
  委托
  @param attrs 被委托的对象
 */
public macro Delegate(attrs: Tokens, input: Tokens): Tokens {
    return genDelegateTokens(attrs, input)
}

func buildDelegateProperty(name: Token, realType: TypeNode, isStatic: Bool, isOption: Bool, mutable: Bool,
    getter: Tokens, setter: Tokens): Tokens {
    let tokens = Tokens()
    let commaToken = Token(TokenKind.COMMA)
    tokens.append(Token(TokenKind.IDENTIFIER, "DelegateProperty"))
    tokens.append(Token(TokenKind.LPAREN))
    tokens.append(Token(TokenKind.NL))
    tokens.append(name)
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(quote(TypeInfo.of<$(realType)>()))
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(Token(TokenKind.BOOL_LITERAL, isStatic.toString()))
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(Token(TokenKind.BOOL_LITERAL, isOption.toString()))
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(Token(TokenKind.BOOL_LITERAL, mutable.toString()))
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(getter)
    tokens.append(commaToken)
    tokens.append(Token(TokenKind.NL))
    tokens.append(setter)
    tokens.append(Token(TokenKind.NL))
    tokens.append(Token(TokenKind.RPAREN))
    return tokens
}

private func delegateProp(attrs: Tokens, decl: PropDecl): Tokens {
    return delegateProp(attrs, ArrayList<Tokens>(), decl)
}

/**
 * 委托属性字段
 */
private func delegateProp(attrs: Tokens, annotations: ArrayList<Tokens>, decl: PropDecl): Tokens {
    //被委托的对象的变量字段，如果不提取出来可能会导致被委托的对象多次初始化、不一致
    let delegateProperty = Token(TokenKind.IDENTIFIER, "_" + decl.identifier.value + "Delegate")
    let propNameToken = Token(TokenKind.STRING_LITERAL, decl.identifier.value)
    let tokens = Tokens()
    let realType = getRealType(decl)
    let isStatic = isStatic(decl)
    let isOption = isOptionType(decl)
    let mutable = isMut(decl)
    setItem("realType", realType.toTokens().toString())
    setItem("isOption", isOption)
    let property = buildDelegateProperty(
        propNameToken,
        realType,
        isStatic,
        isOption,
        mutable,
        genGetterClosure(decl),
        genSetterClosure(decl, realType, isOption, mutable)
    )
    if (isStatic) {
        tokens.append(quote(private static let $(delegateProperty) = ($(attrs), $(property))))
    } else {
        tokens.append(quote(private let $(delegateProperty) = ($(attrs), $(property))))
    }

    tokens.append(Token(TokenKind.NL))

    for (tks in annotations) {
        tokens.append(tks)
        tokens.append(Token(TokenKind.NL))
    }
    //拼接原有的token直到 '{'
    for (token in decl.toTokens()) {
        if (token == decl.lBrace) {
            break
        }
        tokens.append(token)
    }
    //插入属性体
    tokens.append(Token(TokenKind.LCURL))
    tokens.append(Token(TokenKind.NL))
    tokens.append(quote(get()))
    tokens.append(Token(TokenKind.LCURL))
    tokens.append(Token(TokenKind.LPAREN))
    tokens.append(quote($(delegateProperty)[0]($(delegateProperty)[1])))
    // 转换是为了解决map准确返回类型
    if (isOption) {
        // 如果是Option类型这里也把他转换到Option类型 保持一致
        tokens.append(quote(as ?$(realType) ))
    } else {
        tokens.append(quote(as $(realType) ))
    }
    tokens.append(Token(TokenKind.RPAREN))
    //如果是Option类型这里获取到的还是Option类型
    //否则是获取到真实的值
    tokens.append(quote(.getOrThrow()))

    tokens.append(Token(TokenKind.RCURL))
    //可变属性拼接setter
    if (mutable) {
        tokens.append(Token(TokenKind.NL))
        tokens.append(quote(set(v) { $(delegateProperty)[0](v, $(delegateProperty)[1]) }))
    }
    tokens.append(Token(TokenKind.NL))
    tokens.append(Token(TokenKind.RCURL))
    tokens.append(Token(TokenKind.NL))
    return tokens
}
