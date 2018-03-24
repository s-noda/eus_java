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

    public void setInitialPoint(double[] x) { this.or.setInitialPoint(x); }
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
	double[][] G = new double[m][n];
	ConvexMultivariateRealFunction[] ie = new ConvexMultivariateRealFunction[m];
	for ( int i=0; i<m; i++ ) {
	    for ( int j=0; j<n; j++ ) G[i][j] = _G[i*n+j];
	    ie[i] = new LinearMultivariateRealFunction(G[i], h[i]); }
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
	jt.setInitialPoint(new double[]{1,1});
	jt.setQuadraticObjective(new double[]{1,0,0,1}, new double[]{0,0}, 0);
	if ( jt.optimize() > 0) {
	    double[] ret =jt.solution();
	    for ( int i=0; i<ret.length; i++ )
		System.out.println("x[" + i + "] = " + ret[i]);
	} else {
	    System.out.println("fail");
	}}

    // public static void main(String[] args) throws Exception {
    //     // Objective function (plane)
    //     LinearMultivariateRealFunction objectiveFunction = new LinearMultivariateRealFunction(new double[] {3.0, 4.0}, 0); //minimize 3x+4y
    //     //inequalities (polyhedral feasible set G.X<H )
    //     ConvexMultivariateRealFunction[] inequalities = new ConvexMultivariateRealFunction[4];
    //     // x >= 0
    //     inequalities[0] = new LinearMultivariateRealFunction(new double[]{-1.0, 0.00}, 0.0);  // focus: -x+0 <= 0 
    //     // y >= 0
    //     inequalities[1] = new LinearMultivariateRealFunction(new double[]{0.0, -1.00}, 0.0);  // focus: -y+0 <= 0
    //     // 2x+3y >= 8
    //     inequalities[2] = new LinearMultivariateRealFunction(new double[]{-2.0, -3.00}, 8.0); // focus: -2x-3y+8 <= 0
    //     // 5x+2y >= 12
    //     inequalities[3] = new LinearMultivariateRealFunction(new double[]{-5.0, -2.00}, 12.0);// focus: -5x-2y+12 <= 0
    //     //optimization problem
    //     OptimizationRequest or = new OptimizationRequest();
    //     or.setF0(objectiveFunction);
    //     or.setFi(inequalities);
    //     //or.setInitialPoint(new double[] {0.0, 0.0});//initial feasible point, not mandatory
    //     or.setToleranceFeas(1.E-9);
    //     or.setTolerance(1.E-9);
    //     //optimization
    //     JOptimizer opt = new JOptimizer();
    //     opt.setOptimizationRequest(or);
    // 	opt.optimize();
    //     double[] sol = opt.getOptimizationResponse().getSolution();
    //     System.out.println("Length: " + sol.length);
    //     for (int i=0; i<sol.length/2; i++){
    //         System.out.println( "X" + (i+1) + ": " + Math.round(sol[i]) + "\ty" + (i+1) + ": " + Math.round(sol[i+1]) );
    //     }
    // }
}
