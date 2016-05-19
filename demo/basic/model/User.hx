package basic.model;

@:table("users")
class User {
  @:col("id")
  @:type("int")
  @:pk
  public static var id : Int;

  @:col("email")
  @:type("varchar(255)")
  public static var email : String;

  @:col("name")
  @:type("varchar(255)")
  public static var name : String;
}
