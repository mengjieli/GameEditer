package view.component
{
	import egret.components.UIAsset;

	public class ComponentBase extends UIAsset
	{
		public function ComponentBase()
		{
		}
		
		private var _width:int;
		public function get a_width():int {
			return _width;
		}
		
		public function set a_width(val:int):void {
			_width = val;
		}
		
		private var _height:int;
		public function get a_height():int {
			return _height;
		}
		
		public function set a_height(val:int):void {
			_height = val;
		}
	}
}