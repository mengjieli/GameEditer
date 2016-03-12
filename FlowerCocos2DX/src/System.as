package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class System
	{
		public static const IDE:String = "flash";
		public static var stage:Stage;
		public static const local:Boolean = false;
		
		public static function start():void {
			
		}
		
		public static var JSON_parser:Function = JSON.parse;
		public static var JSON_stringify:Function = JSON.stringify;
		
		private static var lastTime:Number;
		public static function runTimeLine(back:Function):void {
			stage.addEventListener(Event.ENTER_FRAME,function(e:Event):void {
				var now:Number = (new Date()).time;
				back(now - lastTime);
				lastTime = now;
			});
		}
		
		public static var URLLoader:Object = {
			"loadText":{
				"sync":false,
				"func":function(url:String,back:Function,errorBack:Function):void {
					var loader:flash.net.URLLoader = new flash.net.URLLoader();
					loader.addEventListener(Event.COMPLETE,function(e:Event):void {
						back(loader.data);
					});
					loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {
						errorBack();
					});
					loader.load(new URLRequest(url));
				}
			}
		}
		
		public static var Bitmap:Object = {
			"class":Bitmap
		}
		
		public static var DisplayObject:Object = {
			"x":{"atr":"x"},
			"y":{"atr":"y"},
			"scaleX":{"atr":"scaleX"},
			"scaleY":{"atr":"scaleY"},
			"rotation":{"atr":"rotation","scale":1},
			"visible":{"atr":"visible"}
		}
	}
}