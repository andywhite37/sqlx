package sqlx;

import haxe.ds.Option;
import sqlx.Syntax;
import utest.Assert;

class TestFormatter {
  public function new() {}

  public function testFormat1() {
    var query : Query = Select({
      distinct: false,
      selections: [SStar],
      source: Table("users", None),
      joins: None,
      filter: None,
      groupings: None,
      orderings: None,
      offset: None,
      limit: None
    });
    var actual = new Formatter().format(query);
    var expected = "select * from users;";
    Assert.equals(expected, actual);
  }

  public function testFormat2() {
    var query : Query = Select({
      distinct: true,
      selections: [
        SStar,
        SExpr(IdentMember("u", "name"), Some("n"))
      ],
      source: Table("users", Some("u")),
      joins: Some([
        InnerJoin(Table("orders", Some("o")), BinOp("=", IdentMember("o", "userId"), IdentMember("u", "id"))),
        LeftJoin(Table("orderLines", None), BinOp("=", IdentMember("orderLines", "orderId"), IdentMember("o", "id")))
      ]),
      filter: Some(FExpr(And(
        BinOp("=", IdentMember("o", "status"), Lit(VString("open"))),
        BinOp("=", IdentMember("u", "status"), Lit(VString("active")))
      ))),
      groupings: None,
      orderings: None,
      offset: Some(40),
      limit: Some(20)
    });
    var actual = new Formatter('\n').format(query);
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
