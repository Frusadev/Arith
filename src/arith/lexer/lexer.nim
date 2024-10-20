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

      # Assignment
      ASSIGN

      # Keywords
      BEGIN
      END

      # Identifiers and values
      ID
      NUMBER

      # Miscellaneous
      SMCOL
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
      "BEGIN": initToken("BEGIN", BEGIN),
      "END": initToken("END", END),
   }.toTable()

   var value: string
   while lexer.currentChar.isAlphaAscii():
      value.add(lexer.currentChar)
      lexer.advance()

   if definedKeywords.hasKey(value):
      return definedKeywords[value]
   else:
      let token = initToken(value, ID)
      return token


proc getNextToken*(lexer: Lexer): Token =
   lexer.skipSpace()
   if lexer.position < lexer.input.len and lexer.currentChar != '\0':
      if lexer.currentChar.isDigit() or ((lexer.currentChar == '.') and lexer.peek().isDigit()):
         lexer.currentToken = lexer.number()
      elif lexer.currentChar.isAlphaAscii():
         lexer.currentToken = lexer.identifyKeyword()
      else: 
         lexer.currentToken = lexer.guessOperator()
   else:
      lexer.currentToken = initToken("\0", EOF)
   return lexer.currentToken
