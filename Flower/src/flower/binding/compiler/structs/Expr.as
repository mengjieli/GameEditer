package flower.binding.compiler.structs
{
	/**
	 * 表达式
	 */
	public class Expr
	{
		private var type:String;
		private var expr1:*;
		private var expr2:*;
		private var expr3:*;
		
		public function Expr(type:String,expr1:*=null,expr2:*=null,expr3:*=null)
		{
			this.type = type;
			this.expr1 = expr1;
			this.expr2 = expr2;
			this.expr3 = expr3;
			if(type == "int") {
				this.expr1 = parseInt(expr1);
			}
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(commonInfo:Object):void {
			if(type == "Atr") {
				(this.expr1 as ExprAtr).checkPropertyBinding(commonInfo);
			}
			if(expr1 && expr1 is Expr) {
				(expr1 as Expr).checkPropertyBinding(commonInfo);
			}
			if(expr2 && expr2 is Expr) {
				(expr2 as Expr).checkPropertyBinding(commonInfo);
			}
			if(expr3 && expr3 is Expr) {
				(expr3 as Expr).checkPropertyBinding(commonInfo);
			}
		}
		
		public function getValue():* {
			if(type == "Atr") {
				return expr1.getValue();
			}
			if(type == "int") {
				return expr1;
			}
			if(type == "0xint") {
				return expr1;
			}
			if(type == "number") {
				return expr1;
			}
			if(type == "boolean") {
				return expr1;
			}
			if(type == "string") {
				return expr1;
			}
			if(type == "+a") {
				return expr1.getValue();
			}
			if(type == "-a") {
				return -expr1.getValue();
			}
			if(type == "!") {
				return !expr1.getValue();
			}
			if(type == "*") {
				return expr1.getValue()*expr2.getValue();
			}
			if(type == "/") {
				return expr1.getValue()/expr2.getValue();
			}
			if(type == "%") {
				return expr1.getValue()%expr2.getValue();
			}
			if(type == "+") {
				return expr1.getValue()+expr2.getValue();
			}
			if(type == "-") {
				return expr1.getValue()-expr2.getValue();
			}
			if(type == "<<") {
				return expr1.getValue()<<expr2.getValue();
			}
			if(type == ">>") {
				return expr1.getValue()>>expr2.getValue();
			}
			if(type == ">>>") {
				return expr1.getValue()>>>expr2.getValue();
			}
			if(type == ">") {
				return expr1.getValue()>expr2.getValue();
			}
			if(type == "<") {
				return expr1.getValue()<expr2.getValue();
			}
			if(type == ">=") {
				return expr1.getValue()>=expr2.getValue();
			}
			if(type == "<=") {
				return expr1.getValue()<=expr2.getValue();
			}
			if(type == "==") {
				return expr1.getValue()==expr2.getValue();
			}
			if(type == "===") {
				return expr1.getValue()===expr2.getValue();
			}
			if(type == "!==") {
				return expr1.getValue()!==expr2.getValue();
			}
			if(type == "!=") {
				return expr1.getValue()!=expr2.getValue();
			}
			if(type == "&") {
				return expr1.getValue()&expr2.getValue();
			}
			if(type == "~") {
				return ~expr1.getValue();
			}
			if(type == "^") {
				return expr1.getValue()^expr2.getValue();
			}
			if(type == "|") {
				return expr1.getValue()|expr2.getValue();
			}
			if(type == "&&") {
				return expr1.getValue()&&expr2.getValue();
			}
			if(type == "||") {
				return expr1.getValue()||expr2.getValue();
			}
			if(type == "?:") {
				return expr1.getValue()?expr2.getValue():expr3.getValue();
			}
			return null;
		}
	}
}