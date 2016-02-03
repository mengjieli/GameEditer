package main.events
{
	import flash.events.Event;
	
	import main.data.directionData.DirectionDataBase;

	public class DirectionEvent extends Event
	{
		public static const SHOW_FILE:String = "show_file";
		
		public var file:DirectionDataBase;
		
		public function DirectionEvent(type:String,file:DirectionDataBase=null)
		{
			super(type);
			this.file = file;
		}
	}
}