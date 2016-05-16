package sqlx;

import utest.Runner;
import utest.ui.Report;

class TestAll {
  static function addTests(runner : Runner) {
  }

  public static function main() {
    var runner = new Runner();
    addTests(runner);
    Report.create(runner);
    runner.run();
  }
}
