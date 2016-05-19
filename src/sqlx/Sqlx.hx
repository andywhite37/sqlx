package sqlx;

import haxe.macro.Expr;

class Sqlx {
  public function new() {
  }

  macro public function from(e : Expr) {
    return macro $e;
  }
}
