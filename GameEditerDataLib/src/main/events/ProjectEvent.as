package main.events
{
	import flash.events.Event;
	
	import main.data.directionData.DirectionDataBase;
	import main.data.gameProject.GameProjectData;

	public class ProjectEvent extends Event
	{
		public static const LOAD_PROJECT:String = "load_project";
		public static const SHOW_PROJECT:String = "show_project";
		public static const ADD_DIRECTION:String = "add_direction";
		
		public var projectURL:String;
		public var project:GameProjectData;
		public var direction:DirectionDataBase;
		
		public function ProjectEvent(type:String,project:GameProjectData=null,projectURL:String=null)
		{
			super(type);
			this.project = project;
			this.projectURL = projectURL;
		}
	}
}