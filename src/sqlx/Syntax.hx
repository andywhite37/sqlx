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
  And(left : Expression, right : Expression);
  Or(left : Expression, right : Expression);
  Not(expr : Expression);
  UnOp(operator : String, operand : Expression);
  BinOp(operator : String, left : Expression, right : Expression);
  Func(name : String, args : Array<Expression>);
}

enum Selection {
  Expression(expression : Expression);
  ExpressionAlias(expression : Expression, alias : String);
}

enum Source {
  Table(name : String);
  TableAlias(name : String, alias : String);
  Func(name : String, arguments : Array<Expression>);
  FuncAlias(name : String, arguments : Array<Expression>, alias : String);
  Select(options : SelectOptions);
}

enum Join {
  InnerJoin(left : Source, right : Source, on : Expression);
  LeftJoin(left : Source, right : Source, on : Expression);
  RightJoin(left : Source, right : Source, on : Expression);
  FullJoin(left : Source, right : Source, on : Expression);
  CrossJoin(left : Source, right : Source);
  Union(left : Source, right : Source);
  UnionAll(left : Source, right : Source);
}

enum Filter {
  Expression(expression : Expression);
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
