// _JCP=`rospack find eus_java`/3rdparty CLASSPATH=${_JCP}/joptimizer-4.0.0.jar:${_JCP}/ParallelColt/parallelcolt-0.9.4.jar:`pwd` javac JOptimizer_test.java

import com.joptimizer.optimizers.JOptimizer;
import com.joptimizer.optimizers.OptimizationRequest;
import com.joptimizer.functions.ConvexMultivariateRealFunction;
import com.joptimizer.functions.LinearMultivariateRealFunction;

public class JOptimizer_test {

    public static void main(String[] args) throws Exception {

        // Objective function (plane)
        LinearMultivariateRealFunction objectiveFunction = new LinearMultivariateRealFunction(new double[] {3.0, 4.0}, 0); //minimize 3x+4y

        //inequalities (polyhedral feasible set G.X<H )
        ConvexMultivariateRealFunction[] inequalities = new ConvexMultivariateRealFunction[4];
        // x >= 0
        inequalities[0] = new LinearMultivariateRealFunction(new double[]{-1.0, 0.00}, 0.0);  // focus: -x+0 <= 0 
        // y >= 0
        inequalities[1] = new LinearMultivariateRealFunction(new double[]{0.0, -1.00}, 0.0);  // focus: -y+0 <= 0
        // 2x+3y >= 8
        inequalities[2] = new LinearMultivariateRealFunction(new double[]{-2.0, -3.00}, 8.0); // focus: -2x-3y+8 <= 0
        // 5x+2y >= 12
        inequalities[3] = new LinearMultivariateRealFunction(new double[]{-5.0, -2.00}, 12.0);// focus: -5x-2y+12 <= 0

        //optimization problem
        OptimizationRequest or = new OptimizationRequest();
        or.setF0(objectiveFunction);
        or.setFi(inequalities);
        //or.setInitialPoint(new double[] {0.0, 0.0});//initial feasible point, not mandatory
        or.setToleranceFeas(1.E-9);
        or.setTolerance(1.E-9);

        //optimization
        JOptimizer opt = new JOptimizer();
        opt.setOptimizationRequest(or);
	opt.optimize();

        double[] sol = opt.getOptimizationResponse().getSolution();

        System.out.println("Length: " + sol.length);
        for (int i=0; i<sol.length/2; i++){
            System.out.println( "X" + (i+1) + ": " + Math.round(sol[i]) + "\ty" + (i+1) + ": " + Math.round(sol[i+1]) );
        }
    }
}
