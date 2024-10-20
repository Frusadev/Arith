import strutils
import arith/parser/parser
import arith/lexer/lexer

proc interpret*(node: ASTNode): float =
   if node != nil:
      case node.nodeType
      of BINOP:
         case node.token.tokType
         of PLUS:
            return interpret(node.left) + interpret(node.right)
         of MINUS:
            return interpret(node.left) - interpret(node.right)
         of MUL:
            return interpret(node.left) * interpret(node.right)
         of DIV:
            return interpret(node.left) / interpret(node.right)
         else:
            discard
      of NUM:
         return parseFloat(node.token.tokenValue)
      of UNOP:
         if node.token.tokType == PLUS:
            return +interpret(node.expr)
         else:
            return -interpret(node.expr)
