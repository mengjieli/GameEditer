package
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import main.data.ToolData;
	import main.data.parsers.ParserBase;
	import main.panels.netWaitPanel.NetWaitingPanel;
	
	import utils.FileHelp;

	public class ParserLoad extends EventDispatcher
	{
		private var list:Vector.<File> = new Vector.<File>();
		private var index:int;
		private var root:String;
		
		public function ParserLoad(url:String)
		{
			ToolData.getInstance().deleteParsers();
			
			NetWaitingPanel.show("加载解析器");
			root = File.applicationDirectory.url;
			var file:File = File.applicationDirectory.resolvePath(url);
			list = FileHelp.getFileListWidthEnd(file,"swf");
			index = 0;
			setTimeout(loadNextParser,0);
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
			load.load(new URLRequest(url));
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadParserComplete);
		}
		
		private function onLoadParserComplete(e:Event):void {
			load.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadParserComplete);
			var parser:ParserBase = (e.currentTarget as LoaderInfo).content as ParserBase;
			parser.loader = load;
			try {
				if(parser) {
					ToolData.getInstance().parsers.push(parser);
					NetWaitingPanel.show("加载解析器 " + parser.parserName);
				}
			} catch(e:Error) {
			}
			index++;
			setTimeout(loadNextParser,0);
		}
	}
}