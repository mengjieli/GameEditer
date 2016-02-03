package main.events
{
	import flash.events.Event;

	public class ToolEvent extends Event
	{
		/**
		 * 登录完成
		 */
		public static var START:String = "start";
		
		public function ToolEvent(type:String)
		{
			super(type);
		}
	}
}