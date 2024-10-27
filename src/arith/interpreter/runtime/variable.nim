import strutils
import strformat
import tables
import arith/interpreter/runtime/scope

type
   String* = ref object
      value: string

type
   Char* = ref object
      value: char

type
   Number* = ref object
      value: float

type
   Bool* = ref object
      value: bool

type
   Object* = ref object
      scope: Table[string, ObjectDeclarationScope]

type
   Variable*[T] = ref object of RootObj
      name: string      
      value: T


proc initObject(name: string): Object =
   discard


proc initBool(value: string): Bool =
   assert value == "true" or (value == "false")
   result = new(Bool)
   result.value = parseBool(value)


proc initNumber(value: string): Number =
   result = new(Number)
   result.value = parseFloat(value)


proc initChar(value: string): Char =
   assert value.len == 1
   result = new(Char)
   result.value = value[0]


proc initString(value: string): String =
   result = new(String)
   result.value = value


proc initVar*[T: String | Char | Number | Bool | Object](name: string, value: string): Variable[T] =
   result = new(Variable)
   result.name = name
   if T of String:
      result.value = initString(value)
   elif T of Char:
      result.value = initChar(value)
   elif T of Bool:
      result.value = initBool(value)
   elif T of Number:
      result.value = initNumber(value)
