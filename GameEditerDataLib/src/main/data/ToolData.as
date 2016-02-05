package main.data
{
	import flash.filesystem.FileStream;
	
	import egret.utils.FileUtil;
	
	import main.data.gameProject.GameProjectData;
	import main.data.parsers.ParserBase;
	import main.events.EventMgr;
	import main.events.ProjectEvent;

	public class ToolData
	{
		private var configURL:String = "configs/config.txt";
		public var server:*;
		public var mobile:MobileData = new MobileData();
		public var log:LogData = new LogData();
		public var parsers:Vector.<ParserBase> = new Vector.<ParserBase>();
		public var panels:Object = {};
		
		public var project:GameProjectData;
		
		public function ToolData()
		{
		}
		
		public function showProject(p:GameProjectData):void {
			this.project = p;
			EventMgr.ist.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PROJECT,this.project));
		}
		
		public function createGameProject(name:String,url:String,res:String,src:String):void {
//			var p:GameProjectData = new GameProjectData();
//			p.name = name;
			if(url.charAt(url.length-1) == "/") {
				url = url.slice(0,url.length-1);
			}
			if(src.charAt(src.length-1) == "/") {
				src = src.slice(0,src.length-1);
			}
			if(res.charAt(res.length-1) == "/") {
				res = res.slice(0,res.length-1);
			}
			var config:Object = {
				"name":name,
				"res":res,
				"src":src
			};
			FileUtil.save(url + "/GameProject.json",JSON.stringify(config));
//			p.url = url + "/";
//			p.src = url + "/" + src + "/";
//			p.res = url + "/" + res + "/";
			EventMgr.ist.dispatchEvent(new ProjectEvent(ProjectEvent.LOAD_PROJECT,null,url));
		}
		
		public function getParser(name:String):ParserBase {
			for(var i:int = 0; i < parsers.length; i++) {
				if(parsers[i].parserName == name) {
					return parsers[i];
				}
			}
			return null;
		}
		
		public function deleteParsers():void {
			while(parsers.length) {
				var parser:ParserBase = parsers.pop();
				parser.unload();
			}
		}
		
		public function deleteParser(name:String):void {
			for(var i:int = 0; i < parsers.length; i++) {
				if(parsers[i].parserName == name) {
					var parser:ParserBase = parsers[i];
					parsers.splice(i,1);
					break;
				}
			}
		}
		
		public function getPanel(name:String):Class {
			return this.panels[name];
		}
		
		/**
		 * 获取配置文件
		 */
		public function getConfigValue(key:String,configName:String="config"):* {
			var exist:Boolean = FileUtil.exists(configURL);
			if(exist == false) {
				FileUtil.save(configURL,"{}");
				return "";
			}
			var file:FileStream = FileUtil.open("configs/" + configName + ".txt");
			var str:String = file.readUTFBytes(file.bytesAvailable);
			file.close();
			var json:Object = JSON.parse(str);
			return json[key];
		}
		
		public function saveConfigValue(key:String,value:*,configName:String="config"):void {
			var url:String = "configs/" + configName + ".txt";
			var exist:Boolean = FileUtil.exists(url);
			if(exist == false) {
				FileUtil.save(url,"{}");
			}
			var file:FileStream = FileUtil.open(url);
			var str:String = file.readUTFBytes(file.bytesAvailable);
			file.close();
			var json:Object = JSON.parse(str);
			json[key] = value;
			FileUtil.save(url,JSON.stringify(json));
		}
		
		private static var ist:ToolData;
		public static function getInstance():ToolData {
			if(!ist) {
				ist = new ToolData();
			}
			return ist;
		}
	}
}