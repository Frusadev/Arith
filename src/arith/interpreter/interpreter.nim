import strutils
import arith/parser/parser
import arith/lexer/lexer
import arith/interpreter/runtime/scope

type
   Interpreter = ref object
      currentScope: Scope





proc interpret*(interpreter: Interpreter, node: ASTNode): float =
   if node != nil:
      case node.nodeType
      of COMPSTMT:
         # create scope
         let scope = initScope()
         scope.parent = interpreter.currentScope
      of ASSIGNSTMT:
         discard
      of VOIDSTMT:
         discard
      of VAR:
         discard
      of BINOP:
         case node.token.tokType
         of PLUS:
            return interpreter.interpret(node.left) + interpreter.interpret(node.right)
         of MINUS:
            return interpreter.interpret(node.left) - interpreter.interpret(node.right)
         of MUL:
            return interpreter.interpret(node.left) * interpreter.interpret(node.right)
         of DIV:
            return interpreter.interpret(node.left) / interpreter.interpret(node.right)
         else:
            discard
      of NUM:
         return parseFloat(node.token.tokenValue)
      of UNOP:
         let node = UnaryOperatorNode(node)
         if node.token.tokType == PLUS:
            return +interpreter.interpret(node.expr)
         else:
            return -interpreter.interpret(node.expr)
