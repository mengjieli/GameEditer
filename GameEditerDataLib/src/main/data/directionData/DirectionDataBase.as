package main.data.directionData
{
	import main.data.parsers.ParserDataBase;
	import main.data.parsers.QuickMenu;
	import main.data.parsers.ReaderBase;

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
		public var url:String;
		
		/**
		 * 解析器数据
		 */
		public var data:ParserDataBase;
		
		/**
		 * 阅读器地址
		 */
		public var reader:ReaderBase;
		
		/**
		 * 快捷按钮
		 */
		public var quickMenu:Vector.<QuickMenu> = new Vector.<QuickMenu>();
		
		
		public function DirectionDataBase()
		{
		}
	}
}