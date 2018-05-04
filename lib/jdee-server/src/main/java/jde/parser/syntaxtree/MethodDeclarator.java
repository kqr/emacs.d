//
// Generated by JTB 1.1.2
//

package jde.parser.syntaxtree;

/**
 * Grammar production:
 * <PRE>
 * f0 -> &lt;IDENTIFIER&gt;
 * f1 -> FormalParameters()
 * f2 -> ( "[" "]" )*
 * </PRE>
 */
public class MethodDeclarator implements Node {
   public NodeToken f0;
   public FormalParameters f1;
   public NodeListOptional f2;

   public MethodDeclarator(NodeToken n0, FormalParameters n1, NodeListOptional n2) {
      f0 = n0;
      f1 = n1;
      f2 = n2;
   }

   public void accept(jde.parser.visitor.Visitor v) {
      v.visit(this);
   }
}
