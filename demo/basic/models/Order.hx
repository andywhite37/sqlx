package basic.models;

@:table("orders")
class Order {
  @:col("id")
  @:type("int")
  @:pk
  public var id : Int;

  @:col("user_id")
  @:type("int")
  @:fk("users(id)")
  public var userId : Int;

  @:col("ordered_at")
  @:type("timestamp with time zone")
  public var orderedAt : DateTimeUtc;

  @:col("fulfilled_at")
  @:type("timestamp with time zone")
  @:nullable
  public var fulfilledAt : DateTimeUtc;

  @:col("cancelled_at")
  @:type("timestamp with time zone")
  @:nullable
  public var cancelledAt : DateTimeUtc;

  @:col("status_id")
  @:type("int")
  @:fk("order_status(id)")
  public var statusId : Int;
}
