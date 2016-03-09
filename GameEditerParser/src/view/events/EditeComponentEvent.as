package view.events
{
	import flash.events.Event;
	
	import view.component.data.ComponentData;

	public class EditeComponentEvent extends Event
	{
		public static const EDITE_COMPOENET:String = "edite_component";
		public static const SHOW_COMPONENT_ATTRIBUTE:String = "show_component_attribute";
		
		public var component:ComponentData;
		
		public function EditeComponentEvent(type:String,compoenet:ComponentData)
		{
			super(type);
			this.component = compoenet;
		}
	}
}