import arith/lexer/lexer

type
   NodeType* = enum
      BINOP # Binary operator
      UNOP # Unary operator
      NUM
      COMPSTMT # Compound statement
      ASSIGNSTMT # Assignment statement
      VAR
      VOIDSTMT


type
   ASTNode* = ref object of RootObj
      nodeType*: NodeType
      token*: Token
      left*: ASTNode
      right*: ASTNode

type
   BinaryOperatorNode* = ref object of ASTNode

type
   UnaryOperatorNode* = ref object of ASTNode
      expr*: ASTNode

type
   CompoundStmtNode* = ref object of ASTNode
      children*: seq[ASTNode]

type
   VoidNode = ref object of ASTNode

type
   AssignmentStmtNode* = ref object of ASTNode
      value*: ASTNode

type
   VarNode* = ref object of ASTNode
      value: string

type
   Parser* = ref object
      lexer*: Lexer
      currentToken*: Token


proc initParser*(lexer: Lexer): Parser =
   result = new(Parser)
   result.lexer = lexer
   result.currentToken = lexer.getNextToken()


func initASTNode*(nodeType: NodeType, token: Token, left: ASTNode = nil, right: ASTNode = nil): ASTNode =
   result = new(ASTNode)
   result.nodeType = nodeType
   result.token = token
   result.left = left
   result.right = right


func initOperatorNode*(token: Token, left: ASTNode, right: ASTNode): BinaryOperatorNode =
   result = new(BinaryOperatorNode)
   result.nodeType = BINOP
   result.token = token
   result.left = left
   result.right = right


func initCompoundStmtNode*(children: seq[ASTNode]): CompoundStmtNode =
   result = new(CompoundStmtNode)
   result.nodeType = COMPSTMT
   result.children = children


func initVarNode*(token: Token): VarNode =
   result = new(VarNode)
   result.nodeType = VAR
   result.token = token
   result.value = token.tokenValue


func initUnaryNode*(token: Token, expr: ASTNode): UnaryOperatorNode =
   result = new(UnaryOperatorNode)
   result.nodeType = UNOP
   result.token = token
   result.expr = expr


func initVoidNode*(): VoidNode =
   result = new(VoidNode)
   result.nodeType = VOIDSTMT


func initAssignmentNode*(token: Token, value: ASTNode): AssignmentStmtNode =
   result = new(AssignmentStmtNode)
   result.nodeType = ASSIGNSTMT
   result.token = token
   result.value = value

proc error*(parser: Parser) =
   raise newException(ValueError, "Invalid token")


proc eat*(parser: Parser, tokenType: TokenType) =
   if not (parser.currentToken.tokType == tokenType):
      parser.error()
   else:
      parser.currentToken = parser.lexer.getNextToken()


proc expr(parser: Parser): ASTNode
proc compoundStmt(parser: Parser): CompoundStmtNode


proc voidStatement(parser: Parser): VoidNode =
   result = initVoidNode()


proc assignmentStmt(parser: Parser): AssignmentStmtNode =
   let varToken = parser.currentToken
   parser.eat(IDENTIFER)
   parser.eat(ASSIGN)
   let assignmentValue = parser.expr()
   return initAssignmentNode(varToken, assignmentValue)


proc statement(parser: Parser): ASTNode =
   var node: ASTNode
   case parser.currentToken.tokType
   of BEGIN:
      node = parser.compoundStmt()
   of IDENTIFER:
      node = parser.assignmentStmt()
   else:
      node = parser.voidStatement()
   return node


proc statementList(parser: Parser): seq[ASTNode] =
   # stmt | stmt SMCOL stmtlist
   let stmt = parser.statement()
   var nodes: seq[ASTNode] = @[]
   nodes.add(stmt)
   
   while parser.currentToken.tokType == SMCOL:
      parser.eat(SMCOL)
      nodes.add(parser.statement())
   return nodes


proc compoundStmt(parser: Parser): CompoundStmtNode =
   var node: CompoundStmtNode = initCompoundStmtNode(children= @[])
   parser.eat(BEGIN)
   node.children = parser.statementList()
   parser.eat(END)
   return node


proc program(parser: Parser): ASTNode =
   var node: CompoundStmtNode
   node = parser.compoundStmt()
   parser.eat(DOT)
   return node


proc factor(parser: Parser): ASTNode =
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
   elif parser.currentToken.tokType == IDENTIFER:
      node = initVarNode(parser.currentToken)
      parser.eat(IDENTIFER)

   return node


proc term(parser: Parser): ASTNode =
   var node = parser.factor()
   while parser.currentToken.tokType in [MUL, DIV]:
      let token = parser.currentToken
      if token.tokType == MUL:
         parser.eat(MUL)
      else:
         parser.eat(DIV)
      node = initASTNode(BINOP, token, node, parser.factor())
   return node


proc expr(parser: Parser): ASTNode =
   var node = parser.term()
   while parser.currentToken.tokType in [PLUS, MINUS]:
      let token = parser.currentToken
      if token.tokType == PLUS:
         parser.eat(PLUS)
      else:
         parser.eat(MINUS)
      node = initASTNode(BINOP, token, node, parser.term())
   return node

proc parse*(parser: Parser): ASTNode =
   return parser.program()
