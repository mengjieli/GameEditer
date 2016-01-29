package main.data.gameProject
{
	import main.data.gameProject.path.PathData;
	import main.data.gameProject.resource.ImageData;
	import main.data.gameProject.resource.SpriteSheetData;

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
		public var paths:Vector.<PathData> = new Vector.<PathData>();
		public var images:Vector.<ImageData> = new Vector.<ImageData>();
		public var spriteSheets:Vector.<SpriteSheetData> = new Vector.<SpriteSheetData>();
		
		public var name:String;
		
		/**
		 * 项目目录,url末尾带符号"/"
		 */
		public var url:String;
		public var res:String;
		public var src:String;
		
		public function GameProjectData()
		{
			var path:PathData;
			
			path = new PathData();
			path.virtual = true;
			path.desc = "模块";
			path.url = "model";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "游戏模板";
			path.url = "model/game";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "小游戏";
			path.url = "model/game/box";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "连连看";
			path.url = "model/game/box/pm";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "三消";
			path.url = "model/game/box/td";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "塔防";
			path.url = "model/game/td";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "ARPG";
			path.url = "model/game/arpg";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "RPG";
			path.url = "model/game/rpg";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "角色";
			path.url = "model/game/rpg/roler";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "地图";
			path.url = "model/game/rpg/map";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "格斗";
			path.url = "model/game/fig";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "模拟经营";
			path.url = "model/game/sim";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "即时战略";
			path.url = "model/game/rts";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "地图";
			path.url = "model/game/rts/map";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "地图元素";
			path.url = "model/game/rts/mapItem";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "角色";
			path.url = "model/game/rts/mapItem/roler";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "物件";
			path.url = "model/game/rts/mapItem/item";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "视图";
			path.url = "view";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "数据结构";
			path.url = "data";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "模块数据";
			path.url = "data/model";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "网络消息";
			path.url = "data/net";
			paths.push(path);
			
			
			path = new PathData();
			path.virtual = true;
			path.desc = "配置";
			path.url = "config";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "表格";
			path.url = "config/table";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "语言配置";
			path.url = "config/language";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "UI";
			path.url = "config/language/ui";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "错误码提示";
			path.url = "config/language/errorTip";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "用户名错误";
			path.url = "config/language/errorTip/nameError";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "用户名错误";
			path.url = "config/language/errorTip/nameError/chinese";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "NameInvalid";
			path.url = "config/language/errorTip/nameError/english";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "美术资源";
			path.url = "art";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "动画";
			path.url = "art/animtaion";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "图片";
			path.url = "art/image";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "";
			path.url = "art/image/SpriteSheet";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "UI组件";
			path.url = "art/image/ui";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "面板";
			path.url = "art/image/ui/panel";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "按钮";
			path.url = "art/image/ui/button";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "UI组件样式";
			path.url = "art/uiSkin";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "面板样式";
			path.url = "art/uiSkin/panel";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "按钮样式";
			path.url = "art/uiSkin/button";
			paths.push(path);
			
			path = new PathData();
			path.virtual = true;
			path.desc = "逐帧动画";
			path.url = "art/animtaion/framebyframe";
			paths.push(path);
		}
		
	}
}