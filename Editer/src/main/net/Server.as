package main.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import main.data.ToolData;
	
	import net.gimite.websocket.WebSocket;
	import net.gimite.websocket.WebSocketEvent;

	public class Server extends EventDispatcher
	{
		private static var id:Number = 0;
		private var websocket:WebSocket;
		
		public var ip:String;
		public var port:String;
		
		public function Server()
		{
		}
		
		public function connect(ip:String,port:String):void {
			this.ip = ip;
			this.port = port;
			if(websocket) {
				this.close();
			}
			websocket = new WebSocket("wss://" + ip  + ":" + port);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketEvent.ERROR,onWebSocketConnectError);
			websocket.addEventListener(WebSocketEvent.CLOSE,onWebSocketClose);
		}
		
		public function onWebSocketClose(event:WebSocketEvent):void {
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function onWebSocketConnectError(e:WebSocketEvent):void {
			this.dispatchEvent(e);
		}
		
		public function close():void {
			if(websocket) {
				websocket.close();
				websocket.removeEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
				websocket.removeEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
				websocket.removeEventListener(WebSocketEvent.ERROR,onWebSocketConnectError);
				websocket.removeEventListener(WebSocketEvent.CLOSE,onWebSocketClose);
				websocket = null;
			}
		}
		
		public function handleWebSocketOpen(event:WebSocketEvent):void {
			this.dispatchEvent(new Event(Event.CONNECT));
		}
		
		public function send(bytes:MyByteArray):void {
			var str:String = "[";
			bytes.position = 0;
			for(var i:Number = 0; i < bytes.length; i++) {
				str += bytes.readByte() + (i<bytes.length-1?",":"");
			}
			str += "]";
			this.websocket.send(str);
		}
		
		public function handleWebSocketMessage(event:WebSocketEvent):void {
			var str:String = event.message;
			var list:Array = JSON.parse(str) as Array;
			var bytes:MyByteArray = new MyByteArray();
			bytes.initFromArray(list);
			var pos:Number;
			var cmd:Number = bytes.readUIntV();
			trace("[Receive]",cmd);
			if(cmd == 0) {
				var backCmd:Number = bytes.readUIntV();
				var zbackList:Array = zbacks[backCmd];
				if(zbackList) {
					var removeList:Array = [];
					var errorCode:Number = bytes.readUIntV();
					var a:Array = zbackList.concat();
					for(var i:Number = 0; i < a.length; i++) {
						a[i].func(backCmd,errorCode);
						if(a[i].once) {
							removeList.push(a[i].id);
						}
					}
					for(i = 0; i < removeList.length; i++) {
						for(var f:Number = 0; f < zbacks[cmd].length; f++) {
							if(zbacks[cmd][f].id == removeList[i]) {
								zbacks[cmd].splice(f,1);
								break;
							}
						}
					}
				}
				
				bytes.position = 0;
				bytes.readUIntV();
				pos = bytes.position;
				var backList:Array = backs[cmd];
				if(backList) {
					var removeList:Array = [];
					var a:Array = backList.concat();
					for(var i:Number = 0; i < a.length; i++) {
						bytes.position = pos;
						a[i].func(cmd,bytes);
						if(a[i].once) {
							removeList.push(a[i].id);
						}
					}
					for(i = 0; i < removeList.length; i++) {
						for(var f:Number = 0; f < backs[cmd].length; f++) {
							if(backs[cmd][f].id == removeList[i]) {
								backs[cmd].splice(f,1);
								break;
							}
						}
					}
				}
			} else {
				var remoteId:Number = bytes.readUIntV();
				pos = bytes.position;
				if(remoteId) {
					var remote:RemoteBase = remotes[remoteId];
					if(remote) {
						remote.doNext(cmd,bytes);
					}
				} else {
					var backList:Array = backs[cmd];
					if(backList) {
						var removeList:Array = [];
						var a:Array = backList.concat();
						for(var i:Number = 0; i < a.length; i++) {
							bytes.position = pos;
							a[i].func(cmd,bytes);
							if(a[i].once) {
								removeList.push(a[i].id);
							}
						}
						for(i = 0; i < removeList.length; i++) {
							for(var f:Number = 0; f < backs[cmd].length; f++) {
								if(backs[cmd][f].id == removeList[i]) {
									backs[cmd].splice(f,1);
									break;
								}
							}
						}
					}
				}
			}
		}
		
		private var remotes:Object = {};
		public function registerRemote(remote:RemoteBase):void {
			remotes[remote.id] = remote;
		}
		
		public function removeRemote(remote:RemoteBase):void {
			delete remotes[remote.id];
		}
		
		private var backs:Object = {};
		private var zbacks:Object = {};
		public function register(cmd:Number,back:Function):void {
			if(backs[cmd] == null) {
				backs[cmd] = [];
			}
			 backs[cmd].push({func:back,id:Server.id++});
		}
		
		public function once(cmd:Number,back:Function):void {
			if(backs[cmd] == null) {
				backs[cmd] = [];
			}
			backs[cmd].push({func:back,once:true,id:Server.id++});
		}
		
		public function remove(cmd:Number,back:Function):void {
			var list:Array = backs[cmd];
			if(list) {
				for(var i:Number = 0; i < list.length; i ++) {
					if(list[i].func == back) {
						list.splice(i,1);
						i--;
					}
				}
			}
		}
		
		public function registerZero(cmd:Number,back:Function):void {
			if(zbacks[cmd] == null) {
				zbacks[cmd] = [];
			}
			zbacks[cmd].push({func:back,id:Server.id++});
		}
		
		public function removeZeroe(cmd:Number,back:Function):void {
			var list:Array = zbacks[cmd];
			if(list) {
				for(var i:Number = 0; i < list.length; i ++) {
					if(list[i].func == back) {
						list.splice(i,1);
						i--;
					}
				}
			}
		}
		
		public function onceZero(cmd:Number,back:Function):void {
			if(zbacks[cmd] == null) {
				zbacks[cmd] = [];
			}
			zbacks[cmd].push({func:back,once:true,id:Server.id++});
		}
	}
}