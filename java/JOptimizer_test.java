import com.joptimizer.optimizers.JOptimizer;
import com.joptimizer.optimizers.OptimizationRequest;
import com.joptimizer.optimizers.LPOptimizationRequest;
import com.joptimizer.functions.ConvexMultivariateRealFunction;
import com.joptimizer.functions.LinearMultivariateRealFunction;
import com.joptimizer.functions.PDQuadraticMultivariateRealFunction;
import com.joptimizer.exception.JOptimizerException;

public class JOptimizer_test {

    public OptimizationRequest or;
    public JOptimizer opt;

    public JOptimizer_test() {
	System.out.println("JOptimizer_test initialized");
	opt = new JOptimizer();
    }

    public void initOptiizationRequest() { or = new OptimizationRequest(); }

    public void echoOptimizationSettings() {
	System.out.println("itter < " + this.or.getMaxIteration());
	System.out.println("KKT   ? " + this.or.isCheckKKTSolutionAccuracy());
    }
    public void setInitialPoint(double[] x) { this.or.setInitialPoint(x); }
    public void disableKKT() { this.or.setCheckKKTSolutionAccuracy(false); this.or.setCheckProgressConditions(false); }
    public void setTolerance(double r) {
	this.or.setToleranceKKT(r); this.or.setToleranceFeas(r); this.or.setTolerance(r); }
    public void setQuadraticObjective(double[] _P, double[] q, double r) {
	// xPx/2 + qx + r
	int n = q.length;
	double[][] P = new double[n][n];
	for ( int i=0; i<n; i++ ) for ( int j=0; j<n; j++ ) P[i][j] = _P[i*n+j];
	PDQuadraticMultivariateRealFunction objectiveFunction = new PDQuadraticMultivariateRealFunction(P, q, r);
	this.or.setF0(objectiveFunction); }
    public void setLinearEquality(double[] _A, double[] b) {
	//equalities Ax=b
	int m = b.length; int n = _A.length/m;
	double[][] A = new double[m][n];
	for ( int i=0; i<m; i++ ) for ( int j=0; j<n; j++ ) A[i][j] = _A[i*n+j];
	this.or.setA(A); this.or.setB(b); }
    public void setLinearInequality(double[] _G, double[] h) {
	//inequalities Gx < h
	int m = h.length; int n = _G.length/m;
	ConvexMultivariateRealFunction[] ie = new ConvexMultivariateRealFunction[m];
	for ( int i=0; i<m; i++ ) {
	    double[] G = new double[n];
	    for ( int j=0; j<n; j++ ) G[j] = _G[i*n+j];
	    ie[i] = new LinearMultivariateRealFunction(G, h[i]); }
	this.or.setFi(ie); }
    public void setLinearMinMaxInequality(double[] _G, double[] lh, double[] uh) {
	//inequalities lh < Gx < uh
	int m = lh.length; int n = _G.length/m;
	ConvexMultivariateRealFunction[] ie = new ConvexMultivariateRealFunction[2*m];
	for ( int i=0; i<m; i++ ) {
	    double[] lG = new double[n];
	    double[] uG = new double[n];
	    for ( int j=0; j<n; j++ ) {
		uG[j] = _G[i*n+j]; lG[j] = -1 * _G[i*n+j]; }
	    ie[2*i] = new LinearMultivariateRealFunction(uG, uh[i]);
	    ie[2*i+1] = new LinearMultivariateRealFunction(lG, -1*lh[i]);}
	this.or.setFi(ie); }
    // public void setLinearInequality(double[] _G, double[] h) {
    // 	//inequalities Gx < h
    // 	int m = h.length; int n = _G.length/m;
    // 	double[][] G = new double[m][n];
    // 	for ( int i=0; i<m; i++ ) for ( int j=0; j<n; j++ ) G[i][j] = _G[i*n+j];
    // 	this.or.setG(G); this.or.setH(h); }
    // public void setBound(double[] lb, double[] ub) {
    // 	this.or.setLb(lb);
    // 	this.or.setUb(ub); }
    public long optimize()  {
	this.opt.setOptimizationRequest(this.or);
	try {
	    this.opt.optimize();
	    return 1;
	} catch(JOptimizerException e) {
	    e.printStackTrace();
	    return -1;
	}}
    public double[] solution() {
	return this.opt.getOptimizationResponse().getSolution(); }

    public static void main(String[] arg) {
	JOptimizer_test jt = new JOptimizer_test();
	jt.initOptiizationRequest();
	jt.setTolerance(1e-3);
	jt.disableKKT();
	jt.setInitialPoint(new double[]{1,1});
	jt.setQuadraticObjective(new double[]{1,1,0,1}, new double[]{0,0}, 0);
	jt.echoOptimizationSettings();
	if ( jt.optimize() > 0) {
	    double[] ret =jt.solution();
	    for ( int i=0; i<ret.length; i++ )
		System.out.println("x[" + i + "] = " + ret[i]);
	} else {
	    System.out.println("fail");
	}}
}
