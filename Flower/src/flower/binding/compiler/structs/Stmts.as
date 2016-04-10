package flower.binding.compiler.structs
{
	public class Stmts
	{
		public var type:String = "stmts";
		private var list:Array = [];
		
		public function Stmts()
		{
		}
		
		public function addStmt(stmt:*):void {
			list.push(stmt);
		}
		
		public function addStmtAt(stmt:*,index:int):void {
			list.splice(index,0,stmt);
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(commonInfo:Object):void {
			for(var i:int = 0; i < list.length; i++) {
				this.list[i].checkPropertyBinding(commonInfo);
			}
		}
		
		public function getValue():* {
			var value:*;
			for(var i:int = 0; i < list.length; i++) {
				if(i == 0) {
					value = list[i].getValue();
				} else {
					list[i].getValue();
				}
			}
			return value;
		}
		
	}
}