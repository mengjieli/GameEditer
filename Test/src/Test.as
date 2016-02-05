package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	
	public class Test extends Sprite
	{
		private var load:Loader;
		private var dir:*;
		
		public function Test()
		{
			load = new Loader();
			load.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			load.load(new URLRequest("DataParser.swf"));
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
		}
		
		private function onKey(e:KeyboardEvent):void {
			trace(e.keyCode);
			if(e.keyCode == 13) {
				load.unloadAndStop();
			} else if(e.keyCode == 49) {
				load = new Loader();
				load.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
				load.load(new URLRequest("DataParser.swf"));
			}
		}
		
		private function loadComplete(e:Event):void {
			trace(load.content["parserName"]);
			load.unloadAndStop();
//			load.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
		}
	}
}