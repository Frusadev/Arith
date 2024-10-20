import arith/lexer/lexer

type
   NodeType* = enum
      BINOP
      UNOP
      NUM

type
   ASTNode* = ref object of RootObj
      nodeType*: NodeType
      token*: Token
      left*: ASTNode
      right*: ASTNode

type
   UnaryOperatorNode* = ref object of ASTNode
      expr*: ASTNode

type
   Parser* = ref object
      lexer*: Lexer
      currentToken*: Token


proc initParser*(lexer: Lexer): Parser =
   result = new(Parser)
   result.lexer = lexer
   result.currentToken = lexer.getNextToken()


proc initASTNode*(nodeType: NodeType, token: Token, left: ASTNode = nil, right: ASTNode = nil, expr: ASTNode = nil): ASTNode =
   result = new(ASTNode)
   result.nodeType = nodeType
   result.token = token
   result.left = left
   result.right = right


proc initUnaryNode*(token: Token, expr: ASTNode): UnaryOperatorNode =
   result = new(UnaryOperatorNode)
   result.nodeType = UNOP
   result.token = token
   result.expr = expr


proc error*(parser: Parser) =
   raise newException(ValueError, "Invalid token")


proc eat*(parser: Parser, tokenType: TokenType) =
   if not (parser.currentToken.tokType == tokenType):
      parser.error()
   else:
      parser.currentToken = parser.lexer.getNextToken()

proc expr*(parser: Parser): ASTNode


proc factor*(parser: Parser): ASTNode =
   var node: ASTNode
   if parser.currentToken.tokType == NUMBER:
      let token = parser.currentToken
      parser.eat(NUMBER)
      node = initASTNode(NUM, token)
   elif parser.currentToken.tokType == LPAREN:
      parser.eat(LPAREN)
      node = parser.expr()
      parser.eat(RPAREN)
   elif parser.currentToken.tokType in [PLUS, MINUS]:
      let token = parser.currentToken
      if token.tokType == PLUS:
         parser.eat(PLUS)
         node = initUnaryNode(expr=parser.factor(), token=token)
      else:
         parser.eat(MINUS)
         node = initUnaryNode(expr=parser.factor(), token=token)
   return node


proc term*(parser: Parser): ASTNode =
   var node = parser.factor()
   while parser.currentToken.tokType in [MUL, DIV]:
      let token = parser.currentToken
      if token.tokType == MUL:
         parser.eat(MUL)
      else:
         parser.eat(DIV)
      node = initASTNode(BINOP, token, node, parser.factor())
   return node


proc expr*(parser: Parser): ASTNode =
   var node = parser.term()
   while parser.currentToken.tokType in [PLUS, MINUS]:
      let token = parser.currentToken
      if token.tokType == PLUS:
         parser.eat(PLUS)
      else:
         parser.eat(MINUS)
      node = initASTNode(BINOP, token, node, parser.term())
   return node
