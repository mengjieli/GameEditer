package dataParser
{
	import main.data.parsers.ParserBase;
	import main.data.parsers.ParserDataBase;

	public class DataParser extends ParserBase
	{
		public function DataParser()
		{
		}
		
		override public function get parserName():String {
			return "Data";
		}
		
		/**
		 * 获取数据解析类
		 */
		override public function getNewData():ParserDataBase {
			return new DataData();
		}
	}
}