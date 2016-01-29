package egret.ui.core.FTEText.view
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * 光标 
	 * @author featherJ
	 * 
	 */	
	public class Ibeam extends Sprite
	{
		private var shape:Shape;
		public function Ibeam()
		{
			shape = new Shape();
			this.addChild(shape);
			updateIbeam();
			startFlicker();
		}
		
		private var _height:Number = 2;
		private var _width:Number = 2;
		private var _color:uint = 0xc5afbf;

		/**
		 * 光标颜色 
		 */		
		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			updateIbeam();
		}

		/**
		 * 光标宽度 
		 */		
		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			_width = value;
			updateIbeam();
		}

		/**
		 * 光标高度 
		 */		
		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			_height = value;
			updateIbeam();
		}
		
		/**
		 * 更新光标 
		 */		
		private function updateIbeam():void
		{
			shape.graphics.clear();
			shape.graphics.beginFill(_color);
			shape.graphics.drawRect(0,0,_width,_height);
			shape.graphics.endFill();
		}
		
		/**
		 * 开始闪烁 
		 * 
		 */		
		public function startFlicker():void
		{
			shape.visible = true;
			_timeStamp = getTimer();
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		
		private var _timeStamp:int = 0;
		protected function enterFrameHandler(event:Event):void
		{
			if(getTimer()-_timeStamp>500)
			{
				shape.visible = !shape.visible;
				_timeStamp = getTimer();
			}
		}
		/**
		 * 停止闪烁 
		 * 
		 */		
		public function stopFlicker():void
		{
			shape.visible = true;
			this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}

	}
}