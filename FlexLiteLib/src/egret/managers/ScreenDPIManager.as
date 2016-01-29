package egret.managers
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import egret.events.UIEvent;
	
	/**
	 * 屏幕DPI管理器。当stage的DPI发生改变时抛出事件。
	 * @author dom
	 */
	public class ScreenDPIManager
	{
		public function ScreenDPIManager()
		{
			
		}
		
		private var _stage:Stage;
		/**
		 * 舞台引用
		 */
		public function get stage():Stage
		{
			return _stage;
		}

		public function set stage(value:Stage):void
		{
			if(_stage==value)
				return;
			if(_stage)
			{
				_stage.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
			_stage = value;
			if(_stage)
			{
				contentsScaleFactor = _stage.contentsScaleFactor;
				_stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
		}
		
		private var contentsScaleFactor:Number = 1;
		
		private function onEnterFrame(event:Event):void
		{
			if(contentsScaleFactor==_stage.contentsScaleFactor)
				return;
			contentsScaleFactor = _stage.contentsScaleFactor;
			_stage.dispatchEvent(new UIEvent(UIEvent.SCREEN_DPI_CHANGED));
		}
		
	}
}