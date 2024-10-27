import strutils
import tables


type
   TokenType* = enum
      # Operators
      PLUS
      MINUS
      MUL
      DIV

      # Parentheses
      LPAREN
      RPAREN

      #Braces
      LBRACE
      RBRACE

      # Assignment
      ASSIGN
      TYPE_ASSIGN

      # Keywords
      BEGIN
      END
      IMPORT
      IF
      OBJECT
      VAR
      FOR
      WHILE
      FUNCTION
      IN
      PUB
      PRIV
      CONSTRUCTOR
      

      # Identifiers and values
      IDENTIFER
      NUMBER
      STRING
      CHAR

      # Miscellaneous
      SMCOL
      COLON
      DOT
      EOF

type
   Token* = ref object
      tokType*: TokenType
      tokenValue*: string

type
   Lexer* = ref object
      input*: string
      currentToken*: Token
      position*: int
      currentChar*: char

proc initLexer*(input: string): Lexer =
   result = new(Lexer)
   result.input = input
   result.position = 0
   if input.len > 0:
      result.currentChar = input[0]


proc initToken*(value: string, tokenType: TokenType): Token =
   result = new(Token)
   result.tokenValue = value
   result.tokType = tokenType


proc advance*(lexer: Lexer, n: int = 1) =
   if lexer.position < lexer.input.len - n:
      lexer.position += n
      lexer.currentChar = lexer.input[lexer.position]
   else:
      lexer.currentChar = '\0'


proc peek*(lexer: Lexer): char =
   if lexer.position < lexer.input.len - 1:
      let newPos = lexer.position + 1
      result = lexer.input[newPos]
   else:
      return '\0'


proc error*(lexer: Lexer) =
   var
      position = lexer.position
      current = lexer.currentChar
   raise newException(ValueError, "Invalid character: " & current & " at position " & $(position + 1))

proc error(lexer: Lexer, complementaryMessage: string) =
   var
      position = lexer.position
      current = lexer.currentChar
   raise newException(ValueError, complementaryMessage & "\nInvalid character: " & current & "\nError happened at position " & $(position + 1))


proc number(lexer: Lexer): Token =
   var output: string
   while lexer.currentChar.isDigit() or (lexer.currentChar == '.'):
      if lexer.currentChar.isDigit():
         output.add(lexer.currentChar)
      else:
         if output.contains('.'):
            lexer.error()
         output.add(lexer.currentChar)
      lexer.advance()
   result = initToken(output, NUMBER)


proc skipSpace(lexer: Lexer) =
   while lexer.currentChar == ' ':
      lexer.advance()


proc guessOperator(lexer: Lexer): Token =
   if lexer.position < lexer.input.len:
      let fixedOperatorTokens: Table[char, Token] = {
         '+': initToken("+", PLUS),
         '-': initToken("-", MINUS),
         '*': initToken("*", MUL),
         '/': initToken("/", DIV),
         '(': initToken("(", LPAREN),
         ')': initToken(")", RPAREN),
      }.toTable()

      var token: Token

      if fixedOperatorTokens.hasKey(lexer.currentChar):
         token = fixedOperatorTokens[lexer.currentChar]
         lexer.advance()
      elif lexer.currentChar == ':':
         case lexer.peek()
         of '=':
            token = initToken(":=", ASSIGN)
            lexer.advance(2)
         else:
            lexer.error()
      return token


proc identifyKeyword(lexer: Lexer): Token =
   let definedKeywords: Table[string, Token] = {
      "begin": initToken("begin", BEGIN),
      "end": initToken("end", END),
      "pub": initToken("pub", PUB),
      "priv": initToken("priv", PRIV),
      "import": initToken("import", IMPORT),
      "if": initToken("if", IF),
      "object": initToken("object", OBJECT),
      "var": initToken("var", VAR),
      "for": initToken("for", FOR),
      "while": initToken("while", WHILE),
      "fn": initToken("fn", FUNCTION),
      "in": initToken("in", IN)
   }.toTable()

   var value: string
   while lexer.currentChar.isAlphaAscii():
      value.add(lexer.currentChar)
      lexer.advance()

   if definedKeywords.hasKey(value):
      return definedKeywords[value]
   else:
      let token = initToken(value, IDENTIFER)
      return token


proc matchString(lexer: Lexer): Token =
   var value: string
   let token = new(Token)
   if lexer.currentChar == '\'':
      lexer.advance()
      if lexer.peek() != '\'':
         lexer.error("Char can only be composed of 1 character")
      value = $lexer.currentChar
      token.tokType = CHAR
      token.tokenValue = value
   else:
      lexer.advance()
      while lexer.currentChar != '"' and lexer.currentChar != '\n':
         lexer.advance()
         value.add(lexer.currentChar)
      token.tokenValue = value
      token.tokType = STRING
      lexer.advance()
   return token


proc getNextToken*(lexer: Lexer): Token =
   lexer.skipSpace()
   if lexer.position < lexer.input.len and lexer.currentChar != '\0':
      let symbols: Table[char, Token] = {
         ';': initToken(";", SMCOL),
         '.': initToken(".", DOT),
         ':': initToken(":", COLON)
      }.toTable()

      if lexer.currentChar.isDigit() or ((lexer.currentChar == '.') and lexer.peek().isDigit()):
         lexer.currentToken = lexer.number()
      elif lexer.currentChar.isAlphaAscii():
         lexer.currentToken = lexer.identifyKeyword()
      elif symbols.hasKey(lexer.currentChar):
         lexer.currentToken = symbols[lexer.currentChar]
         lexer.advance()
      elif lexer.currentChar in ['\"', '\'']:
         lexer.currentToken = lexer.matchString()
      else: 
         lexer.currentToken = lexer.guessOperator()
   else:
      lexer.currentToken = initToken("\0", EOF)

   return lexer.currentToken
