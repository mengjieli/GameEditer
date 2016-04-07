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
		
		public function execute():* {
			
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(checks:Array,commonInfo:Object):void {
			if(checks == null) {
				return;
			}
			for(var i:int = 0; i < list.length; i++) {
				this.list[i].checkPropertyBinding(checks,commonInfo);
			}
		}
	}
}