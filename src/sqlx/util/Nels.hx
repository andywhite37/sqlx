package sqlx.util;

import thx.Nel;

class Nels {
  public static function join(nel : Nel<String>, delimiter: String) : String {
    return switch nel {
      case Single(x) : x;
      case ConsNel(x, xs) : return '${x}${delimiter}${join(xs, delimiter)}';
    };
  }

  public static function push<A>(nel : Nel<A>, item : A) : Nel<A> {
    return nel.append(Single(item));
  }
}
