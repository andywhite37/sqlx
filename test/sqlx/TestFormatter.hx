package sqlx;

import haxe.ds.Option;
import sqlx.Syntax;
import utest.Assert;

class TestFormatter {
  public function new() {}

  public function testFormat1() {
    var query : Query = Select({
      selections: [SExpression(Ident("*"), None)],
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
      selections: [
        SExpression(Ident("*"), None),
        SExpression(IdentPath(["users", "name"]), Some("n"))
      ],
      source: Table("users", Some("u")),
      joins: Some([
        InnerJoin(Table("orders", Some("o")), BinOp("=", IdentPath(["o", "userId"]), IdentPath(["u", "id"]))),
        LeftJoin(Table("orderLines", None), BinOp("=", IdentPath(["orderLines", "orderId"]), IdentPath(["o", "id"])))
      ]),
      filter: Some(FExpression(And( 
        BinOp("=", IdentPath(["o", "status"]), Lit(VString("open"))),
        BinOp("=", IdentPath(["u", "status"]), Lit(VString("active")))
      ))),
      groupings: None,
      orderings: None,
      offset: Some(40),
      limit: Some(20)
    });
    var actual = new Formatter('\n').format(query);
    var expected = "select * from users;";
    Assert.equals(expected, actual);
  }
}
