package test.ui
{
	import flower.binding.Binding;
	import flower.data.DataManager;
	import flower.data.member.StringValue;
	import flower.events.Event;
	import flower.events.TouchEvent;
	import flower.net.URLLoaderList;
	import flower.ui.Group;
	import flower.ui.Label;
	import flower.ui.UIParser;
	import flower.ui.layout.HorizontalLayout;
	import flower.utils.Formula;

	public class TestLayout extends Group
	{
		public function TestLayout()
		{
//			for(var i:int = 0; i < 10; i++) {
//				var label:Label = new Label();
//				label.text = i + "";
//				label.color = 0x00ff00;
//				this.addChild(label);
//			}
//			var layout:HorizontalLayout = new HorizontalLayout();
//			layout.gap = 5;
//			this.layout = layout;
			
			var group:Group = new Group();
			var label:Label = new Label();
			label.bindProperty("text","{$state}",[group]);
			group.addChild(label);
			group.currentState = "select";
			group.absoluteState = true;
			this.addChild(group);
			return;
			var loadList:URLLoaderList = new URLLoaderList([
				"res/uxml/Layout.xml"
			]);
			loadList.addListener(Event.COMPLETE,onLoadComplete,this);
			loadList.load();
		}
		
		private function onLoadComplete(e:Event):void {
			Binding.addBindingCheck(DataManager.ist);
			Binding.addBindingCheck(Formula);
			
			DataManager.ist.addDataDeinf({
				"name": "MainData",
				"desc": "派克总数据",
				"members": {
					"x": {
						"desc": "坐标 x",
						"type": "int",
						"init":10
					},
					"y": {
						"desc": "坐标 y",
						"type": "int",
						"init": 20
					},
					"title":{
						"type":"string",
						"init":"标题啊"
					},
					"title2":{
						"type":"string",
						"init":"副标题"
					}
				}
			});
			DataManager.ist.addRootData("main","MainData");
			
			Formula["and"] = function(a:*,b:*):Boolean {
				a = +a||0;
				b = +b||0;
				return a&&b?true:false;
			}
				
			Formula["mutily"] = function(a:*,b:*):Number {
				return a*b;
			}
			
//			var data:Object = {
//				title:new StringValue("标题啊"),
//				title2:new StringValue("副标题啊")
//			}
			
			var panel:Group = UIParser.parse(e.data[0]);
			this.addChild(panel);
			panel.currentState = "select";
			panel.addListener(TouchEvent.TOUCH_END,function(e:TouchEvent):void {
				panel.currentState = panel.currentState=="select"?"noselect":"select";
				DataManager.ist.main.x.value += DataManager.ist.main.x.value;
			},this);
			trace(panel.txt1.text);
		}
	}
}