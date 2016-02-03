package imageParser
{
	import flash.filesystem.File;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	
	import utils.FileHelp;

	public class ImageParser extends ParserBase
	{
		public function ImageParser()
		{
		}
		
		override public function get parserName():String {
			return "Image";
		}
		
		public function refreshUISource(d:DirectionDataBase):void {
			var loads:Vector.<File> = FileHelp.getFileListWidthEnd(new File(ToolData.getInstance().project.getResURL(d.url)),["png","jpg"]);
			for(var i:int = 0; i < loads.length; i++) {
				var dir:ImageData = new ImageData();
				dir.url = ToolData.getInstance().project.getResDirectionURL(loads[i].url);
				dir.type = DirectionDataBase.FILE;
				dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
//				dir.toolTip = loads[i].url;
//				dir.toolTipClass = ImageLoaderToolTip;
				dir.reader = new ImageReader();
				ToolData.getInstance().project.addData(dir);
				var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
				e.direction = dir;
				EventMgr.ist.dispatchEvent(e);
			}
		}
		
		override public function get api():Object {
			return {"refreshUISource":refreshUISource};
		}
	}
}