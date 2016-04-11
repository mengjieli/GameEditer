package test.ui
{
	import flower.display.DisplayObject;
	import flower.display.Sprite;
	import flower.events.Event;
	import flower.net.URLLoaderList;
	import flower.ui.Button;
	import flower.ui.UIParser;
	
	public class TestParser extends Sprite
	{	
		public function TestParser()
		{
			UIParser.registerUIClass("PanelBase",MyPanelBase);
			
			var loadList:URLLoaderList = new URLLoaderList([
				"res/uxml/Button.xml",
				"res/uxml/Panel.xml",
				"res/uxml/ProfilePanel.xml"
			]);
			loadList.addListener(Event.COMPLETE,onLoadComplete,this);
			loadList.load();
			
		}
		
		private function onLoadComplete(e:Event):void {
//			var button:* = UIParser.parse(e.data[0]);
//			this.addChild(button);
//			button.x = 400;
//			button.y = 500;
			
			UIParser.parse(e.data[0]);
			UIParser.parse(e.data[1]);
			
			var panel:* = UIParser.parse(e.data[2]);
			this.addChild(panel);
			trace(panel.txt1.text);
		}
	}
}