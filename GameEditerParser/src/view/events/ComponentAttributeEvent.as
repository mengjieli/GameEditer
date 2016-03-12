package view.events
{
	import flash.events.Event;

	public class ComponentAttributeEvent extends Event
	{
		public static const CHILD_ATTRIBUTE_CHANGE:String = "child_attribute_change";
		
		public var value:*;
		
		public function ComponentAttributeEvent(type:String,value:*)
		{
			super(type);
			this.value = value;
		}
	}
}