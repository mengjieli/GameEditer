package dataParser
{
	import flash.filesystem.File;
	
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	
	import utils.FileHelp;

	public class DataParser extends ParserBase
	{
		public function DataParser()
		{
		}
		
		override public function get parserName():String {
			return "Data";
		}
		
		public function addData(d:DirectionDataBase):void {
			trace("收到啦",d.url);
		}
		
		public function refreshDataResource(d:DirectionDataBase):void {
			var loads:Vector.<File> = FileHelp.getFileListWidthEnd(new File(ToolData.getInstance().project.getResURL(d.url)),["json"]);
			for(var i:int = 0; i < loads.length; i++) {
				var dir:DataData = new DataData();
				dir.url = ToolData.getInstance().project.getResDirectionURL(loads[i].url);
				if(dir.decode() == false) {
					continue;
				}
				dir.type = DirectionDataBase.FILE;
				dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
				//				dir.toolTip = loads[i].url;
				//				dir.toolTipClass = ImageLoaderToolTip;
				dir.reader = DataReader;
				ToolData.getInstance().project.addData(dir);
				var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
				e.direction = dir;
				EventMgr.ist.dispatchEvent(e);
			}
		}
		
		override public function get api():Object {
			return {"addData":addData,"refreshDataResource":refreshDataResource};
		}
	}
}