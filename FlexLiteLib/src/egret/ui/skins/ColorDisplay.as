package egret.ui.skins
{
	import flash.display.Shape;

	/**
	 * 取色器的颜色展示模块儿 
	 * @author 雷羽佳
	 * 
	 */	
	public class ColorDisplay extends Shape
	{
		
		private var _color:uint = 0x009aff;
		
		private var _strokeColor:uint = 0xffffff;
		
		public function ColorDisplay()
		{
			draw();
		}
		
		/**
		 * 线条颜色
		 * @return 
		 * 
		 */		
		public function get strokeColor():uint
		{
			return _strokeColor;
		}

		public function set strokeColor(value:uint):void
		{
			_strokeColor = value;
			draw();
		}

		/**
		 * 填充颜色 
		 * @return 
		 * 
		 */		
		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			draw();
		}
		
		private function draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1,_strokeColor);
			this.graphics.beginFill(_color);
			this.graphics.drawRect(0,0,10,10);
			this.graphics.endFill();
		}

	}
}