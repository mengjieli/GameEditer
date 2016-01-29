package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 文本编辑器视区事件 
	 * @author featherJ
	 * 
	 */	
	public class FTEViewPortEvent extends Event
	{
		/**
		 * 视区改变 
		 */		
		public static const VIEWPORT_CHANGED_V:String = "viewportChangedV";
		/**
		 * 视区改变 
		 */	
		public static const VIEWPORT_CHANGED_H:String = "viewportChangedH";
		/**
		 * 视区改变 
		 */	
		public static const VIEWPORT_CHANGED_W:String = "viewportChangedW";
		public function FTEViewPortEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
	}
}