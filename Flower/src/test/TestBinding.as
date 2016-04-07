package test
{
	import flower.Engine;
	import flower.data.DataManager;
	import flower.display.Sprite;
	import flower.events.TouchEvent;
	import flower.ui.Label;
	import flower.utils.Formula;

	public class TestBinding extends Sprite
	{
		private var label:Label;
		
		public function TestBinding()
		{
			Engine.getInstance().addChild(this);
			var txt:Label = new Label();
			txt.text = "点击改变位置";
			txt.color = 0xff00ff;
//			txt.autoSize = false;
			this.addChild(txt);
			label = txt;
			
			DataManager.ist.addDataDeinf({
				"name": "MainData",
				"desc": "派克总数据",
				"members": {
					"x": {
						"desc": "游戏版本号",
						"type": "int"
					},
					"y": {
						"desc": "游戏版本号",
						"type": "int"
					}
				}
			});
			
			DataManager.ist.addRootData("main","MainData");
			
			Formula["and"] = function(a:*,b:*):Boolean {
				a = +a||0;
				b = +b||0;
				return a&&b?true:false;
			}
			
			txt.bindProperty("x","{main.x}");
			txt.bindProperty("y","{main.y}");
			txt.bindProperty("text","x:{main.x},y:{main.y},我说呢根本不可能\nx+y:{add(main.x,main.y)},\nand:{and(main.x,main.y)},\nprint:{this.print()}");
			
			txt.addListener(TouchEvent.TOUCH_BEGIN,onTouch,this);
		}
		
		private function onTouch(e:TouchEvent):void {
			trace(label.x,label.y);
			if(label.x > 30) {
				label.dispose();
			}
			DataManager.ist.main.x.value += 10;
			DataManager.ist.main.y.value += 20;
			trace(label.x,label.y);
		}
	}
}