package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 键盘事件
	 * @author featherJ
	 * 
	 */	
	public class FTEKeyboardEvent extends Event
	{
		/**
		 * 键盘按下 
		 */		
		public static const FTE_KEY_DOWN:String = "fteKeyDown"
		
		public function FTEKeyboardEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
		/**
		 * 按下或释放的键的键控代码值。 
		 */		
		public var keyCode:int;
		
		override public function clone():Event
		{
			var event:FTEKeyboardEvent = new FTEKeyboardEvent(type,bubbles,cancelable);
			event.keyCode = keyCode;
			return event;
		}
	}
}