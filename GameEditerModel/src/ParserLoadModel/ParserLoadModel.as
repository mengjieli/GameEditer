package ParserLoadModel
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import main.data.ToolData;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ToolBarEvent;
	import main.model.ModelBase;
	
	import utils.FileHelp;

	public class ParserLoadModel extends ModelBase
	{
		private var list:Vector.<File> = new Vector.<File>();
		private var index:int;
		private var root:String;
		
		public function ParserLoadModel()
		{
//			NetWaitingPanel.show("加载模块");
//			EventMgr.ist.addEventListener(ToolBarEvent.CLICK,onClickToolBar);
		}
		
		private function onClickToolBar(e:ToolBarEvent):void {
			
			var url:String = "parsers/";
			root = File.applicationDirectory.url;
			var file:File = File.applicationDirectory.resolvePath(url);
			list = FileHelp.getFileListWidthEnd(file,"swf");
			
			ToolData.getInstance().deleteParsers();
			
			index = 0;
//			setTimeout(loadNextParser,0);
		}
		
		override public function get modelName():String {
			return "ParserLoadModel";
		}
		
		private var load:Loader;
		
		private function loadNextParser():void {
			if(index >= list.length) {
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			var file:File = list[index];
			var url:String = file.url.slice(root.length,file.url.length);
			load = new Loader();
			load.load(new URLRequest("../" + url));
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadParserComplete);
		}
		
		private function onLoadParserComplete(e:Event):void {
			load.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadParserComplete);
			var parser:ParserBase = (e.currentTarget as LoaderInfo).content as ParserBase;
			parser.loader = load;
//			parser.swf = (e.currentTarget as LoaderInfo).content as MovieClip;
			try {
				if(parser) {
					ToolData.getInstance().parsers.push(parser);
//					NetWaitingPanel.show("加载解析器 " + parser.parserName);
				}
			} catch(e:Error) {
			}
			index++;
			setTimeout(loadNextParser,0);
		}
	}
}