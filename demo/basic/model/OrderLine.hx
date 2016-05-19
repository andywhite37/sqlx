package basic.model;

@:table("order_lines")
class OrderLine {
  @:col("id")
  @:type("int")
  @:pk
  public static var id : Int;

  @:col("order_id")
  @:type("int")
  @:fk("orders(id)")
  public static var orderId : Int;
}
