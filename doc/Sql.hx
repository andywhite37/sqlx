//stripper.xxx

//- Generate POHOs from database tables

create table order(
  id varchar,
  status varchar,
  user_id varchar references user(id)
);

enum Field<T> {
}

// generated
@:table("order")
class ORDER {
  @:column("id", "varchar")
  static var ID : Field<T>;

  @:column("status", "varchar")
  static var STATUS : Field<T>;

  @:column("user_id", "varchar", "fk")
  static var USER_ID : Field<T>;
}

class FN {
  static var PRODUCT_SEARCH : SqlFunction<String, Array<{ productId : String, name : String }>>
}

typedef Order = {
  var id : String;
  var userId : String;
};

class Query {
  public function toSql() : String;

  // for insert/update/delete
  public function run() : Promise<T> {
  }

  // for select
  public function table() : Promise<Cursor<T>> {
  }

  public function count() : Promise<Int> {
  }

  public function objects() : Promise<Cursor<T>> {
  }
}

class Sql {
  public function select(fieldDescriptors : Array<FieldDescriptor>) : Query {
  }
}


class Main {

  sql.from(ORDER).join(ORDER_LINE, ORDER.ID == ORDER_LINE.orderId).where(ORDER.STATUS == "open").select();

  sql.from(ORDER).where(ORDER.ID = 5).select(count(ORDER.ID)); // Cursor<{ count: Int }>;
  sql.from(ORDER).where(ORDER.ID = 5).count(); // Cursor<{ count: Int }>;

  sql.from(ORDER).join(ORDER_LINE, ORDER.ID == ORDER_LINE.orderId).where(ORDER.STATUS == "open").select(ORDER.ID, ORDER.STATUS, ORDER_LINE.PRODUCT_ID).table();
  sql.from(ORDER).join(ORDER_LINE, ORDER.ID == ORDER_LINE.orderId).where(ORDER.STATUS == "open").select(ORDER.ID, ORDER.STATUS, ORDER_LINE.PRODUCT_ID).objects();


  sql.from(ORDER).join(OrderLine, Eq(ORDER.ID, ORDER_LINE.ID)).select([ORDER.ID, ORDER.STATUS]);
  // { ID

  sql.from(ORDER).join(ORDER_LINE, ORDER.ID == ORDER_LINE.orderId).where(ORDER.STATUS == "open").select(ORDER.ID as "id", ORDER_LINE.ID as "orderLineId", ORDER.STATUS);

  sql.from(ORDER).join(ORDER_LINE).where(ORDER.STATUS == "open").select("*");

  sql.from(USER).where(USER.EMAIL.like('%pellucid.com') && USER.NAME.ilike('%andy%'));

  sql.delete(USER).where(USER.EMAIL == "andy");

  sql.transaction({
    sql.insert(ORDER_LINE).setMany({}, {}, {});
    sql.insert(ORDER).setMany({}, {}, {});
  })

  var t = sql.begin();
  sql.insert(ORDER).set({}).queue(t);
  sql.insert(USER).set({}).queue(t);
  sql.from(USER).select().queueTable(t);
  t.execute()
    .success(function(r : Promise<Tuple<Int, Int, User>>) {
    });


  // insert into User (id, email, name)
  // values (123, 'aw@asd', 'andy')
  sql.insert(USER).values(USER.ID = 123, USER.EMAIL = 'andy', USER.NAME = 'andy');
  sql.insert(USER).set({
    id: 123,
    email: 'andy'
  })

  sql.update(USER).set(USER.ID = 123, USER.EMAIL = 'andy', USER.NAME = 'andy');

  sql.from(ORDER).groupBy(ORDER.USER_ID).select(ORDER.USER_ID, count(ORDER.USER_ID));


  // select * from product_search('hi')

  sql.from(FN.PRODUCT_SEARCH('hi')).select().table()
    .success(function(products) {
      for (product in products) {
        trace(product);
      }
    });
}

