package flower.ui
{
	import flower.Engine;
	import flower.debug.DebugInfo;
	import flower.display.DisplayObject;
	import flower.utils.XMLElement;

	public class UIParser
	{
		private var classes:Object;
		private var parseContent:String;
		
		public function UIParser()
		{
			classes = {};
			classes.f = {
				"Label":Label,
				"Image":Image,
				"Group":Group,
				"Button":Button
			}
			classes.local = {
			}
			classes.localClass = {
			}
		}
		
		private function addLocalUI(name:String,xml:XMLElement):void {
			classes.local[name] = xml;
		}
		
		public function addLocalUIClass(name:String,cls:*):void {
			classes.localClass[name] = cls;
		}
		
		public function parse(content:*):DisplayObject {
			parseContent = content;
			var xml:XMLElement;
			if(content is String) {
				xml = XMLElement.parse(content);
			} else {
				xml = content;
			}
			if(xml.getNameSapce("f") == null || xml.getNameSapce("f").value != "flower.ui") {
				if(Engine.DEBUG) {
					DebugInfo.debug("解析 UI 出错,未设置命名空间 xmlns:f=\"flower.ui\" :" + "\n" + content,DebugInfo.ERROR);
				}
				return null;
			}
			var hasLocalNS:Boolean = xml.getNameSapce("local")?true:false;
			var ui:* = decodeComponent(null,xml,hasLocalNS);
			for(var i:int = 0; i < xml.attributes.length; i++) {
				if(xml.attributes[i].name == "class") {
					classes.local[xml.attributes[i].value] = xml;
					break;
				}
			}
			parseContent = "";
			return ui;
		}
		
		private function decodeComponent(parent:*,xml:XMLElement,hasLocalNS:Boolean):* {
			var uiname:String = xml.name;
			var uinameNS:String = uiname.split(":")[0];
			uiname = uiname.split(":")[1];
			var cls:*;
			var ui:*;
			if(uinameNS == "local") {
				if(!hasLocalNS) {
					if(Engine.DEBUG) {
						DebugInfo.debug("解析 UI 出错:无法解析的命名空间 " + uinameNS + " :\n" + parseContent,DebugInfo.ERROR);
					}
				}
				if(classes.local[uiname]) {
					return decodeComponent(parent,classes.local[uiname],hasLocalNS);
				} else {
					cls = classes.localClass[uiname];
					ui = new cls();
				}
			} else {
				cls = classes[uinameNS][uiname];
				ui = new cls();
			}
			for(var i:int = 0; i < xml.attributes.length; i++) {
				var atrName:String = xml.attributes[i].name;
				var atrValue:String = xml.attributes[i].value;
				var atrArray:Array = atrName.split(".");
				if(atrName == "class") {
					
				} else if(atrName == "id") {
					if(parent) {
						parent[atrValue] = ui;
					}
				} else if(atrArray.length == 2) {
					var atrState:String = atrArray[1];
					atrName = atrArray[0];
					ui.setStatePropertyValue(atrName,atrState,atrValue);
				} else if(atrArray.length == 1) {
					ui[atrName] = atrValue;
				}
			}
			if(xml.list.length) {
				var childIndex:int = ui.numChildren;
				for(i = 0; i < xml.list.length; i++) {
					var child:DisplayObject = this.decodeComponent(ui,xml.list[i],hasLocalNS);
					ui.addChildAt(child,childIndex);
				}
			}
			return ui;
		}
		
		private static var ist:UIParser;
		
		public static function parse(content:*):DisplayObject {
			if(!ist) {
				ist = new UIParser();
			}
			return ist.parse(content);
		}
		
		public static function registerUIClass(name:String,localUIClass:*):void {
			if(!ist) {
				ist = new UIParser();
			}
			ist.addLocalUIClass(name,localUIClass);
		}
	}
}