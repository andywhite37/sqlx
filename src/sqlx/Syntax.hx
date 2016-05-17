package sqlx;

import haxe.ds.Option;

enum Value {
  VInt(v : Int);
  VFloat(v : Float);
  VString(v : String);
  VBool(v : Bool);
  VNull;
}

enum Expression {
  Lit(v : Value);
  Ident(name : String);
  Idents(parent : String, child : String);
  And(left : Expression, right : Expression);
  Or(left : Expression, right : Expression);
  Not(expr : Expression);
  UnOp(operator : String, operand : Expression);
  BinOp(operator : String, left : Expression, right : Expression);
  Func(name : String, args : Array<Expression>);
}

enum Selection {
  SStar;
  SExpression(expression : Expression, alias : Option<String>);
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
  FExpression(expression : Expression);
}

enum Grouping {
}

enum Ordering {
}

typedef SelectOptions = {
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
