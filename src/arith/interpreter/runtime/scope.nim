type
   Scope* = ref object
      parent*: Scope
      

func initScope*(): Scope =
   result = new(Scope)
