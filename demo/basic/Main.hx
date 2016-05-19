package basic;

import sqlx.Formatter;
import sqlx.Syntax.Query;
import sqlx.Sqlx;
import basic.model.Order;
import basic.model.OrderLine;
import basic.model.User;

class Main {
  public static function main() {
    var sqlx = new Sqlx();

    var query : Query = sqlx
      .from(User)
      .innerJoin(Order, Order.userId == User.id)
      .innerJoin(OrderLine, OrderLine.orderId == Order.id)
      .where(User.email == "andy.white@pellucid.com")
      .select({
        email: User.email,
        orderId: Order.id,
        orderLineId: OrderLine.id
      });

    var formatter = new Formatter();

    var sql = formatter.format(query);
    trace(sql);
  }
}
