package basic;

import sqlx.Formatter;
import sqlx.Syntax;
import basic.model.Order;
import basic.model.OrderLine;
import basic.model.User;
using sqlx.Query;

class Main {
  public static function main() {
    var query = Query.from(User)
      .innerJoin(Order, Order.userId == User.id)
      .innerJoin(OrderLine, OrderLine.orderId == Order.id)
      .where(User.email == "andy.white@pellucid.com")
      .select()
      //.select(User)
      //.select(User, Order)
      //.select({
        //email: User.email,
        //orderId: Order.id,
        //orderLineId: OrderLine.id
      //})
      ;
    var sql = new Formatter().format(Select(query));
    trace(sql);
  }
}
