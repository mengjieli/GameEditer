package view.component
{
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.parsers.ParserBase;
	
	import view.component.data.ComponentData;
	import view.component.data.GroupData;
	import view.component.data.ImageData;
	import view.component.data.LabelData;

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
//					component = new Button();
					break;
			}
			component.decodeByStyle(styleData,styleURL);
			return component;
		}
		
		/**
		 * 根据配置获取 ComponentData
		 */
		public static function getComponentDataByConfig(json:Object):ComponentData {
			var component:ComponentData;
			switch(json.type) {
				case "Label":
					var label:LabelData = new LabelData();
					label.parser(json);
					component = label;
					break;
				case "Image":
					var image:ImageData = new ImageData();
					image.parser(json);
					component = image;
					break;
				case "Group":
					var group:GroupData = new GroupData();
					group.parser(json);
					component = group;
					break;
			}
			return component;
		}
		
		public static function getCustomComponentData(name:String):ComponentData {
			var component:ComponentData;
			switch(name) {
				case "Label":
					component = new LabelData();
					break;
				case "Image":
					component = new ImageData();
					break;
				case "Group":
					component = new GroupData();
					break;
			}
			return component;
		}
		
		/**
		 * 获取默认容器
		 */
		public static function getComponentByData(componentData:ComponentData):ComponentBase {
			var component:ComponentBase;
			switch(componentData.type){
				case "Label":
					component = new Label(componentData as LabelData);
					break;
				case "Image":
					component = new Image(componentData as ImageData);
					break;
				case "Group":
					component = new Group(componentData as GroupData);
					break;
			}
			return component;
		}
	}
}