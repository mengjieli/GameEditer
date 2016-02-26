package view.component
{
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.parsers.ParserBase;

	public class ComponentParser
	{
		protected var style:Object;
		
		/**
		 * 把样式解析成组件
		 */
		public static function parserStyleToComponent(styleURL:String):ComponentBase {
			var component:ComponentBase;
			var content:String = FileUtil.openAsString(styleURL);
			var config:Object = JSON.parse(content);
			var parserName:String = config.parser;
			var parser:ParserBase = ToolData.getInstance().getParser(parserName);
			var styleData:Object = parser.parseToFixConfig(styleURL);
			switch(styleData["class"]) {
				case "Button":
					component = new Button();
					break;
			}
			component.decodeByStyle(styleData,styleURL);
			return component;
		}
		
		/**
		 * 获取默认容器
		 */
		public static function getCustomComponent(name:String):ComponentBase {
			var component:ComponentBase;
			switch(name){
				case "Group":
					component = new Group();
					break;
			}
			return component;
		}
	}
}