public class Test {
    public String name;

    public Test() { this("nothing"); }
    public Test(String _n) { this.name = _n; System.out.println(this.name + " standby"); }

    public void v() { System.out.println(this.name + ": void test"); return; }
    public long l(long l) { System.out.println(this.name + ": long test"); return 2*l; }
    public double d(double d) { System.out.println(this.name + ":double test"); return 10*d; }
    //
    public String s(String s) { System.out.println(this.name + ": string test"); return ("hello " + s); }
    public long[] lv(long[] lv) {  System.out.println(this.name + ": lvector test"); for ( int i=0; i<lv.length; i++ ) lv[i] = 2*lv[i]; return lv; }
    public double[] dv(double[] dv) {  System.out.println(this.name + ": dvector test"); for ( int i=0; i<dv.length; i++ ) dv[i] = 10*dv[i]; return dv; }
}
