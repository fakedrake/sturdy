Specification(
  [ Signature(
      [ Constructors(
          [ OpDecl(
              "Num"
            , FunType([ConstType(SortNoArgs("Int"))], ConstType(SortNoArgs("Exp")))
            )
          , OpDecl(
              "Max"
            , FunType(
                [ConstType(SortNoArgs("Exp")), ConstType(SortNoArgs("Exp"))]
              , ConstType(SortNoArgs("Exp"))
              )
            )
          , OpDecl(
              "Min"
            , FunType(
                [ConstType(SortNoArgs("Exp")), ConstType(SortNoArgs("Exp"))]
              , ConstType(SortNoArgs("Exp"))
              )
            )
          , OpDecl("True", ConstType(SortNoArgs("BExp")))
          , OpDecl("False", ConstType(SortNoArgs("BExp")))
          , OpDecl(
              "And"
            , FunType(
                [ConstType(SortNoArgs("BExp")), ConstType(SortNoArgs("BExp"))]
              , ConstType(SortNoArgs("BExp"))
              )
            )
          , OpDecl(
              "Or"
            , FunType(
                [ConstType(SortNoArgs("BExp")), ConstType(SortNoArgs("BExp"))]
              , ConstType(SortNoArgs("BExp"))
              )
            )
          , OpDecl("Nil", ConstType(Sort("List", [SortVar("a")])))
          , OpDecl(
              "Cons"
            , FunType(
                [ConstType(SortVar("a")), ConstType(Sort("List", [SortVar("a")]))]
              , ConstType(Sort("List", [SortVar("a")]))
              )
            )
          , OpDeclInj(ConstType(SortTuple([])))
          , OpDeclInj(
              FunType(
                [ConstType(SortVar("a"))]
              , ConstType(SortTuple([SortVar("a")]))
              )
            )
          , OpDeclInj(
              FunType(
                [ConstType(SortVar("a")), ConstType(SortVar("b"))]
              , ConstType(SortTuple([SortVar("a"), SortVar("b")]))
              )
            )
          , OpDeclInj(
              FunType(
                [ConstType(SortVar("a")), ConstType(SortVar("b")), ConstType(SortVar("c"))]
              , ConstType(
                  SortTuple([SortVar("a"), SortVar("b"), SortVar("c")])
                )
              )
            )
          ]
        )
      ]
    )
  , Strategies(
      [ SDefT(
          "trans_0_0"
        , []
        , []
        , GuardedLChoice(
            Seq(
              Match(Anno(Op("True", []), Wld()))
            , Build(
                Anno(
                  Op(
                    "Num"
                  , [Anno(Int("1"), Op("Nil", []))]
                  )
                , Op("Nil", [])
                )
              )
            )
          , Id()
          , GuardedLChoice(
              Seq(
                Match(Anno(Op("False", []), Wld()))
              , Build(
                  Anno(
                    Op(
                      "Num"
                    , [Anno(Int("0"), Op("Nil", []))]
                    )
                  , Op("Nil", [])
                  )
                )
              )
            , Id()
            , GuardedLChoice(
                Scope(
                  ["b_1", "c_1"]
                , Seq(
                    Match(
                      Anno(
                        Op("And", [Var("b_1"), Var("c_1")])
                      , Wld()
                      )
                    )
                  , Build(
                      Anno(
                        Op("Min", [Var("b_1"), Var("c_1")])
                      , Op("Nil", [])
                      )
                    )
                  )
                )
              , Id()
              , Scope(
                  ["z_0", "a_1"]
                , Seq(
                    Match(
                      Anno(
                        Op("Or", [Var("z_0"), Var("a_1")])
                      , Wld()
                      )
                    )
                  , Build(
                      Anno(
                        Op("Max", [Var("z_0"), Var("a_1")])
                      , Op("Nil", [])
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "topdown_1_0"
        , [ VarDec(
              "d_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Seq(
            CallT(SVar("d_1"), [], [])
          , All(
              CallT(
                SVar("topdown_1_0")
              , [CallT(SVar("d_1"), [], [])]
              , []
              )
            )
          )
        )
      , SDefT(
          "bottomup_1_0"
        , [ VarDec(
              "e_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Seq(
            All(
              CallT(
                SVar("bottomup_1_0")
              , [CallT(SVar("e_1"), [], [])]
              , []
              )
            )
          , CallT(SVar("e_1"), [], [])
          )
        )
      , SDefT(
          "trans__topdown_0_0"
        , []
        , []
        , CallT(
            SVar("topdown_1_0")
          , [CallT(SVar("trans_0_0"), [], [])]
          , []
          )
        )
      , SDefT(
          "trans__bottomup_0_0"
        , []
        , []
        , CallT(
            SVar("bottomup_1_0")
          , [CallT(SVar("trans_0_0"), [], [])]
          , []
          )
        )
      , SDefT(
          "Anno__Cong_____2_0"
        , [ VarDec(
              "j_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "k_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["f_1", "g_1", "h_1", "i_1"]
          , Seq(
              Match(Anno(Var("f_1"), Var("g_1")))
            , Seq(
                Build(Var("f_1"))
              , Seq(
                  CallT(SVar("j_1"), [], [])
                , Seq(
                    Match(Var("h_1"))
                  , Seq(
                      Build(Var("g_1"))
                    , Seq(
                        CallT(SVar("k_1"), [], [])
                      , Seq(
                          Match(Var("i_1"))
                        , Build(Anno(Var("h_1"), Var("i_1")))
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "Num_1_0"
        , [ VarDec(
              "l_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["e_2", "d_2", "f_2"]
          , Seq(
              Match(
                Anno(Op("Num", [Var("d_2")]), Var("e_2"))
              )
            , Seq(
                Build(Var("d_2"))
              , Seq(
                  CallT(SVar("l_1"), [], [])
                , Seq(
                    Match(Var("f_2"))
                  , Build(
                      Anno(Op("Num", [Var("f_2")]), Var("e_2"))
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "Max_2_0"
        , [ VarDec(
              "m_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "n_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["i_2", "g_2", "h_2", "j_2", "k_2"]
          , Seq(
              Match(
                Anno(
                  Op("Max", [Var("g_2"), Var("h_2")])
                , Var("i_2")
                )
              )
            , Seq(
                Build(Var("g_2"))
              , Seq(
                  CallT(SVar("m_1"), [], [])
                , Seq(
                    Match(Var("j_2"))
                  , Seq(
                      Build(Var("h_2"))
                    , Seq(
                        CallT(SVar("n_1"), [], [])
                      , Seq(
                          Match(Var("k_2"))
                        , Build(
                            Anno(
                              Op("Max", [Var("j_2"), Var("k_2")])
                            , Var("i_2")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "Min_2_0"
        , [ VarDec(
              "o_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "p_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["n_2", "l_2", "m_2", "o_2", "p_2"]
          , Seq(
              Match(
                Anno(
                  Op("Min", [Var("l_2"), Var("m_2")])
                , Var("n_2")
                )
              )
            , Seq(
                Build(Var("l_2"))
              , Seq(
                  CallT(SVar("o_1"), [], [])
                , Seq(
                    Match(Var("o_2"))
                  , Seq(
                      Build(Var("m_2"))
                    , Seq(
                        CallT(SVar("p_1"), [], [])
                      , Seq(
                          Match(Var("p_2"))
                        , Build(
                            Anno(
                              Op("Min", [Var("o_2"), Var("p_2")])
                            , Var("n_2")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "True_0_0"
        , []
        , []
        , Match(Anno(Op("True", []), Wld()))
        )
      , SDefT(
          "False_0_0"
        , []
        , []
        , Match(Anno(Op("False", []), Wld()))
        )
      , SDefT(
          "And_2_0"
        , [ VarDec(
              "q_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "r_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["s_2", "q_2", "r_2", "t_2", "u_2"]
          , Seq(
              Match(
                Anno(
                  Op("And", [Var("q_2"), Var("r_2")])
                , Var("s_2")
                )
              )
            , Seq(
                Build(Var("q_2"))
              , Seq(
                  CallT(SVar("q_1"), [], [])
                , Seq(
                    Match(Var("t_2"))
                  , Seq(
                      Build(Var("r_2"))
                    , Seq(
                        CallT(SVar("r_1"), [], [])
                      , Seq(
                          Match(Var("u_2"))
                        , Build(
                            Anno(
                              Op("And", [Var("t_2"), Var("u_2")])
                            , Var("s_2")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "Or_2_0"
        , [ VarDec(
              "s_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "t_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["x_2", "v_2", "w_2", "y_2", "z_2"]
          , Seq(
              Match(
                Anno(
                  Op("Or", [Var("v_2"), Var("w_2")])
                , Var("x_2")
                )
              )
            , Seq(
                Build(Var("v_2"))
              , Seq(
                  CallT(SVar("s_1"), [], [])
                , Seq(
                    Match(Var("y_2"))
                  , Seq(
                      Build(Var("w_2"))
                    , Seq(
                        CallT(SVar("t_1"), [], [])
                      , Seq(
                          Match(Var("z_2"))
                        , Build(
                            Anno(
                              Op("Or", [Var("y_2"), Var("z_2")])
                            , Var("x_2")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "Nil_0_0"
        , []
        , []
        , Match(Anno(Op("Nil", []), Wld()))
        )
      , SDefT(
          "Cons_2_0"
        , [ VarDec(
              "u_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "v_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["c_3", "a_3", "b_3", "d_3", "e_3"]
          , Seq(
              Match(
                Anno(
                  Op("Cons", [Var("a_3"), Var("b_3")])
                , Var("c_3")
                )
              )
            , Seq(
                Build(Var("a_3"))
              , Seq(
                  CallT(SVar("u_1"), [], [])
                , Seq(
                    Match(Var("d_3"))
                  , Seq(
                      Build(Var("b_3"))
                    , Seq(
                        CallT(SVar("v_1"), [], [])
                      , Seq(
                          Match(Var("e_3"))
                        , Build(
                            Anno(
                              Op("Cons", [Var("d_3"), Var("e_3")])
                            , Var("c_3")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "_0_0"
        , []
        , []
        , Match(Anno(Op("", []), Wld()))
        )
      , SDefT(
          "_1_0"
        , [ VarDec(
              "w_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["g_3", "f_3", "h_3"]
          , Seq(
              Match(
                Anno(Op("", [Var("f_3")]), Var("g_3"))
              )
            , Seq(
                Build(Var("f_3"))
              , Seq(
                  CallT(SVar("w_1"), [], [])
                , Seq(
                    Match(Var("h_3"))
                  , Build(
                      Anno(Op("", [Var("h_3")]), Var("g_3"))
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "_2_0"
        , [ VarDec(
              "x_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "y_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["k_3", "i_3", "j_3", "l_3", "m_3"]
          , Seq(
              Match(
                Anno(
                  Op("", [Var("i_3"), Var("j_3")])
                , Var("k_3")
                )
              )
            , Seq(
                Build(Var("i_3"))
              , Seq(
                  CallT(SVar("x_1"), [], [])
                , Seq(
                    Match(Var("l_3"))
                  , Seq(
                      Build(Var("j_3"))
                    , Seq(
                        CallT(SVar("y_1"), [], [])
                      , Seq(
                          Match(Var("m_3"))
                        , Build(
                            Anno(
                              Op("", [Var("l_3"), Var("m_3")])
                            , Var("k_3")
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "_3_0"
        , [ VarDec(
              "z_1"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "a_2"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          , VarDec(
              "b_2"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["q_3", "n_3", "o_3", "p_3", "r_3", "s_3", "t_3"]
          , Seq(
              Match(
                Anno(
                  Op(
                    ""
                  , [Var("n_3"), Var("o_3"), Var("p_3")]
                  )
                , Var("q_3")
                )
              )
            , Seq(
                Build(Var("n_3"))
              , Seq(
                  CallT(SVar("z_1"), [], [])
                , Seq(
                    Match(Var("r_3"))
                  , Seq(
                      Build(Var("o_3"))
                    , Seq(
                        CallT(SVar("a_2"), [], [])
                      , Seq(
                          Match(Var("s_3"))
                        , Seq(
                            Build(Var("p_3"))
                          , Seq(
                              CallT(SVar("b_2"), [], [])
                            , Seq(
                                Match(Var("t_3"))
                              , Build(
                                  Anno(
                                    Op(
                                      ""
                                    , [Var("r_3"), Var("s_3"), Var("t_3")]
                                    )
                                  , Var("q_3")
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "DR__UNDEFINE_1_0"
        , [ VarDec(
              "c_2"
            , FunType(
                [ConstType(Sort("ATerm", []))]
              , ConstType(Sort("ATerm", []))
              )
            )
          ]
        , []
        , Scope(
            ["v_3", "u_3", "w_3"]
          , Seq(
              Match(
                Anno(Op("DR_UNDEFINE", [Var("u_3")]), Var("v_3"))
              )
            , Seq(
                Build(Var("u_3"))
              , Seq(
                  CallT(SVar("c_2"), [], [])
                , Seq(
                    Match(Var("w_3"))
                  , Build(
                      Anno(Op("DR_UNDEFINE", [Var("w_3")]), Var("v_3"))
                    )
                  )
                )
              )
            )
          )
        )
      , SDefT(
          "DR__DUMMY_0_0"
        , []
        , []
        , Match(Anno(Op("DR_DUMMY", []), Wld()))
        )
      ]
    )
  ]
)
