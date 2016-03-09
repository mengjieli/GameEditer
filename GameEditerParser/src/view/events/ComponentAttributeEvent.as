package view.events
{
	import flash.events.Event;

	public class ComponentAttributeEvent extends Event
	{
		public var value:*;
		
		public function ComponentAttributeEvent(type:String,value:*)
		{
			super(type);
			this.value = value;
		}
	}
}