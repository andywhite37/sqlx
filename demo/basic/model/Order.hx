package basic.model;

import thx.DateTimeUtc;

@:table("orders")
class Order {
  @:col("id")
  @:type("int")
  @:pk
  public static var id : Int;

  @:col("user_id")
  @:type("int")
  @:fk("users(id)")
  public static var userId : Int;

  @:col("ordered_at")
  @:type("timestamp with time zone")
  public static var orderedAt : DateTimeUtc;

  @:col("fulfilled_at")
  @:type("timestamp with time zone")
  @:nullable
  public static var fulfilledAt : DateTimeUtc;

  @:col("cancelled_at")
  @:type("timestamp with time zone")
  @:nullable
  public static var cancelledAt : DateTimeUtc;

  @:col("status_id")
  @:type("int")
  @:fk("order_status(id)")
  public static var statusId : Int;
}
