package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 关闭选项卡事件 
	 * @author 雷羽佳
	 * 
	 */	
	public class CloseTabEvent extends Event
	{
		/**
		 * 关闭当前
		 */
		public static const CLOSE:String = "CloseCurrent";
		
		/**
		 * 关闭其他
		 */		
		public static const CLOSE_OTHER:String = "CloseOther";
		
		/**
		 * 关闭全部
		 */		
		public static const CLOSE_ALL:String = "CloseAll";
		
		public function CloseTabEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}