import arith/interpreter/runtime/runtimeTypes

func initScope*(): Scope =
   result = new(Scope)
