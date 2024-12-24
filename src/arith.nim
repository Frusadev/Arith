import arith/interpreter/interpreter
import arith/lexer/lexer
import arith/parser/parser

when isMainModule:
   while true:
      write(stdout, "> ")
      let input = readLine(stdin)
      if input.len() > 0:
         let 
            lexer = initLexer(input)
            parser = initParser(lexer)
            interpreter: Interpreter = new (Interpreter)
         echo interpreter.interpret(parser.expr())
