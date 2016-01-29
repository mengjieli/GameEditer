package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 文本选择改变事件
	 * @author featherJ
	 * 
	 */	
	public class FTETextSelectionEvent extends Event
	{
		/**
		 * 文本选择内容改变 
		 */		
		public static const TEXT_SELECTION_CHANGED:String = "textSelectionChanged";
		
		public function FTETextSelectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
	}
}