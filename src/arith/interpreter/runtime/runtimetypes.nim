import tables

type
   PrimitiveType* = ref object
      name*: string
      value*: string

type
   Variable*[T] = ref object of RootObj
      name*: string      
      value*: T

type
   Scope* = ref object of RootObj
      parent*: Scope

type
   ObjectDeclarationScope* = ref object of Scope
      objectName*: string

type
   Object* = ref object
      scope*: Table[string, ObjectDeclarationScope]

type
   FunctionScope* = ref object of Scope
      variables: seq[Variable[PrimitiveType | Object]]
