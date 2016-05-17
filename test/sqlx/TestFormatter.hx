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
        SStar,
        SExpression(Idents("users", "name"), Some("n"))
      ],
      source: Table("users", Some("u")),
      joins: Some([
        InnerJoin(Table("orders", Some("o")), BinOp("=", Idents("o", "userId"), Idents("u", "id"))),
        LeftJoin(Table("orderLines", None), BinOp("=", Idents("orderLines", "orderId"), Idents("o", "id")))
      ]),
      filter: Some(FExpression(And(
        BinOp("=", Idents("o", "status"), Lit(VString("open"))),
        BinOp("=", Idents("u", "status"), Lit(VString("active")))
      ))),
      groupings: None,
      orderings: None,
      offset: Some(40),
      limit: Some(20)
    });
    var actual = new Formatter('\n').format(query);
    // TODO: expected is not correct
    var expected = "select * from users;";
    Assert.equals(expected, actual);
  }
}
