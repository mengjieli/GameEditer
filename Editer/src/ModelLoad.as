package
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import egret.ui.components.TabPanel;
	
	import main.data.ToolData;
	import main.data.parsers.ParserBase;
	import main.model.ModelBase;
	import main.panels.netWaitPanel.NetWaitingPanel;
	import main.ui.DefinePanel;
	
	import utils.FileHelp;
	
	public class ModelLoad extends EventDispatcher
	{
		private var list:Vector.<File> = new Vector.<File>();
		private var index:int;
		private var root:String;
		
		public function ModelLoad(url:String)
		{
			NetWaitingPanel.show("加载模块");
			root = File.applicationDirectory.url;
			var file:File = File.applicationDirectory.resolvePath(url);
			list = FileHelp.getFileListWidthEnd(file,"swf");
			
			index = 0;
			setTimeout(loadNextParser,0);
		}
		
		private function loadNextParser():void {
			if(index >= list.length) {	
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			var file:File = list[index];
			var url:String = file.url.slice(root.length,file.url.length);
			var load:Loader = new Loader();
			load.load(new URLRequest(url));
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadParserComplete);
		}
		
		private function onLoadParserComplete(e:Event):void {
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var panel:ModelBase = loaderInfo.content as ModelBase;
			try {
				if(panel) {
//					var className:String = flash.utils.getQualifiedClassName(panel);
//					var cls:* = loaderInfo.applicationDomain.getDefinition(className);
//					ToolData.getInstance().panels[panel.panelName] = cls;
					NetWaitingPanel.show("加载模块 " + panel.modelName);
				}
			} catch(err:Error) {
			}
			index++;
			setTimeout(loadNextParser,0);
		}
	}
}