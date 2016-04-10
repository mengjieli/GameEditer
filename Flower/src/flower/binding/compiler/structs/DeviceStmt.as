package flower.binding.compiler.structs
{
	public class DeviceStmt
	{
		public function DeviceStmt()
		{
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(commonInfo:Object):void {
		}
		
		public function getValue():* {
			return null;
		}
	}
}