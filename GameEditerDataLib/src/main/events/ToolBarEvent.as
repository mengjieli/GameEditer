package main.events
{
	import flash.events.Event;

	public class ToolBarEvent extends Event
	{
		public static var CLICK:String = "click";
		
		public var name:String;
		
		public function ToolBarEvent(name)
		{
			super(CLICK);
			this.name = name;
		}
	}
}