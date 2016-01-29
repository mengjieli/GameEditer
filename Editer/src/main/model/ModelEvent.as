package main.model
{
	import flash.events.Event;

	public class ModelEvent extends Event
	{
		public static const MENU:String = "menu";
		
		public var value:*;
		
		public function ModelEvent(type:String,value:*)
		{
			super(type);
			this.value = value;
		}
	}
}