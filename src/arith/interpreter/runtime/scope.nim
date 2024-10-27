import arith/interpreter/runtime/variable

type
   Scope* = ref object of RootObj
      parent*: Scope

type
   ObjectDeclarationScope* = ref object of Scope
      objectName*: string

type
   FunctionScope* = ref object of Scope
      variables: seq

func initScope*(): Scope =
   result = new(Scope)
