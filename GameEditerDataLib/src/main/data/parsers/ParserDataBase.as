package main.data.parsers
{
	import flash.events.EventDispatcher;
	
	import main.data.directionData.DirectionDataBase;

	public class ParserDataBase extends EventDispatcher
	{
		protected var _parserName:String = "";
		protected var _data:Object = "";
		public var directions:Vector.<DirectionDataBase> = new Vector.<DirectionDataBase>();
		
		public function ParserDataBase()
		{
		}
		
		/**
		 * 解析数据
		 */
		public function decode(config:Object):void {
			_parserName = config.parser;
			_parserName = config.data;
		}
		
		/**
		 * 保存数据
		 */
		public function encode():Object {
			return {
				"parser":_parserName,
				"data":_data
			};
		}
		
		/**
		 * 生成目录结构
		 * @param url String 根目录地址
		 */
		public function makeDirection(url:String):void {
			var dir:DirectionDataBase = new DirectionDataBase();
			dir.data = this;
			this.directions.push(dir);
		}
	}
}