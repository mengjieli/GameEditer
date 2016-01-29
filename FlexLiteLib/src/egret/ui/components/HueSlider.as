package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import egret.components.VSlider;

	/**
	 * 色相滑块儿 
	 * @author 雷羽佳
	 * 
	 */	
	public class HueSlider extends VSlider
	{
		public function HueSlider()
		{
			super();
		}
		
		private var isMouseDown:Boolean = false;
		
		override protected function track_mouseDownHandler(event:MouseEvent):void
		{
			super.track_mouseDownHandler(event);
			isMouseDown = true;
			(systemManager as DisplayObject).addEventListener(MouseEvent.MOUSE_UP,system_mouseUpSomewhereHandler);
			setTimeout(startThumbDrag,50,event);
		}
		
		private function startThumbDrag(event:MouseEvent):void
		{
			if(isMouseDown)
			{
				thumb_mouseDownHandler(event);
			}
		}
		private function system_mouseUpSomewhereHandler(event:MouseEvent):void
		{

			(systemManager as DisplayObject).removeEventListener(MouseEvent.MOUSE_UP,system_mouseUpSomewhereHandler);
			isMouseDown = false;
		}
	}
}