public class Test {
    public String name;

    public Test() { this("nothing"); }
    public Test(String _n) { this.name = _n; System.out.println(this.name + " standby"); }

    public void v() { System.out.println(this.name + ": void test"); return; }
    public int i(int i) { System.out.println(this.name + ": int test"); return 2*i; }
    public double d(double d) { System.out.println(this.name + ":double test"); return 10*d; }
    //
    public String s(String s) { System.out.println(this.name + ": string test"); return ("hello " + s); }
    public int[] iv(int[] iv) {  System.out.println(this.name + ": ivector test"); for ( int i=0; i<iv.length; i++ ) iv[i] = 2*iv[i]; return iv; }
    public double[] dv(double[] dv) {  System.out.println(this.name + ": dvector test"); for ( int i=0; i<dv.length; i++ ) dv[i] = 10*dv[i]; return dv; }
}
