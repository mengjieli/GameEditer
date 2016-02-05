package main.data.gameProject
{
	import egret.utils.FileUtil;
	
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.MenuData;
	import main.data.parsers.ParserBase;
	import main.data.parsers.ParserCall;
	import main.data.parsers.QuickMenu;

	/**
	 * RPG(角色扮演类游戏)
ACT(动作类游戏)
FPS(射击类游戏)
FIG(格斗类游戏)
SLG(策略模拟类)
RAC(赛车类现在应该称为竞速类游戏)
AVG(解迷冒险类)
SIM（模拟经营类）
SPT(体育类)
RTS（即时战略）
Online Game(网络游戏)
EDU（养成类）
	 */
	public class GameProjectData
	{
		public var name:String;
		private var list:Vector.<DirectionDataBase> = new Vector.<DirectionDataBase>();
		
		/**
		 * 项目目录,url末尾带符号"/"
		 */
		public var url:String;
		public var res:String;
		public var src:String;
		
		public function GameProjectData()
		{
			
		}
		
		/**
		 * 通过相对目录返回本机绝对目录
		 */
		public function getResURL(url:String):String {
			return res + url;
		}
		
		/**
		 * 通过绝对目录返回本机相对目录
		 */
		public function getResDirectionURL(url:String):String {
			return url.slice(res.length,url.length);
		}
		
		public function getInitPath():Vector.<DirectionDataBase> {
			var res:Vector.<DirectionDataBase> = new Vector.<DirectionDataBase>();
			var list:Array = JSON.parse(FileUtil.openAsString("configs/direction.json")) as Array;
			for(var i:int = 0; i < list.length; i++) {
				var data:Object = list[i];
				var p:DirectionDataBase = new DirectionDataBase();
				p.initWidthDirection();
				p.desc = data.desc;
				p.url = data.url;
				if(data.openIcon) p.directionOpenIcon = data.openIcon;
				if(data.closeIcon) p.directionCloseIcon = data.closeIcon;
				if(data.initLoad) p.initLoad = new ParserCall(data.initLoad.name,data.initLoad.api);
				var quickDataList:Array = data.quickMenu;
				var q:int;
				var parser:ParserBase;
				if(quickDataList) {
					for(q = 0; q < quickDataList.length; q++) {
						var quickData:Object = quickDataList[q];
						var quckMenu:QuickMenu = new QuickMenu();
						quckMenu.icon = quickData.icon;
						quckMenu.toolTip = quickData.toolTip;
						if(quickData.click) {
							quckMenu.clickFunction = new ParserCall(quickData.click.name,quickData.click.api);
						}
						p.quickMenu.push(quckMenu);
					}
				}
				var menuList:Array = data.menu;
				if(menuList) {
					for(q = 0; q < menuList.length; q++) {
						var menuData:Object = menuList[q];
						var menu:MenuData = new MenuData();
						menu.name = menuData.name;
						if(menuData.click) {
							menu.clickFunction = new ParserCall(menuData.click.name,menuData.click.api);
						}
						p.menu.push(menu);
					}
				}
				res.push(p);
			}
			return res;
		}
		
		public function addData(d:DirectionDataBase):void {
			this.list.push(d);
		}
		
		private function test():void {
		}
		
	}
}