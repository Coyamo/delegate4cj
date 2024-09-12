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
 获取被注解的定义的真实定义和注解Tokens
 @return 注解Tokens数组和真实的定义的元组
 */
func getAnnotatedRealDecl(decl: MacroExpandDecl): (ArrayList<Tokens>, Decl) {
    let annotationTokens = ArrayList<Tokens>()
    annotationTokens.append(buildAnnoTokens(decl))
    var subDecl = decl
    while (let Some(macroInputDecl) <- subDecl.macroInputDecl as MacroExpandDecl) {
        annotationTokens.append(buildAnnoTokens(macroInputDecl))
        subDecl = macroInputDecl
    }
    return (annotationTokens, subDecl.macroInputDecl)
}

/**
 从宏展开定义中提取对应注解的Tokens
 */
func buildAnnoTokens(decl: MacroExpandDecl): Tokens {
    let tokens = Tokens()
    //第一个@是没有的
    tokens.append(Token(TokenKind.AT))
    tokens.append(decl.fullIdentifier)
    if (decl.macroAttrs.size != 0) {
        //[
        tokens.append(Token(TokenKind.LSQUARE))
        for (tk in decl.macroAttrs) {
            tokens.append(tk)
        }
        //]
        tokens.append(Token(TokenKind.RSQUARE))
    }
    return tokens
}

/**
 * 变量定义转属性定义
 */
func var2Prop(decl: VarDecl): PropDecl {
    let tokens = Tokens()
    for (tk in decl.toTokens()) {
        //可变变量添加mut
        if (tk.kind == TokenKind.VAR) {
            tokens.append(Token(TokenKind.MUT))
            tokens.append(Token(TokenKind.PROP))
        } else if (tk.kind == TokenKind.LET) {
            tokens.append(Token(TokenKind.PROP))
        } else if (tk.kind == TokenKind.NL) {
            //换行添加属性体
            tokens.append(Token(TokenKind.LCURL))
            tokens.append(Token(TokenKind.RCURL))
            tokens.append(tk)
        } else if (tk.kind == TokenKind.ASSIGN) {
            //如果变量有赋值 直接拼接属性体 并且结束拼接
            tokens.append(Token(TokenKind.LCURL))
            tokens.append(buildVarGetter(decl))
            tokens.append(Token(TokenKind.RCURL))
            tokens.append(Token(TokenKind.NL))
            break
        } else {
            tokens.append(tk)
        }
    }
    return PropDecl(tokens)
}

/**
 生成var变量类型的默认getter
 */
func buildVarGetter(decl: VarDecl): Tokens {
    let tokens = Tokens()
    try {
        //CallExpr RefExpr LitConstExpr
        let expr = decl.expr
        tokens.append(quote(get(){return $(expr)}))
    } catch (_: ASTException) {
    }
    return tokens
}

func hasModifier(decl: Decl, modifier: String) {
    for (m in decl.modifiers) {
        if (m.keyword.value == modifier) {
            return true
        }
    }
    return false
}

func hasKeyword(decl: Decl, keyword: String) {
    for (k in decl.keyword.toTokens()) {
        if (k.value == keyword) {
            return true
        }
    }
    return false
}

func isLet(decl: VarDecl) {
    return hasKeyword(decl, 'let')
}

func isMut(decl: PropDecl) {
    return hasModifier(decl, 'mut')
}

func isStatic(decl: PropDecl) {
    return hasModifier(decl, 'static')
}

func getRealType(decl: PropDecl): TypeNode {
    let declType = try {
        decl.declType
    } catch (e: ASTException) {
        diagReport(DiagReportLevel.ERROR, decl.toTokens(), "Undeclared type node.", "Unkonwn type")
        throw Exception("Undeclared type node.")
    }

    let tokens = decl.declType.toTokens()
    if (let Some(declType) <- declType as RefType) {
        if (declType.identifier.value == "Option") {
            return declType.typeArguments[0]
        }
    }
    if (let Some(declType) <- declType as PrefixType) {
        return declType.baseType
    }
    return declType
}

func isOptionType(decl: PropDecl): Bool {
    let declType = try {
        decl.declType
    } catch (e: ASTException) {
        diagReport(DiagReportLevel.ERROR, decl.toTokens(), "Undeclared type node.", "Unkonwn type")
        throw Exception("Undeclared type node.")
    }
    let tokens = decl.declType.toTokens()
    if (let Some(declType) <- declType as RefType) {
        if (declType.identifier.value == "Option") {
            return true
        }
    }
    if (let Some(declType) <- declType as PrefixType) {
        return declType.prefixOps[0].kind == TokenKind.QUEST
    }
    return false
}

func genGetterClosure(decl: PropDecl): Tokens {
    return try {
        let block = decl.getter.block
        let tokens = Tokens()
        tokens.append(block.lBrace)
        tokens.append(quote(=>))
        for (node in block.nodes) {
            tokens.append(node)
        }
        tokens.append(block.rBrace)
        tokens
    } catch (_: ASTException | ParseASTException) {
        quote(None)
    }
}
/**
  返回使用(?Any)->Unit闭包包裹一次的setter
  var setter:(?Any)->Unit = { v: ?Any =>
        let param = (v as String).getOrThrow()
        { aa: String => xxx
        }(param)
    }
 */
func genSetterClosure(decl: PropDecl, realType: TypeNode, isOption: Bool, mutable: Bool): Tokens {
    if (!mutable) {
        return quote(None)
    }
    return try {
        let block = decl.setter.block
        let identifier = decl.setter.funcParams[0].identifier
        let typeInfo = Tokens()
        if (isOption) {
            typeInfo.append(Token(TokenKind.QUEST))
        }
        typeInfo.append(realType)

        let tokens = Tokens()
        tokens.append(Token(TokenKind.LCURL))
        tokens.append(quote(v: ?Any =>))
        let delegateVar = Token(TokenKind.IDENTIFIER, "_" + identifier.value + "DelegateSetter")
        tokens.append(Token(TokenKind.NL))
        tokens.append(quote(let $(delegateVar) = (v.getOrThrow() as $(typeInfo)).getOrThrow();))
        tokens.append(Token(TokenKind.NL))
        tokens.append(Token(TokenKind.LCURL))
        tokens.append(quote($(identifier): $(typeInfo) =>))
        for (node in block.nodes) {
            tokens.append(node)
            tokens.append(Token(TokenKind.NL))
        }
        tokens.append(Token(TokenKind.RCURL))
        tokens.append(Token(TokenKind.LPAREN))

        tokens.append(delegateVar)
        tokens.append(Token(TokenKind.RPAREN))

        tokens.append(Token(TokenKind.RCURL))
        tokens
    } catch (_: ASTException | ParseASTException) {
        quote(None)
    }
}
