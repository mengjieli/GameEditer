package view.component
{
	import egret.components.Group;
	import egret.components.UIAsset;

	public class ComponentBase extends egret.components.Group
	{
		protected var show:UIAsset;
		protected var styleData:Object;
		
		public function ComponentBase()
		{
			show = new UIAsset();
			this.addElement(show);
		}
		
		public function decodeByStyle(style:Object,styleURL:String):void {
			
		}
		
		private var _width:int;
		public function get a_width():int {
			return _width;
		}
		
		public function set a_width(val:int):void {
			_width = val;
			this.show.width = _width;
		}
		
		private var _height:int;
		public function get a_height():int {
			return _height;
		}
		
		public function set a_height(val:int):void {
			_height = val;
			this.show.height = _height;
		}
		
		private var _x:int;
		public function set a_x(val:Number):void {
			_x = val;
			this.x = val;
		}
		
		public function get a_x():Number {
			return _x;
		}
		
		private var _y:int;
		public function set a_y(val:Number):void {
			_y = val;
			this.y = _y;
		}
		
		public function get a_y():Number {
			return _y;
		}
	}
}