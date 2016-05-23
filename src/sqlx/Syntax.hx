package sqlx;

import haxe.ds.Option;
import thx.Nel;
import thx.ReadonlyArray;

enum Value {
  VInt(v : Int);
  VFloat(v : Float);
  VString(v : String);
  VBool(v : Bool);
  VNull;
}

enum Expression {
  EStar;
  ELit(v : Value);
  EIdent(name : String);
  EQualIdent(source : String, name : String);
  EQualStar(source : String);
  EAnd(left : Expression, right : Expression);
  EOr(left : Expression, right : Expression);
  ENot(expr : Expression);
  EUnOp(operator : String, operand : Expression);
  EBinOp(operator : String, left : Expression, right : Expression);
  EFunc(name : String, args : ReadonlyArray<Expression>);
}

enum Selection {
  SelExpr(expr : Expression, alias : Option<String>);
}

enum Source {
  SrcNone;
  SrcTable(name : String, alias : Option<String>);
  //SrcTables(tables : Nel<{ name : String, alias : Option<String> }>);
  SrcFunc(name : String, arguments : ReadonlyArray<Expression>, alias : Option<String>);
  SrcSelect(query : SelectQuery, alias : Option<String>);
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
  FiltNone;
  FiltExpr(expression : Expression);
}

enum Grouping {
  GrpNone;
  GrpExprs(expressions : ReadonlyArray<Expression>, having : Option<Expression>);
}

enum Direction {
  Asc;
  Desc;
}

enum Ordering {
  OrdNone;
  OrdExprs(expressions : ReadonlyArray<{ expr : Expression, dir: Direction }>);
}

class SelectQuery {
  public var distinct(default, null): Bool;
  public var selections(default, null) : Nel<Selection>;
  public var source(default, null) : Source;
  public var joins(default, null) : ReadonlyArray<Join>;
  public var filter(default, null) : Filter;
  public var groupings(default, null) : ReadonlyArray<Grouping>;
  public var orderings(default, null) : ReadonlyArray<Ordering>;
  public var offset(default, null) : Option<Int>;
  public var limit(default, null) : Option<Int>;

  public function new(options: {
    distinct : Bool,
    selections : Nel<Selection>,
    source : Source,
    joins : ReadonlyArray<Join>,
    filter : Filter,
    groupings : ReadonlyArray<Grouping>,
    orderings : ReadonlyArray<Ordering>,
    offset : Option<Int>,
    limit : Option<Int>
  }) {
    this.distinct = options.distinct;
    this.selections = options.selections;
    this.source = options.source;
    this.joins = options.joins;
    this.filter = options.filter;
    this.groupings = options.groupings;
    this.orderings = options.orderings;
    this.offset = options.offset;
    this.limit = options.limit;
  }

  public static function empty() : SelectQuery {
    return new SelectQuery({ distinct: false, selections: Nel.pure(SelExpr(EStar, Option.None)), source: SrcNone,
      joins: [], filter: FiltNone, groupings: [], orderings: [],
      offset: Option.None, limit: Option.None });
  }

  public function setDistinct(distinct : Bool) : SelectQuery {
    return new SelectQuery({ distinct: distinct, selections: this.selections, source: this.source,
      joins: this.joins, filter: this.filter, groupings: this.groupings, orderings: this.orderings,
      offset: this.offset, limit: this.limit });
  }

  public function setSelections(selections : Nel<Selection>) : SelectQuery {
    return new SelectQuery({ distinct: this.distinct, selections: selections, source: this.source,
      joins: this.joins, filter: this.filter, groupings: this.groupings, orderings: this.orderings,
      offset: this.offset, limit: this.limit });
  }

  public function setSource(source : Source) : SelectQuery {
    return new SelectQuery({ distinct: this.distinct, selections: this.selections, source: source,
      joins: this.joins, filter: this.filter, groupings: this.groupings, orderings: this.orderings,
      offset: this.offset, limit: this.limit });
  }

  public function setFilter(filter : Filter) : SelectQuery {
    return new SelectQuery({ distinct: this.distinct, selections: this.selections, source: this.source,
      joins: this.joins, filter: filter, groupings: this.groupings, orderings: this.orderings,
      offset: this.offset, limit: this.limit });
  }

  public function addJoin(join : Join) : SelectQuery {
    return new SelectQuery({ distinct: this.distinct, selections: this.selections, source: this.source,
      joins: this.joins.append(join), filter: filter, groupings: this.groupings, orderings: this.orderings,
      offset: this.offset, limit: this.limit });
  }
}

class InsertQuery {
}

class UpdateQuery {
}

class DeleteQuery {
}

enum SqlQuery {
  Select(query : SelectQuery);
  Insert(query : InsertQuery);
  Update(query : UpdateQuery);
  Delete(query : DeleteQuery);
}
