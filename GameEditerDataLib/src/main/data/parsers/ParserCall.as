package main.data.parsers
{
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;

	public class ParserCall
	{
		private var parserName:String;
		private var apiName:String;
		public var dir:DirectionDataBase;
		
		public function ParserCall(parserName:String,apiName:String)
		{
			this.parserName = parserName;
			this.apiName = apiName;
		}
		
		public function call(dir:DirectionDataBase=null):void {
			if(dir == null) dir = this.dir;
			var parser:ParserBase = ToolData.getInstance().getParser(this.parserName);
			var api:Function = parser.api[this.apiName];
			api.call(null,dir);
		}
	}
}