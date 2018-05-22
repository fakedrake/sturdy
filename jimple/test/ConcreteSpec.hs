module ConcreteSpec where

import Concrete
import Syntax
import Data.Concrete.Error
import Control.Arrow

import qualified Data.Map as Map

import Test.Hspec

import Classes.Object
import Classes.Throwable
import Classes.IllegalArgumentException
import Classes.ArrayIndexOutOfBoundsException

import Classes.ArrayFieldExample
import Classes.FactorialExample
import Classes.PersonExample
import Classes.SingleMethodExample
import Classes.TryCatchExample

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "Literals" $ do
    it "LocalName lookup" $ do
      let expr = Local "x"
      let nv = [("x", 1)]
      let st = [(1, VInt 2)]
      evalConcrete nv st expr `shouldBe` Success (VInt 2)
    it "Integer literals" $ do
      let expr = IntConstant 7
      evalConcrete env store expr `shouldBe` Success (VInt 7)
    it "Float literals" $ do
      let expr = FloatConstant 2.5
      evalConcrete env store expr `shouldBe` Success (VFloat 2.5)
    it "String literals" $ do
      let expr = StringConstant "Hello World"
      evalConcrete env store expr `shouldBe` Success (VString "Hello World")
    it "Class literals" $ do
      let expr = ClassConstant "java.lang.Object"
      evalConcrete env store expr `shouldBe` Success (VClass "java.lang.Object")
    it "Null literals" $ do
      let expr = NullConstant
      evalConcrete env store expr `shouldBe` Success VNull

  describe "Simple Expressions" $ do
    it "-3" $ do
      let expr = UnopExpr Neg (IntConstant 3)
      evalConcrete env store expr `shouldBe` Success (VInt (-3))
    it "lengthof [1, 2, 3]" $ do
      let expr = UnopExpr Lengthof (Local "x")
      let nv = [("x", 1)]
      let st = [(1, VRef 2),
                (2, VArray [VInt 1, VInt 2, VInt 3])]
      evalConcrete nv st expr `shouldBe` Success (VInt 3)
    it "8 + 2" $ do
      let expr = BinopExpr (IntConstant 8) Plus (IntConstant 2)
      evalConcrete env store expr `shouldBe` Success (VInt 10)
    it "8 / 0" $ do
      let expr = BinopExpr (IntConstant 8) Div (IntConstant 0)
      evalConcrete env store expr `shouldBe` Fail (VString "Cannot divide by zero")
    it "3 < 3.5" $ do
      let expr = BinopExpr (IntConstant 3) Cmplt (FloatConstant 3.5)
      evalConcrete env store expr `shouldBe` Success (VBool True)
    it "3 != 'three'" $ do
      let expr = BinopExpr (IntConstant 3) Cmpne (StringConstant "three")
      evalConcrete env store expr `shouldBe` Success (VBool True)
    it "3 % 2.5" $ do
      let expr = BinopExpr (IntConstant 3) Mod (FloatConstant 2.5)
      evalConcrete env store expr `shouldBe` Success (VFloat 0.5)
    it "new boolean" $ do
      let expr = NewExpr TBoolean
      evalConcrete env store expr `shouldBe` Success (VInt 0)
    it "[1, 2, 3][2]" $ do
      let expr = ArrayRef "xs" (IntConstant 2)
      let nv = [("xs", 1)]
      let st = [(1, VRef 2),
                (2, VArray [VInt 1, VInt 2, VInt 3])]
      evalConcrete nv st expr `shouldBe` Success (VInt 3)
    it "newmultiarray (float) [3][]" $ do
      let expr = NewMultiArrayExpr TFloat [IntConstant 3, IntConstant 2]
      evalConcrete env store expr `shouldBe` Success (VArray [VArray [VFloat 0.0, VFloat 0.0],
                                                 VArray [VFloat 0.0, VFloat 0.0],
                                                 VArray [VFloat 0.0, VFloat 0.0]])

  describe "Simple Statements" $ do
    it "i0 = 2 + 3; return i0;" $ do
      let nv = [("i0", 1)]
      let st = [(1, defaultValue TInt)]
      let stmts = [Assign (VLocal "i0") (BinopExpr (IntConstant 2) Plus (IntConstant 3)),
                   Return (Just (Local "i0"))]
      runStatementsConcrete nv st stmts `shouldBe` Success (Just (VInt 5))
    it "assign non-declared variable" $ do
      let stmts = [Assign (VLocal "s") (IntConstant 2)]
      runStatementsConcrete env store stmts `shouldBe` Fail (VString "Variable \"s\" not bounded")
    it "s = 2; xs = newarray (int)[s]; y = lengthof xs; return xs;" $ do
      let nv = [("s", 0),
                ("xs", 1),
                ("y", 2)]
      let st = [(0, defaultValue TInt),
                (1, defaultValue (TArray TInt)),
                (2, defaultValue TInt)]
      let stmts = [Assign (VLocal "s") (IntConstant 2),
                   Assign (VLocal "xs") (NewArrayExpr TInt (Local "s")),
                   Assign (VLocal "y") (UnopExpr Lengthof (Local "xs")),
                   Return (Just (Local "y"))]
      runStatementsConcrete nv st stmts `shouldBe` Success (Just (VInt 2))
    it "if 2 <= 3 goto l2; l1: return 1; l2: return 0;" $ do
      let stmts = [If (BinopExpr (IntConstant 2) Cmple (IntConstant 3)) "l2",
                   Label "l1",
                   Return (Just (IntConstant 1)),
                   Label "l2",
                   Return (Just (IntConstant 0))]
      runStatementsConcrete env store stmts `shouldBe` Success (Just (VInt 0))
    it "lookupswitch(4) { case 0: goto l1; case 4: goto l2; default: goto l3;}; l1: return 1; l2: return 2; l3: return 3;" $ do
      let stmts = [Lookupswitch (IntConstant 4) [(CLConstant 0, "l1"),
                                                 (CLConstant 4, "l2"),
                                                 (CLDefault, "l3")],
                   Label "l1",
                   Return (Just (IntConstant 1)),
                   Label "l2",
                   Return (Just (IntConstant 2)),
                   Label "l3",
                   Return (Just (IntConstant 3))]
      runStatementsConcrete env store stmts `shouldBe` Success (Just (VInt 2))
    it "lookupswitch(2) { case 0: goto l1; case 4: goto l2; default: goto l3;}; l1: return 1; l2: return 2; l3: return 3;" $ do
      let stmts = [Lookupswitch (IntConstant 2) [(CLConstant 0, "l1"),
                                          (CLConstant 4, "l2"),
                                          (CLDefault, "l3")],
                   Label "l1",
                   Return (Just (IntConstant 1)),
                   Label "l2",
                   Return (Just (IntConstant 2)),
                   Label "l3",
                   Return (Just (IntConstant 3))]
      runStatementsConcrete env store stmts `shouldBe` Success (Just (VInt 3))
    it "f0 := @parameter0: float; f1 = f0 * 2; return f1; (@parameter0 = 2.0)" $ do
      let nv = [("@parameter0", 0),
                ("f0",          1),
                ("f1",          2)]
      let st = [(0, VFloat 2.0),
                (1, defaultValue TFloat),
                (2, defaultValue TFloat)]
      let stmts = [Identity "f0" (ParameterRef 0) TFloat,
                   Assign (VLocal "f1") (BinopExpr (Local "f0") Mult (IntConstant 2)),
                   Return (Just (Local "f1"))]
      runStatementsConcrete nv st stmts `shouldBe` Success (Just (VFloat 4.0))

  describe "Complete program" $ do
    it "10! = 3628800" $ do
      let files = baseCompilationUnits ++ [factorialExampleFile]
      runProgramConcrete files factorialExampleFile [IntConstant 10] `shouldBe` Success (Just (VInt 3628800))
    it "s = new SingleMethodExample; s.x = 2; return s.x" $ do
      let files = baseCompilationUnits ++ [singleMethodExampleFile]
      runProgramConcrete files singleMethodExampleFile [] `shouldBe` Success (Just (VInt 2))
    it "(-10)! throws IllegalArgumentException" $ do
      let files = baseCompilationUnits ++ [factorialExampleFile]
      runProgramConcrete files factorialExampleFile [IntConstant (-10)] `shouldBe` Fail (VObject "java.lang.IllegalArgumentException" (Map.fromList [(throwableMessageSignature, VString "Negative value for argument n")]))
    it "5 -> [5, 5, 5, 5]" $ do
      let files = baseCompilationUnits ++ [arrayFieldExampleFile]
      runProgramConcrete files arrayFieldExampleFile [IntConstant 5] `shouldBe` Success (Just (VArray [VInt 5, VInt 5, VInt 5, VInt 5]))
    it "(new Person(10)).yearsToLive() = 90" $ do
      let files = baseCompilationUnits ++ [personExampleFile]
      runProgramConcrete files personExampleFile [] `shouldBe` Success (Just (VInt 90))
    it "try { throw e } catch (e) { throw e' }" $ do
      let files = baseCompilationUnits ++ [tryCatchExampleFile]
      runProgramConcrete files tryCatchExampleFile [] `shouldBe` Fail (VObject "java.lang.ArrayIndexOutOfBoundsException" (Map.fromList [(throwableMessageSignature, VString "b")]))

  where
    baseCompilationUnits = [objectFile,
                            throwableFile,
                            illegalArgumentExceptionFile,
                            arrayIndexOutOfBoundsExceptionFile]
    env = []
    store = []

    testMethodBody stmts = MFull { declarations = []
                                 , statements = stmts
                                 , catchClauses = []
                                 }

    testMethod stmts = Method { methodModifiers = [Public, Static]
                              , returnType = TVoid
                              , methodName = "test"
                              , parameters = []
                              , throws = []
                              , methodBody = testMethodBody stmts
                              }

    testCompilationUnits stmts = [CompilationUnit { fileModifiers = [Public]
                                                  , fileType = FTClass
                                                  , fileName = "Test"
                                                  , extends = Just "java.lang.Object"
                                                  , implements = []
                                                  , fileBody = [MethodMember (testMethod stmts)]
                                                  }] ++ baseCompilationUnits

    evalConcrete env' store' = runInterp (eval >>> unbox) (testCompilationUnits []) env' store' (Just (testMethod []))

    runStatementsConcrete env' store' stmts =
      runInterp (runStatements >>> unboxMaybe) (testCompilationUnits stmts) env' store' (Just (testMethod stmts)) (stmts, 0)

    runProgramConcrete compilationUnits mainUnit args =
      runInterp (runProgram >>> unboxMaybe) compilationUnits [] [] Nothing (mainUnit, args)
