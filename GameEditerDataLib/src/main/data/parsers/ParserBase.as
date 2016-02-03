package main.data.parsers
{
	import flash.display.Sprite;

	/**
	 * 解析器
	 */
	public class ParserBase extends Sprite
	{
		public function ParserBase()
		{
		}
		
		public function get parserName():String {
			return "ParserBase";
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
	}
}