package egret.utils.maxRects
{
	/**
	 * MaxRect算法用的矩形数据 
	 * @author featherJ
	 * 
	 */	
	public class MaxRectangle implements IMaxRectangle
	{
		private var _x:Number=0;
		public function set x(v:Number):void
		{
			_x=v;
		}
		public function get x():Number
		{
			return _x;
		}
		private var _y:Number=0;
		public function set y(v:Number):void
		{
			_y=v;
		}
		public function get y():Number
		{
			return _y;
		}
		private var _width:Number=0;
		public function set width(v:Number):void
		{
			_width=v;
		}
		public function get width():Number
		{
			return _width;
		}
		private var _height:Number=0;
		public function set height(v:Number):void
		{
			_height=v;
		}
		public function get height():Number
		{
			return _height;
		}
		/**
		 * 携带的数据内容 
		 */		
		private  var _data:Object;
		public function set data(v:Object):void
		{
			_data=v;
		}
		public function get data():Object
		{
			return _data;
		}
		/**
		 * 是否旋转了 
		 */		
		private  var _isRotated:Boolean = false;
		public function set isRotated(v:Boolean):void
		{
			_isRotated=v;
		}
		public function get isRotated():Boolean
		{
			return _isRotated;
		}
		
		public function MaxRectangle(x:Number = 0,y:Number = 0,width:Number = 0,height:Number = 0,data:Object = null)
		{
			_x=x;
			_y=y;
			_width=width;
			_height=height;
			this.data = data;
		}
		public function cloneOne():IMaxRectangle
		{
			var cloneRect:MaxRectangle = new MaxRectangle();
			cloneRect.x=_x;
			cloneRect.y=_y;
			cloneRect.width=_width;
			cloneRect.height=_height;
			cloneRect.data = this.data;
			cloneRect.isRotated = this.isRotated;
			return cloneRect;
		}
		public function newOne():IMaxRectangle
		{
			return new MaxRectangle();
		}
	}
}