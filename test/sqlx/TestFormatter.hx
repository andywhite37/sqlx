package sqlx;

import haxe.ds.Option;
import sqlx.Syntax;
import utest.Assert;
import thx.Nel;
using thx.Options;
using sqlx.util.Nels;

class TestFormatter {
  var formatter : Formatter;

  public function new() {
    var settings = Formatter.getDefaultSettings();
    settings.lineSeparator = " ";
    this.formatter = new Formatter(settings);
  }

  public function testFormat1() {
    var query = SelectQuery.empty().setSource(SrcTable("users", None));
    var actual = formatter.format(Select(query));
    var expected = "select * from users;";
    Assert.equals(expected, actual);
  }

  public function testFormat2() {
    var query = new SelectQuery({
      distinct: true,
      selections: Nel.pure(SelExpr(EStar, None)).push(SelExpr(EQualIdent("u", "name"), Some("n"))),
      source: SrcTable("users", Some("u")),
      joins: [
        InnerJoin(SrcTable("orders", Some("o")), EBinOp("=", EQualIdent("o", "userId"), EQualIdent("u", "id"))),
        LeftJoin(SrcTable("orderLines", None), EBinOp("=", EQualIdent("orderLines", "orderId"), EQualIdent("o", "id")))
      ],
      filter: FiltExpr(EAnd(
        EBinOp("=", EQualIdent("o", "status"), ELit(VString("open"))),
        EBinOp("=", EQualIdent("u", "status"), ELit(VString("active")))
      )),
      groupings: [],
      orderings: [],
      offset: Some(40),
      limit: Some(20)
    });
    formatter.settings.lineSeparator = "\n";
    var actual = formatter.format(Select(query));
    var expected = 'select distinct *, u.name as n
from users as u
inner join orders as o on (o."userId" = u.id)
left outer join "orderLines" on ("orderLines"."orderId" = o.id)
where ((o.status = \'open\') and (u.status = \'active\'))
offset 40
limit 20;';
    Assert.equals(expected, actual);
  }
}
