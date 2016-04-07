package flower.binding.compiler.structs
{
	public class CallParams
	{
		public var type:String = "callParams";
		private var list:Array = [];
		
		public function CallParams()
		{
		}
		
		public function addParam(expr:Expr):void {
			list.push(expr);
		}
		
		public function addParamAt(expr:Expr,index:int):void {
			list.splice(index,0,expr);
		}
		
		public function checkPropertyBinding(checks:Array,commonInfo:Object):void {
			for(var i:int = 0; i < list.length; i++) {
				list[i].checkPropertyBinding(checks,commonInfo);
			}
		}
		
		public function getValueList():Array {
			var params:Array = [];
			for(var i:int = 0; i < list.length; i++) {
				params.push((list[i] as Expr).getValue());
			}
			return params;
		}
	}
}