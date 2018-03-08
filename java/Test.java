public class Test {

    public String name;

    public Test(String _n) { this.name = _n; }

    public void v() { System.out.println(this.name + ": void test"); return; }
    public int i(int i) { System.out.println(this.name + ": int test"); return 2*i; }
    public double d(double d) { System.out.println(this.name + ":double test"); return 10*d; }
    public String s(String s) { System.out.println(this.name + ": string test"); return ("hello " + s); }
}
