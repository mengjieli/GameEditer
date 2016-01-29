package egret.utils.command
{
	import flash.events.Event;
	
	/**
	 * 脚本输出事件
	 * @author xzper
	 */
	public class CommandEvent extends Event
	{
		/**
		 * 标准输出
		 */
		public static const OUTPUT:String = "standard_output_data";
		
		/**
		 * 错误的输出
		 */
		public static const ERROR:String = "standard_error_data";
		
		public function CommandEvent(type:String , text:String = "")
		{
			super(type, bubbles, cancelable);
			this.text = text;
		}
		
		/**
		 * 输出的文本
		 */
		public var text:String = "";
		
		override public function clone():Event
		{
			var event:CommandEvent = new CommandEvent(type);
			event.text = this.text;
			return event;
		}
		
	}
}