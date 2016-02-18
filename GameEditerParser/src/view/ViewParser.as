package view
{
	import flash.filesystem.File;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	
	import utils.FileHelp;

	public class ViewParser extends ParserBase
	{
		public function ViewParser()
		{
		}
		
		override public function get parserName():String {
			return "View";
		}
		
		private function add(d:DirectionDataBase):void {
			(new AddViewPanel(d,addBack)).open(false);
		}
		
		private function addBack(d:DirectionDataBase,name:String,desc:String):void {
			var dir:ViewData = new ViewData();
			dir.url = d.url + "/" + name + ".json";
			dir.desc = desc;
			dir.type = DirectionDataBase.FILE;
			//dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
			dir.save();
			dir.reader = ViewReader;
			ToolData.getInstance().project.addData(dir);
			var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
			e.direction = dir;
			EventMgr.ist.dispatchEvent(e);
		}
		
		private function refreshDirection(d:DirectionDataBase):void {
			var loads:Vector.<File> = FileHelp.getFileListWidthEnd(new File(ToolData.getInstance().project.getResURL(d.url)),["json"]);
			for(var i:int = 0; i < loads.length; i++) {
				var dir:ViewData = new ViewData();
				dir.url = ToolData.getInstance().project.getResDirectionURL(loads[i].url);
				if(dir.decode() == false) {
					continue;
				}
				dir.type = DirectionDataBase.FILE;
				//dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
				dir.reader = ViewReader;
				ToolData.getInstance().project.addData(dir);
				var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
				e.direction = dir;
				EventMgr.ist.dispatchEvent(e);
			}
		}
		
		override public function get api():Object {
			return {"add":add,"refreshDirection":refreshDirection};
		}
	}
}