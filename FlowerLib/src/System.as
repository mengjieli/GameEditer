package
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	
	import net.gimite.websocket.WebSocket;
	import net.gimite.websocket.WebSocketEvent;

	public class System
	{
		public static const IDE:String = "flash";
		public static var stage:Stage;
		public static const local:Boolean = false;
		//Y 方向是反的?
		public static const receverY:Boolean = false;
		public static var width:int;
		public static var height:int;
		public static var global:* = {};
		
		public static function start(root:*,debugRoot:*,engine:*):void {
			stage.frameRate = 60;
			width = stage.stageWidth;
			height = stage.stageHeight;
			stage.addChild(root);
			stage.addChild(debugRoot);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent):void {
				engine.onMouseDown(0,e.stageX,e.stageY);
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE,function(e:MouseEvent):void {
				engine.onMouseMove(0,e.stageX,e.stageX);
			});
			stage.addEventListener(MouseEvent.MOUSE_UP,function(e:MouseEvent):void {
				engine.onMouseUp(0,e.stageX,e.stageX);
			});
			
			$mesureTxt.autoSize = TextFieldAutoSize.LEFT;
			
//			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
//			stage.addEventListener(TouchEvent.TOUCH_BEGIN,function(e:TouchEvent):void {
//				engine.onMouseDown(e.touchPointID,e.localX,e.localY);
//			});
//			stage.addEventListener(TouchEvent.TOUCH_MOVE,function(e:TouchEvent):void {
//				engine.onMouseMove(e.touchPointID,e.localX,e.localY);
//			});
//			stage.addEventListener(TouchEvent.TOUCH_END,function(e:TouchEvent):void {
//				engine.onMouseUp(e.touchPointID,e.localX,e.localY);
//			});
		}
		
		private static var webSockets:Array = [];
		public static function bindWebSocket(ip:String,port:uint,thisObj:*,onConnect:Function,onReceiveMessage:Function,onError:Function,onClose:Function):* {
			var websocket:WebSocket = new WebSocket("wss://" + ip  + ":" + port);
			var openFunc:Function =  function(event:WebSocketEvent):void {
				onConnect.call(thisObj);
			};
			websocket.addEventListener(WebSocketEvent.OPEN,openFunc);
			var receiveFunc:Function = function(event:WebSocketEvent):void {
				onReceiveMessage.call(thisObj,"string",event.message);
			};
			websocket.addEventListener(WebSocketEvent.MESSAGE, receiveFunc);
			var errorFunc:Function = function(event:WebSocketEvent):void{
				onError.call(thisObj);
			};
			websocket.addEventListener(WebSocketEvent.ERROR,errorFunc);
			var closeFunc:Function = function(event:WebSocketEvent):void {
				onClose.call(thisObj);
			};
			websocket.addEventListener(WebSocketEvent.CLOSE,closeFunc);
			webSockets.push({
				"webSocket":websocket,
				"openFunc":openFunc,
				"receiveFunc":receiveFunc,
				"errorFunc":errorFunc,
				"closeFunc":closeFunc
			});
			return websocket;
		}
		
		public static function sendWebSocketUTF(webSocket:WebSocket,data:String):void {
			webSocket.send(data);
		}
		
		public static function sendWebSocketBytes(webSocket:WebSocket,data:Array):void {
			var str:String = "[";
			for(var i:Number = 0; i < data.length; i++) {
				str += data[i] + (i<data.length-1?",":"");
			}
			str += "]";
			webSocket.send(str);
		}
		
		public static function releaseWebSocket(websocket:WebSocket):void {
			var item:* = null;
			var list:Array = System.webSockets;
			for(var i:int = 0; i < list.length; i++) {
				if(websocket == list[i].webSocket) {
					websocket.close();
					websocket.removeEventListener(WebSocketEvent.OPEN,list[i].openFunc);
					websocket.removeEventListener(WebSocketEvent.MESSAGE,list[i].receiveFunc);
					websocket.removeEventListener(WebSocketEvent.ERROR,list[i].errorFunc);
					websocket.removeEventListener(WebSocketEvent.CLOSE,list[i].closeFunc);
					list.splice(i,1);
					break;
				}
			}
		}
		
		public static function numberToString(arr:Array):String {
			var bytes:ByteArray = new ByteArray();
			for(var i:Number = 0; i < arr.length; i++) {
				bytes.writeByte(arr[i]);
			}
			bytes.position = 0;
			return bytes.readUTFBytes(bytes.bytesAvailable);
		}
		
		public static function stringToBytes(str:String):Array {
			var arr:Array = [];
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(str);
			bytes.position = 0;
			for(var i:Number = 0; i < bytes.length; i++) {
				arr.push(bytes.readUnsignedByte());
			}
			return arr;
		}
		
		public static function getTime():Number {
			return (new Date()).time;
		}
		
		public static function createTexture(data:*):* {
			return data;
		}
		
		public static function disposeTexture(nativeTexture:*,url:String):void {
			(nativeTexture as BitmapData).dispose();
		}
		
		public static function log(...args):void {
			var str:String = "";
			for (var i:int = 0; i < args.length; i++) {
				str += args[i] + (i < args.length - 1 ? "  " : "");
			}
			trace(str);
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
		
		public static function getNativeShow(className:String):* {
			if(nativeShows[className].length) {
				var show:* = nativeShows[className].pop();
				return show;
			}
			trace("[New native show]",className);
			if(className == "DisplayObjectContainer") {
				return new Sprite();
			}
			if(className == "Bitmap") {
				return new flash.display.Bitmap();
			}
			if(className == "TextField") {
				var txt:flash.text.TextField = new flash.text.TextField();
				txt.autoSize = TextFieldAutoSize.LEFT;
				txt.defaultTextFormat.leading = 5;
				txt.selectable = false;
				return txt;
			}
			return null;
		}
		
		private static var nativeShows:Object = {
			"DisplayObjectContainer":[],
			"Bitmap":[],
			"TextField":[]
		};
			
		public static function cycleNativeShow(className,show:*):void {
			nativeShows[className].push(show);
		}
		
		public static var URLLoader:Object = {
			"loadText":{
				"func":function(url:String,back:Function,errorBack:Function,thisObj:*):void {
					var loader:flash.net.URLLoader = new flash.net.URLLoader();
					loader.addEventListener(Event.COMPLETE,function(e:Event):void {
						back.call(thisObj,loader.data);
					});
					loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {
						errorBack.call(thisObj);
					});
					loader.load(new URLRequest(url));
				}
			},
			"loadTexture":{
				"func":function(url:String,back:Function,errorBack:Function,thisObj:*):void {
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(e:Event):void {
						var bitmap:* = loader.contentLoaderInfo.content;
						back.call(thisObj,bitmap.bitmapData,bitmap.bitmapData.width,bitmap.bitmapData.height);
					});
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {
						errorBack.call(thisObj);
					});
					loader.load(new URLRequest(url));
				}
			}
		}
		
		public static var DisplayObject:Object = {
			"x":{"atr":"x"},
			"y":{"atr":"y"},
			"scaleX":{"atr":"scaleX"},
			"scaleY":{"atr":"scaleY"},
			"rotation":{"atr":"rotation","scale":1},
			"alpha":{"atr":"alpha","scale":1},
			"visible":{"atr":"visible"}
		};
		
		public static var DisplayObjectContainer:Object = {
			"setChildIndex":{"func":"setChildIndex"}
		}
		
		public static var Bitmap:Object = {
			"texture":{"atr":"bitmapData"}
		}
			
		private static var $mesureTxt:flash.text.TextField = new flash.text.TextField();
		public static var TextField:Object = {
			"color":{"atr":"textColor"},
			"size":{"exe":function(txt:flash.text.TextField,size:uint):void {
				txt.defaultTextFormat.size = size;
			}},
			"resetText":function(txt:flash.text.TextField, text:String, width:uint, height:uint, size:uint, wordWrap:Boolean, multiline:Boolean, autoSize:Boolean):void {
//				txt.text = text; return;
				
				$mesureTxt.defaultTextFormat.size = size;
				$mesureTxt.defaultTextFormat.leading = 5;
				txt.text = "";
				txt.width = width;
				var txtText:String = "";
				var start:uint = 0;
				var line:int = 0;
				for(var i:int = 0; i < text.length; i++) {
					//取一行文字进行处理
					if(text.charAt(i) == "\n" || text.charAt(i) == "\r" || i == text.length-1) {
						var str:String = text.slice(start,i);
						$mesureTxt.text = str;
						var lineWidth:uint = $mesureTxt.textWidth;
						var findEnd:uint = i;
						var changeLine:Boolean = false;
						//如果这一行的文字宽大于设定宽
						while(!autoSize && lineWidth > width) {
							changeLine = true;
							findEnd--;
							$mesureTxt.text = text.slice(start,findEnd + (i == text.length-1?1:0));
							lineWidth = $mesureTxt.textWidth;
						}
						if(wordWrap && changeLine) {
							i = findEnd;
							txt.text = txtText + text.slice(start,findEnd + (i == text.length-1?1:0));
						} else {
							txt.text = txtText + text.slice(start,findEnd + (i == text.length-1?1:0));
						}
						//如果文字的高度已经大于设定的高，回退一次
						if(!autoSize && txt.textHeight > height) {
							txt.text = txtText;
							break;
						} else {
							txtText += text.slice(start,findEnd + (i == text.length-1?1:0));
							if(wordWrap && changeLine) {
								txtText += "\n";
							}
						}
						start = i;
						if(multiline == false) {
							break;
						}
						line++;
					}
				}
			},
			"mesure":function(txt:flash.text.TextField):Object{
				return {"width":txt.textWidth,"height":txt.textHeight};
			}
		}
	}
}