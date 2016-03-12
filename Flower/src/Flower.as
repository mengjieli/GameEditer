package
{
	import flash.display.Sprite;
	
	import flower.Engine;
	import flower.events.Event;
	import flower.events.IOErrorEvent;
	import flower.net.URLLoader;
	import flower.res.ResItem;
	import flower.res.ResType;
	import flower.utils.ObjectDo;
	
	public class Flower extends Sprite
	{
		public function Flower()
		{
			if(System.IDE == "flash") {
				System.stage = this["stage"];
			}
			new Engine();
			
			new TestCase();
			var res:ResItem = new ResItem();
			res.type = ResType.JSON;
			res.url = "paike.json";
			res.localURL = "res/";
			res.serverURL = "http:localhost:9600/";
			res.local = System.local;
			var loader:URLLoader = new URLLoader(res.loadURL,res.type);
			loader.load();
			loader.once(Event.COMPLETE,onLoaderComplete,this);
			loader.once(IOErrorEvent.ERROR,onLoaderError,this);
		}
		
		private function onLoaderComplete(e:Event):void {
			var loader:URLLoader = e.currentTarget;
			trace(loader.url,ObjectDo.toString(loader.data));
		}
		
		private function onLoaderError(e:IOErrorEvent):void {
			var loader:URLLoader = e.currentTarget;
			trace("加载出错了",loader.url);
		}
	}
}