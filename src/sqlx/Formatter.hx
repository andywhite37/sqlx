package sqlx;

import haxe.ds.Option;
import sqlx.Syntax;
using thx.Arrays;
using thx.Options;

class Formatter {
  var divider : String;

  public function new(divider : String = " ") {
    this.divider = divider;
  }

  public function format(query : Query) : String {
    return switch query {
      case Select(options) : formatSelect(options);
      case Insert(options) : formatInsert(options);
      case Update(options) : formatUpdate(options);
      case Delete(options) : formatDelete(options);
    };
  }

  public function formatSelect(options : SelectOptions) : String {
    var selections = 'select ${options.selections.map(formatSelection).join(", ")}';
    var source = '${divider}from ${formatSource(options.source)}';
    var joins = options.joins.cata('', function(joins : Array<Join>) : String {
      return '${divider}${joins.map(formatJoin).join(divider)}';
    });
    var filter = options.filter.cata('', function(filter : Filter) : String {
      return '${divider}where ${formatFilter(filter)}';
    });
    var groupings = options.groupings.cata('', function(groupings : Array<Grouping>) : String {
      return '${divider}${groupings.map(formatGrouping).join(", ")}';
    });
    var orderings = options.orderings.cata('', function(orderings : Array<Ordering>) : String {
      return '${divider}${orderings.map(formatOrdering).join(", ")}';
    });
    var offset = options.offset.cata('', function(offset : Int) : String {
      return '${divider}offset $offset';
    });
    var limit = options.limit.cata('', function(limit : Int) : String {
      return '${divider}limit $limit';
    });
    return '${selections}${source}${joins}${filter}${groupings}${orderings}${offset}${limit};';
  }

  public function formatInsert(options : InsertOptions) : String {
    throw 'not implemented';
  }

  public function formatUpdate(options : UpdateOptions) : String {
    throw 'not implemented';
  }

  public function formatDelete(options : DeleteOptions) : String {
    throw 'not implemented';
  }

  public function formatSelection(selection : Selection) : String {
    return switch selection {
      case All : '*';
      case SExpression(expr, alias) : '${formatExpression(expr)}${formatAlias(alias)}';
    };
  }

  public function formatSource(source : Source) : String {
    return switch source {
      case Table(name, alias) : '${quoteIdent(name)}${formatAlias(alias)}';
      case Func(name, args, alias) : '${formatFunction(name, args)}${formatAlias(alias)}';
      case Select(options, alias) : '${formatSelect(options)}${formatAlias(alias)}';
    };
  }

  public function formatJoin(join : Join) : String {
    return switch join {
      case InnerJoin(source, on) : 'inner join ${formatSource(source)} on ${formatExpression(on)}';
      case LeftJoin(source, on) : 'left outer join ${formatSource(source)} on ${formatExpression(on)}';
      case RightJoin(source, on) : 'right outer join ${formatSource(source)} on ${formatExpression(on)}';
      case FullJoin(source, on) : 'full outer join ${formatSource(source)} on ${formatExpression(on)}';
      case CrossJoin(source) : 'cross join ${formatSource(source)}';
      case Union(source) : 'union ${formatSource(source)}';
      case UnionAll(source) : 'union all ${formatSource(source)}';
    };
  }

  public function formatFilter(filter : Filter) : String {
    return switch filter {
      case FExpression(expr) : ${formatExpression(expr)};
    };
  }

  public function formatGrouping(grouping : Grouping) : String {
    return '';
  }

  public function formatOrdering(ordering : Ordering) : String {
    return '';
  }

  public function formatExpression(expression : Expression) : String {
    return switch expression {
      case Lit(v) : formatValue(v);
      case Ident(name) : formatIdent(name);
      case IdentPath(parts) : parts.map(formatIdent).join(".");
      case And(left, right) : '(${formatExpression(left)} and ${formatExpression(right)})';
      case Or(left, right) : '(${formatExpression(left)} or ${formatExpression(right)})';
      case Not(expr) : 'not ${formatExpression(expr)}';
      case UnOp(operator, operand) : '${operator}${formatExpression(operand)}';
      case BinOp(operator, left, right) : '(${formatExpression(left)} ${operator} ${formatExpression(right)})';
      case Func(name, args) : formatFunction(name, args);
    };
  }

  public function formatIdent(name : String) : String {
    return quoteIdent(name);
  }

  public function formatFunction(name : String, args : Array<Expression>) : String {
    return '${name}(${args.map(formatExpression)})';
  }

  public function formatValue(value : Value) : String {
    return switch value {
      case VInt(v) : Std.string(v);
      case VFloat(v) : Std.string(v);
      case VString(v) : quoteLit(v);
      case VBool(v) : Std.string(v);
      case VNull : "null";
    };
  }

  public function formatAlias(alias : Option<String>) {
    return switch alias {
      case Some(alias) : ' as ${quoteIdent(alias)}';
      case None : '';
    };
  }

  public function quoteIdent(ident : String) : String {
    if (~/[A-Z]/.match(ident)) {
      return '"$ident"';
    }
    return ident;
  }

  public function quoteLit(str : String) : String {
    return '\'$str\'';
  }
}
