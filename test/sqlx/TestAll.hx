package sqlx;

import utest.Runner;
import utest.ui.Report;

class TestAll {
  static function addTests(runner : Runner) {
    runner.addCase(new TestFormatter());
  }

  public static function main() {
    var runner = new Runner();
    addTests(runner);
    Report.create(runner);
    runner.run();
  }
}
