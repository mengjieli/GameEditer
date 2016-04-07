package flower.debug.toolBar
{
	import flower.display.Sprite;
	import flower.events.Event;
	import flower.events.TouchEvent;
	import flower.net.URLLoader;
	import flower.ui.Image;
	import flower.ui.Label;
	import flower.utils.ObjectDo;

	public class DebugToolBar extends Sprite
	{
		private var image:Image;
		private var image2:Image;
		
		public function DebugToolBar()
		{
			var label:Label = new Label();
			label.text = "我是";
			label.color = 0xff0000;
			label.addListener(TouchEvent.TOUCH_BEGIN,onBegin,this);
			this.addListener(TouchEvent.TOUCH_BEGIN,onBegin2,this);
			this.addChild(label);
			
			image = new Image("res/fight/testplist.png");
			this.addChild(image);
			image.x = 100;
			image.y = 100;
			image.scaleX = 2;
			image.scaleY = 3;
			
			var load:URLLoader = new URLLoader("res/paike.json");
			load.load();
			load.addListener(Event.COMPLETE,loadConfigComplete,this);
			var load:URLLoader = new URLLoader("res/paike.json");
			load.load();
			load.addListener(Event.COMPLETE,loadConfigComplete,this);
		}
		
		private function loadConfigComplete(e:Event):void {
			trace(flower.utils.ObjectDo.toString(e.data));
		}
		
		private function onBegin(e:TouchEvent):void {
			trace("click label");
		}
		
		private function onBegin2(e:TouchEvent):void {
			trace("click tool bar");
			if(image) {
				image.dispose();
				image = null;
				if(image2) {
					image2.dispose();
					image2 = null;
				}
			} else {
				image = new Image("res/fight/ui/12081015.png");
				this.addChild(image);
//				image.x = 200;
//				image.y = 200;
				this.addChild(image);
				
				image2 = new Image("res/fight/ui/12081015.png");
				this.addChild(image2);
				this.addChild(image2);
				image2.x = 100;
				image2.y = 100;
			}
		}
	}
}