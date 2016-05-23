package sqlx;

import haxe.ds.Option;
import sqlx.Syntax;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using thx.Arrays;
using thx.Strings;
using thx.Options;
using thx.macro.MacroTypes;
using thx.macro.MacroClassTypes;

typedef ColumnInfo = { haxeFieldName : String, sqlColumnName : String, haxeType : Type, sqlType : String };
typedef ColumnMap = Map<String, ColumnInfo>;
typedef ModelInfo = {
  className : String,
  type: Type,
  complexType: ComplexType,
  classType : ClassType,
  metadata: Metadata,
  tableName: String,
  columns: ColumnMap,
};

class Query {
  public static function distinct(query : SelectQuery) : SelectQuery {
    return query.setDistinct(true);
  }

  macro public static function from(modelExpr : ExprOf<Class<Dynamic>>) : Expr {
    var modelInfo = getModelInfo(modelExpr);
    return macro SelectQuery.empty().setSource(SrcTable($v{modelInfo.tableName}, None));
  }

  macro public static function innerJoin(queryExpr : ExprOf<SelectQuery>, modelExpr : ExprOf<Class<Dynamic>>, onExpr : Expr) : Expr {
    var tableName = getModelInfo(modelExpr).tableName;
    var joinInfo = getBinaryOperatorInfo(onExpr);
    var join = InnerJoin(
      SrcTable(tableName, None),
      EBinOp(joinInfo.operator,
        EQualIdent(joinInfo.leftTableName, joinInfo.leftColumnName),
        EQualIdent(joinInfo.rightTableName, joinInfo.rightColumnName)
      )
    );
    return macro $e{queryExpr}.addJoin($v{join});
  }

  macro public static function where(queryExpr : ExprOf<SelectQuery>, filterExpr : Expr) : Expr {
    return macro $e{queryExpr};
  }

  macro public static function select(queryExpr : ExprOf<SelectQuery>) : Expr {
    return macro $e{queryExpr};
  }

#if macro
  static function getModelInfo(e : Expr) : ModelInfo {
    return switch e.expr {
      case EConst(CIdent(name)) : getModelInfoByClassName(name);
      case _ : Context.error("expecting a const ident expression of a model class", Context.currentPos());
    };
  }

  static function getModelInfoByClassName(className : String) : ModelInfo {
    var type : Type = Context.getType(className);
    var complexType : ComplexType = MacroTypes.qualifyType(type);
    var classType = switch type {
      case TInst(classType, params) : classType.get();
      case _ : Context.error("failed to get class type for model expr", Context.currentPos());
    };
    var metadata = classType.meta.get();

    var tableName = getMetaString(metadata, ":table");

    var columns = classType.statics.get().reduce(function(acc : ColumnMap, field : haxe.macro.ClassField) : ColumnMap {
      acc.set(field.name, {
        haxeFieldName: field.name,
        haxeType: field.type,
        sqlColumnName: getMetaString(field.meta.get(), ":col"),
        sqlType: getMetaString(field.meta.get(), ":type"),
      });
      return acc;
    }, new Map());

    return {
      className: className,
      type: type,
      complexType: complexType,
      classType: classType,
      metadata: metadata,
      tableName : tableName,
      columns: columns
    };
  }

  static function haxeExprToSqlxExpr(expr : Expr) : Expression {
    return switch expr.expr {
      case EConst(CInt(value)) : ELit(VInt(Std.parseInt(value)));
      case EConst(CFloat(value)) : ELit(VFloat(Std.parseFloat(value)));
      case EConst(CString(value)) : ELit(VString(value));
      case EConst(CIdent(name)) : EIdent(name);
      case EConst(CRegexp(str, opt)) : Context.error('unable to convert const regexp expression "$str" ($opt) to sqlx expression', Context.currentPos());
      case EBinop(op, left, right) : EBinOp(haxeBinopToString(op), haxeExprToSqlxExpr(left), haxeExprToSqlxExpr(right));
      //case EField(expr, field) : 
      case _ : Context.error('expression ${expr.expr} is not yet supported', Context.currentPos());
    };
  }

  static function getBinaryOperatorInfo(expr : Expr) {
    return switch expr.expr {
      case EBinop(binop,
        { expr: EField({ expr: EConst(CIdent(leftClassName)) }, leftFieldName) },
        { expr: EField({ expr : EConst(CIdent(rightClassName)) }, rightFieldName) }
      ) :
        var leftModelInfo = getModelInfoByClassName(leftClassName);
        var rightModelInfo = getModelInfoByClassName(rightClassName);
        var leftColumnInfo = leftModelInfo.columns.get(leftFieldName);
        var rightColumnInfo = rightModelInfo.columns.get(rightFieldName);
        return {
          operator: haxeBinopToString(binop),
          leftTableName: leftModelInfo.tableName,
          leftColumnName: leftColumnInfo.sqlColumnName,
          rightTableName: rightModelInfo.tableName,
          rightColumnName: rightColumnInfo.sqlColumnName,
        }
      case _ : Context.error("expected a binary operator expression", Context.currentPos());
    };
  }

  static function haxeBinopToString(binop : Binop) {
    return switch binop {
      case OpEq : "=";
      case _ : Context.error('$binop not yet supported', Context.currentPos());
    };
  }

  static function getMetaString(metadata : Metadata, name : String) : String {
    var meta = metadata.find(function(meta) {
      return meta.name == name;
    });

    if (meta == null) {
      Context.error('no meta found for name $name', Context.currentPos());
    }

    return switch meta.params {
      case [{ expr: EConst(CString(value)) }] : value;
      case _ : Context.error('expected a constant string metadata value for name $name', Context.currentPos());
    }
  }
#end
}
