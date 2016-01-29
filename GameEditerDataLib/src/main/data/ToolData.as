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
		
		public var project:GameProjectData;
		
		public function ToolData()
		{
		}
		
		public function showProject(p:GameProjectData):void {
			this.project = p;
			EventMgr.ist.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PROJECT,p));
		}
		
		public function createGameProject(name:String,url:String,res:String,src:String):void {
			var p:GameProjectData = new GameProjectData();
			p.name = name;
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
			p.url = url + "/";
			p.src = url + "/" + src + "/";
			p.res = url + "/" + res + "/";
			EventMgr.ist.dispatchEvent(new ProjectEvent(ProjectEvent.LOAD_PROJECT,p));
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
			var exist:Boolean = FileUtil.exists(configURL);
			if(exist == false) {
				FileUtil.save(configURL,"{}");
			}
			var file:FileStream = FileUtil.open("configs/" + configName + ".txt");
			var str:String = file.readUTFBytes(file.bytesAvailable);
			file.close();
			var json:Object = JSON.parse(str);
			json[key] = value;
			FileUtil.save(configURL,JSON.stringify(json));
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