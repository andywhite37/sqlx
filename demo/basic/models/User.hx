package basic.models;

@:table("users")
class User {
  @:col("id")
  @:type("int")
  @:pk
  public var id : Int;

  @:col("email")
  @:type("varchar(255)")
  public var email : String;

  @:col("name")
  @:type("varchar(255)")
  public var name : String;
}
