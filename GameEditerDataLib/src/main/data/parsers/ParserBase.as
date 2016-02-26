package main.data.parsers
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	/**
	 * 解析器
	 */
	public class ParserBase extends Sprite
	{
		public var loader:Loader;
//		public var swf:MovieClip;
		
		public function ParserBase()
		{
		}
		
		public function get parserName():String {
			return "ParserBase";
		}
		
		/**
		 * 与其它模块交换数据，数据的格式是向前兼容的，一般不会随着存储的数据变化而变化
		 */
		public function parseToFixConfig(url:String):Object {
			return null;
		}
		
		/**
		 * 获取数据解析类
		 */
		public function getNewData():ParserDataBase {
			return new ParserDataBase();
		}
		
		public function get api():Object {
			return {};
		}
		
		public function unload():void {
//			swf.stopAllMovieClips();
			loader.unloadAndStop();
		}
	}
}