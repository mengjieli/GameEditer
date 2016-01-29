package main.data.events
{
	import flash.events.Event;

	public class LogEvent extends Event
	{
		public static const ADD:String = "add";
		public static const SHIFT:String = "shift";
		public static const CLEAR:String = "clear";
		
		public var content:String;
		public var color:uint;
		
		public function LogEvent(type:String,content:String="",color:uint=0)
		{
			this.content = content;
			this.color = color;
			super(type);
		}
	}
}