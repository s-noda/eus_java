public class Test {
    public String name;

    public void _log(String s) { System.out.println("[" + this.name + "]: " + s); }

    public Test() { this("nothing"); }
    public Test(String _n) { this.name = _n; this._log("standby"); }

    public void v() { this._log("void test"); return; }
    public long l(long l) { this._log("long test"); return 2*l; }
    public double d(double d) { this._log("double test"); return 10*d; }
    //
    public String s(String s) { this._log("string test"); return ("hello " + s); }
    public long[] lv(long[] lv) {  this._log("lvector test"); for ( int i=0; i<lv.length; i++ ) lv[i] = 2*lv[i]; return lv; }
    public double[] dv(double[] dv) {  this._log("dvector test"); for ( int i=0; i<dv.length; i++ ) dv[i] = 10*dv[i]; return dv; }
}
