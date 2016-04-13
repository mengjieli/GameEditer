package flower.ui
{
	import flower.Engine;
	import flower.debug.DebugInfo;
	import flower.display.DisplayObject;
	import flower.ui.layout.HorizontalLayout;
	import flower.ui.layout.LinearLayoutBase;
	import flower.ui.layout.VerticalLayout;
	import flower.utils.XMLElement;

	public class UIParser
	{
		private var classes:Object;
		private var parseContent:String;
		private var id:int = 0;
		
		public function UIParser()
		{
			classes = {};
			classes.f = {
				"Label":Label,
				"Image":Image,
				"Group":Group,
				"Button":Button,
				"LinearLayoutBase":LinearLayoutBase,
				"HorizontalLayout":HorizontalLayout,
				"VerticalLayout":VerticalLayout
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
		
		public function parse(content:*,data:*):DisplayObject {
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
			var ui:* = decodeComponent(null,xml,hasLocalNS,data);
			for(var i:int = 0; i < xml.attributes.length; i++) {
				if(xml.attributes[i].name == "class") {
					classes.local[xml.attributes[i].value] = xml;
					break;
				}
			}
			parseContent = "";
			return ui;
		}
		
		private function decodeComponent(root:*,xml:XMLElement,hasLocalNS:Boolean,data:*=null):* {
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
					return decodeComponent(root,classes.local[uiname],hasLocalNS);
				} else {
					cls = classes.localClass[uiname];
					ui = new cls();
				}
			} else {
				cls = classes[uinameNS][uiname];
				if(cls) {
					ui = new cls();
				}
			}
			if(!ui) {
				return null;
			}
			if(data) {
				ui.data = data;
			}
			if(root == null) {
				root = ui;
			}
			for(var i:int = 0; i < xml.attributes.length; i++) {
				var atrName:String = xml.attributes[i].name;
				var atrValue:String = xml.attributes[i].value;
				var atrArray:Array = atrName.split(".");
				if(atrName == "class") {
					
				} else if(atrName == "id") {
					if(root) {
						root[atrValue] = ui;
					}
				} else if(atrArray.length == 2) {
					var atrState:String = atrArray[1];
					atrName = atrArray[0];
					ui.setStatePropertyValue(atrName,atrState,atrValue,[root]);
				} else if(atrArray.length == 1) {
					if(atrValue.indexOf("{") >= 0 && atrValue.indexOf("}") >= 0) {
						ui.bindProperty(atrName,atrValue,[root]);
					} else {
						ui[atrName] = atrValue;
					}
				}
			}
			if(xml.list.length) {
				for(i = 0; i < xml.list.length; i++) {
					var item:XMLElement = xml.list[i];
					var child:* = this.decodeComponent(root,item,hasLocalNS);
					//解析成属性
					if(child == null) {
						var atr:String = item.name;
						atr = atr.split(":")[atr.split(":").length-1];
						ui[atr] = this.decodeComponent(root,item.list[0],hasLocalNS);
					} else {
						ui.addChild(child);
					}
				}
			}
			return ui;
		}
		
		private static var ist:UIParser;
		
		public static function parse(content:*,data:*=null):* {
			if(!ist) {
				ist = new UIParser();
			}
			return ist.parse(content,data);
		}
		
		public static function registerUIClass(name:String,localUIClass:*):void {
			if(!ist) {
				ist = new UIParser();
			}
			ist.addLocalUIClass(name,localUIClass);
		}
	}
}