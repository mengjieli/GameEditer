package main.data.directionData
{
	
	import egret.components.UIAsset;
	
	import extend.ui.ImageLoader;
	
	import main.data.parsers.MenuData;
	import main.data.parsers.ParserCall;
	import main.data.parsers.ParserDataBase;
	import main.data.parsers.QuickMenu;
	import main.data.parsers.ReaderBase;
	
	import utils.FileHelp;

	public class DirectionDataBase
	{
		/**
		 * 文件夹类型
		 */
		public static const DIRECTION:String = "direction";
		/**
		 * 文件类型
		 */
		public static const FILE:String = "file";
		
		/**
		 * 类型，是文件夹还是文件类型
		 */
		public var type:String;
		
		/**
		 * 目录打开时的图标
		 */
		public var directionOpenIcon:String;
		/**
		 * 目录关闭时的图标
		 */
		public var directionCloseIcon:String;
		
		/**
		 * 文件图标
		 */
		public var fileIcon:String;
		
		
		/**
		 * url
		 */
		private var _url:String;
		
		/**
		 * 文件名描述
		 */
		public var desc:String = "";
		
		public var toolTip:*;
		public var toolTipClass:Class;
		
		/**
		 * 解析器数据
		 */
		public var data:ParserDataBase;
		
		/**
		 * 阅读器
		 */
		public var reader:Class;
		
		/**
		 * 快捷按钮
		 */
		public var quickMenu:Vector.<QuickMenu> = new Vector.<QuickMenu>();
		
		/**
		 * 右键菜单
		 */
		public var menu:Vector.<MenuData> = new Vector.<MenuData>();
		
		public var initLoad:ParserCall;
		
		public var dragFlag:Boolean = false;
		public var dragType:String = "";
		
		protected var _dragShow:ImageLoader;
		
		public function get dragShow():ImageLoader {
			return _dragShow;
		}
		
		public function DirectionDataBase()
		{
		}
		
		public function get isDirection():Boolean {
			return type==DirectionDataBase.DIRECTION?true:false;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set url(val:String):void {
			_url = val;
		}
		
		public function get name():String {
			return FileHelp.getURLName(url);
		}
		
		public function get nameDesc():String {
			return desc==""?name:desc;
		}
		
		public function initWidthDirection():void {
			this.type = DirectionDataBase.DIRECTION;
			this.directionOpenIcon = "assets/directionView/fileIcon/folder_open.png";
			this.directionCloseIcon = "assets/directionView/fileIcon/folder_close.png";
		}
		
		public function initWidthFile():void {
			this.type = DirectionDataBase.FILE;
			this.fileIcon = "assets/directionView/fileIcon/unknow.png";
		}
		
		public function save():void {
			
		}
	}
}