package flower.binding.compiler.structs
{
	public class ExprStmt
	{
		public var type:String = "stmt_expr";
		private var expr:Expr;
		
		public function ExprStmt(expr:Expr)
		{
			this.expr = expr;
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(commonInfo:Object):void {
			this.expr.checkPropertyBinding(commonInfo);
		}
		
		public function getValue():* {
			return expr.getValue();
		}
	}
}