package main.events
{
	import flash.events.Event;
	
	import main.data.gameProject.GameProjectData;

	public class ProjectEvent extends Event
	{
		public static const LOAD_PROJECT:String = "load_project";
		public static const SHOW_PROJECT:String = "show_project";
		
		public var project:GameProjectData;
		
		public function ProjectEvent(type:String,project:GameProjectData=null)
		{
			super(type);
			this.project = project;
		}
	}
}