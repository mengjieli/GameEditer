package view.events
{
	import flash.events.Event;
	
	import view.component.data.ComponentData;

	public class GroupEvent extends Event
	{
		public static const SET_CHILD_INDEX:String = "set_child_index";
		public static const ADD_CHILD:String = "add_child";
		public static const REMOVE_CHILD:String = "remove_child";
		
		public var child:ComponentData;
		public var index:int;
		
		public function GroupEvent(type:String,child:ComponentData,index:int)
		{
			super(type);
			this.child = child;
			this.index = index;
		}
	}
}