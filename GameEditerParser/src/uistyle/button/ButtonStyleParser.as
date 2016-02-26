package uistyle.button
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import dataParser.DataData;
	import dataParser.DataReader;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	
	import uistyle.AddStylePanel;
	
	import utils.FileHelp;
	

	public class ButtonStyleParser extends ParserBase
	{
		public function ButtonStyleParser()
		{
		}
		
		override public function get parserName():String {
			return "ButtonStyle";
		}
		
		private function add(d:DirectionDataBase):void {
			(new AddStylePanel("添加按钮样式",d,addBack)).open(false);
		}
		
		override public function parseToFixConfig(url:String):Object {
			var style:ButtonStyleData = new ButtonStyleData();
			style.url = url;
			if(style.decode()) {
				return {
					"class":"Button",
					"up":style.up.url,
					"down":style.down.url,
					"disabled":style.disabled.url
				}
			}
			return null;
		}
		
		private function addBack(d:DirectionDataBase,name:String,desc:String):void {
			var dir:ButtonStyleData = new ButtonStyleData();
			dir.url = d.url + "/" + name + ".json";
			dir.desc = desc;
			dir.type = DirectionDataBase.FILE;
			dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
			dir.save();
			dir.reader = ButtonStyleReader;
			ToolData.getInstance().project.addData(dir);
			var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
			e.direction = dir;
			EventMgr.ist.dispatchEvent(e);
		}
		
		private function refreshDirection(d:DirectionDataBase):void {
			var loads:Vector.<File> = FileHelp.getFileListWidthEnd(new File(ToolData.getInstance().project.getResURL(d.url)),["json"]);
			for(var i:int = 0; i < loads.length; i++) {
				var dir:ButtonStyleData = new ButtonStyleData();
				dir.url = ToolData.getInstance().project.getResDirectionURL(loads[i].url);
				if(dir.decode() == false) {
					continue;
				}
				dir.type = DirectionDataBase.FILE;
				dir.fileIcon = "assets/directionView/fileIcon/" + FileHelp.getURLEnd(dir.url) + ".png";
				dir.reader = ButtonStyleReader;
				ToolData.getInstance().project.addData(dir);
				var e:ProjectEvent = new ProjectEvent(ProjectEvent.ADD_DIRECTION,ToolData.getInstance().project);
				e.direction = dir;
				EventMgr.ist.dispatchEvent(e);
			}
		}
		
		override public function get api():Object {
			return {
				"add":add,
				"refreshDirection":refreshDirection
			};
		}
	}
}