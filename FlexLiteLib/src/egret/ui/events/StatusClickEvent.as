package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 状态栏的点击事件 
	 * @author 雷羽佳
	 * 
	 */	
	public class StatusClickEvent extends Event
	{
		public static const STATUS_CLICK:String = "statusClick";
		public var data:Object;
		public function StatusClickEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}