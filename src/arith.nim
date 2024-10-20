import arith/interpreter/interpreter

when isMainModule:
   while true:
      write(stdout, "> ")
      let input = readLine(stdin)
      if input.len() > 0:
         let 
            lexer = initLexer(input)
            parser = initParser(lexer)
         echo interpret(parser.expr())
