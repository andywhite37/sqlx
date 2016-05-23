package sqlx;

import haxe.ds.Either;
import haxe.ds.Option;
import sqlx.Syntax;
import thx.Error;
import thx.Nel;
import thx.ReadonlyArray;
import thx.Validation;
using thx.Arrays;
using sqlx.util.Nels;

typedef FormatterSettings = {
  lineSeparator: String,
  itemSeparator: String,
  identLeftQuote: String,
  identRightQuote: String,
  stringLeftQuote: String,
  stringRightQuote: String
};

class Formatter {
  public var settings(default, null) : FormatterSettings;

  public function new(?settings: FormatterSettings) {
    this.settings = settings != null ? settings : getDefaultSettings();
  }

  public static function getDefaultSettings() : FormatterSettings {
    return {
      lineSeparator: "\n",
      itemSeparator: ", ",
      identLeftQuote: '"',
      identRightQuote: '"',
      stringLeftQuote: "'",
      stringRightQuote: "'"
    };
  }

  public function format(sqlQuery : SqlQuery) : String {
    return switch sqlQuery {
      case Select(query) : formatSelect(query);
      case Insert(query) : formatInsert(query);
      case Update(query) : formatUpdate(query);
      case Delete(query) : formatDelete(query);
    };
  }

  public function formatSelect(query : SelectQuery) : String {
    var distinct = formatDistinct(query.distinct);
    var selections = formatSelections(query.selections);
    var source = formatSource(query.source, true);
    var joins = formatJoins(query.joins);
    var filter = formatFilter(query.filter);
    var groupings = formatGroupings(query.groupings);
    var orderings = formatOrderings(query.orderings);
    var offset = formatOffset(query.offset);
    var limit = formatLimit(query.limit);
    var sep = settings.lineSeparator;
    return 'select ${distinct}${selections}${source}${joins}${filter}${groupings}${orderings}${offset}${limit};';
  }

  public function formatInsert(query : InsertQuery) : String {
    throw 'not implemented';
  }

  public function formatUpdate(query : UpdateQuery) : String {
    throw 'not implemented';
  }

  public function formatDelete(query : DeleteQuery) : String {
    throw 'not implemented';
  }

  public function formatDistinct(distinct : Bool) : String {
    return distinct ? "distinct " : "";
  }

  public function formatSelections(selections : Nel<Selection>) : String {
    return selections.map(formatSelection).join(settings.itemSeparator);
  }

  public function formatSelection(selection : Selection) : String {
    return switch selection {
      case SelExpr(expr, alias) : '${formatExpression(expr)}${formatAlias(alias)}';
    };
  }

  public function formatSource(source : Source, isFrom : Bool) : String {
    var sep = isFrom ? settings.lineSeparator : "";
    var from = isFrom ? "from " : "";
    return switch source {
      case SrcNone : '';
      case SrcTable(name, alias) : '${sep}${from}${quoteIdent(name)}${formatAlias(alias)}';
      case SrcFunc(name, args, alias) : '${sep}${from}${formatFunction(name, args)}${formatAlias(alias)}';
      case SrcSelect(options, alias) : '${sep}${from}${formatSelect(options)}${formatAlias(alias)}';
    };
  }

  public function formatJoins(joins : ReadonlyArray<Join>) : String {
    if (joins.isEmpty()) return "";
    return settings.lineSeparator + joins.map(formatJoin).join(settings.lineSeparator);
  }

  public function formatJoin(join : Join) : String {
    return switch join {
      case InnerJoin(source, on) : 'inner join ${formatSource(source, false)} on ${formatExpression(on)}';
      case LeftJoin(source, on) : 'left outer join ${formatSource(source, false)} on ${formatExpression(on)}';
      case RightJoin(source, on) : 'right outer join ${formatSource(source, false)} on ${formatExpression(on)}';
      case FullJoin(source, on) : 'full outer join ${formatSource(source, false)} on ${formatExpression(on)}';
      case CrossJoin(source) : 'cross join ${formatSource(source, false)}';
      case Union(source) : 'union ${formatSource(source, false)}';
      case UnionAll(source) : 'union all ${formatSource(source, false)}';
    };
  }

  public function formatFilter(filter : Filter) : String {
    return switch filter {
      case FiltNone : "";
      case FiltExpr(expr) : settings.lineSeparator + "where " + formatExpression(expr);
    };
  }

  public function formatGroupings(groupings : ReadonlyArray<Grouping>) : String {
    if (groupings.isEmpty()) return "";
    return settings.lineSeparator + "group by " + groupings.map(formatGrouping).join(settings.lineSeparator);
  }

  public function formatOrderings(orderings : ReadonlyArray<Ordering>) : String {
    if (orderings.isEmpty()) return "";
    return settings.lineSeparator + "order by " + orderings.map(formatOrdering).join(settings.lineSeparator);
  }

  public function formatGrouping(grouping : Grouping) : String {
    return '';
  }

  public function formatOrdering(ordering : Ordering) : String {
    return '';
  }

  public function formatExpression(expression : Expression) : String {
    return switch expression {
      case EStar : '*';
      case ELit(v) : formatValue(v);
      case EIdent(name) : formatIdent(name);
      case EQualIdent(parent, child) : '${formatIdent(parent)}.${formatIdent(child)}';
      case EQualStar(parent) : '${formatIdent(parent)}.*';
      case EAnd(left, right) : '(${formatExpression(left)} and ${formatExpression(right)})';
      case EOr(left, right) : '(${formatExpression(left)} or ${formatExpression(right)})';
      case ENot(expr) : 'not ${formatExpression(expr)}';
      case EUnOp(operator, operand) : '${operator}${formatExpression(operand)}';
      case EBinOp(operator, left, right) : '(${formatExpression(left)} ${operator} ${formatExpression(right)})';
      case EFunc(name, args) : formatFunction(name, args);
    };
  }

  public function formatIdent(name : String) : String {
    return quoteIdent(name);
  }

  public function formatFunction(name : String, args : ReadonlyArray<Expression>) : String {
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

  public function formatAlias(alias : Option<String>) : String {
    return switch alias {
      case Some(alias) : ' as ${quoteIdent(alias)}';
      case None : '';
    };
  }

  public function formatOffset(offset : Option<Int>) : String {
    return switch offset {
      case Some(v) : settings.lineSeparator + 'offset $v';
      case None : '';
    };
  }

  public function formatLimit(limit : Option<Int>) : String {
    return switch limit {
      case Some(v) : settings.lineSeparator + 'limit $v';
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
