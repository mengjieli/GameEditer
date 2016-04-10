package flower.binding.compiler.structs
{
	public class ObjectAtr
	{
		private var list:Array;
		
		public function ObjectAtr(list:Array)
		{
			this.list = list;
			for(var i:int = 0; i < list.length; i++) {
				list[i][0] = list[i][0].getValue();
			}
		}
		
		public function checkPropertyBinding(commonInfo:Object):void {
			for(var i:int = 0; i < list.length; i++) {
				list[i][1].checkPropertyBinding(commonInfo);
			}
		}
		
		public function getValue():* {
			var val:Object = {};
			for(var i:int = 0; i < list.length; i++) {
				val[list[i][0]] = list[i][1].getValue();
			}
			return val;
		}
	}
}