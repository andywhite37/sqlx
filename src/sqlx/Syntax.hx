package sqlx;

import haxe.ds.Option;
import thx.Tuple;

enum Value {
  VInt(v : Int);
  VFloat(v : Float);
  VString(v : String);
  VBool(v : Bool);
  VNull;
}

enum Expression {
  Lit(v : Value);
  Star;
  Ident(name : String);
  IdentMember(parent : String, child : String);
  And(left : Expression, right : Expression);
  Or(left : Expression, right : Expression);
  Not(expr : Expression);
  UnOp(operator : String, operand : Expression);
  BinOp(operator : String, left : Expression, right : Expression);
  Func(name : String, args : Array<Expression>);
}

enum Selection {
  SStar;
  SExpr(expression : Expression, alias : Option<String>);
}

enum Source {
  Table(name : String, alias : Option<String>);
  Func(name : String, arguments : Array<Expression>, alias : Option<String>);
  Select(options : SelectOptions, alias : Option<String>);
}

enum Join {
  InnerJoin(source : Source, on : Expression);
  LeftJoin(source : Source, on : Expression);
  RightJoin(source : Source, on : Expression);
  FullJoin(source : Source, on : Expression);
  CrossJoin(source : Source);
  Union(source : Source);
  UnionAll(source : Source);
}

enum Filter {
  FExpr(expression : Expression);
}

enum Grouping {
  GExpr(expressions : Array<Expression>, having : Option<Expression>);
}

enum Direction {
  Asc;
  Desc;
}

enum Ordering {
  OExpr(expressions : Array<Tuple<Expression, Direction>>);
}

typedef SelectOptions = {
  distinct: Bool,
  selections : Array<Selection>,
  source : Source,
  joins : Option<Array<Join>>,
  filter : Option<Filter>,
  groupings : Option<Array<Grouping>>,
  orderings : Option<Array<Ordering>>,
  offset: Option<Int>,
  limit : Option<Int>
};

typedef InsertOptions = {
};

typedef UpdateOptions = {
};

typedef DeleteOptions = {
};

enum Query {
  Select(options : SelectOptions);
  Insert(options : InsertOptions);
  Update(options : UpdateOptions);
  Delete(options : DeleteOptions);
}
