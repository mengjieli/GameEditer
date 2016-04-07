package flower.net
{
	import flower.utils.VByteArray;

	/**
	 * VByteArray
	 */
	public class VBWebSocket extends WebSocket
	{
		private static var id:Number = 0;
		
		/**
		 * 是否支持远程调用
		 */
		private var _remote:Boolean;
		private var remotes:Object = {};
		private var backs:Object = {};
		private var zbacks:Object = {};
		
		public function VBWebSocket(remote:Boolean=false)
		{
			_remote = remote;
			remotes = {};
			backs = {};
			zbacks = {};
		}
		
		public function get remote():Boolean {
			return _remote;
		}
		
		override protected function onReceiveMessage(type:String,data:*):void {
			var bytes:VByteArray = new VByteArray();
			if(type == "string") {
				bytes.readFromArray(System.JSON_parser(data));
			} else {
				bytes.readFromArray(data);
			}
			var pos:Number;
			var cmd:Number = bytes.readUInt();
			var removeList:Array;
			var a:Array;
			var i:Number;
			var f:Number;
			var backList:Array;
			if(cmd == 0) {
				var backCmd:Number = bytes.readUInt();
				var zbackList:Array = zbacks[backCmd];
				if(zbackList) {
					removeList = [];
					var errorCode:Number = bytes.readUInt();
					a = zbackList.concat();
					for(i = 0; i < a.length; i++) {
						a[i].func.call(a[i].thisObj,backCmd,errorCode);
						if(a[i].once) {
							removeList.push(a[i].id);
						}
					}
					for(i = 0; i < removeList.length; i++) {
						for(f = 0; f < zbacks[cmd].length; f++) {
							if(zbacks[cmd][f].id == removeList[i]) {
								zbacks[cmd].splice(f,1);
								break;
							}
						}
					}
				}
				bytes.position = 0;
				bytes.readUInt();
				pos = bytes.position;
				backList = backs[cmd];
				if(backList) {
					removeList = [];
					a = backList.concat();
					for(i = 0; i < a.length; i++) {
						bytes.position = pos;
						a[i].func.call(a[i].thisObj,cmd,bytes);
						if(a[i].once) {
							removeList.push(a[i].id);
						}
					}
					for(i = 0; i < removeList.length; i++) {
						for(f = 0; f < backs[cmd].length; f++) {
							if(backs[cmd][f].id == removeList[i]) {
								backs[cmd].splice(f,1);
								break;
							}
						}
					}
				}
			} else {
				var remoteId:Number = 0;
				if(_remote) {
					remoteId = bytes.readUInt();
				}
				pos = bytes.position;
				if(remoteId) {
					var remote:Remote = remotes[remoteId];
					if(remote) {
						remote.doNext(cmd,bytes);
					}
				} else {
					backList = backs[cmd];
					if(backList) {
						removeList = [];
						a = backList.concat();
						for(i = 0; i < a.length; i++) {
							bytes.position = pos;
							a[i].func.call(a[i].thisObj,cmd,bytes);
							if(a[i].once) {
								removeList.push(a[i].id);
							}
						}
						for(i = 0; i < removeList.length; i++) {
							for(f = 0; f < backs[cmd].length; f++) {
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
		
		override public function send(data:*):void {
			System.sendWebSocketBytes(localWebSocket,data.data);
		}
		
		public function registerRemote(remote:Remote):void {
			remotes[remote.id] = remote;
		}
		
		public function removeRemote(remote:Remote):void {
			delete remotes[remote.id];
		}
		
		public function register(cmd:Number,back:Function,thisObj:*):void {
			if(backs[cmd] == null) {
				backs[cmd] = [];
			}
			backs[cmd].push({func:back,thisObj:thisObj,id:VBWebSocket.id++});
		}
		
		public function registerOnce(cmd:Number,back:Function,thisObj:*):void {
			if(backs[cmd] == null) {
				backs[cmd] = [];
			}
			backs[cmd].push({func:back,thisObj:thisObj,once:true,id:VBWebSocket.id++});
		}
		
		public function remove(cmd:Number,back:Function,thisObj:*):void {
			var list:Array = backs[cmd];
			if(list) {
				for(var i:Number = 0; i < list.length; i ++) {
					if(list[i].func == back && list[i].thisObj == thisObj) {
						list.splice(i,1);
						i--;
					}
				}
			}
		}
		
		public function registerZero(cmd:Number,back:Function,thisObj:*):void {
			if(zbacks[cmd] == null) {
				zbacks[cmd] = [];
			}
			zbacks[cmd].push({func:back,thisObj:thisObj,id:VBWebSocket.id++});
		}
		
		public function removeZeroe(cmd:Number,back:Function,thisObj:*):void {
			var list:Array = zbacks[cmd];
			if(list) {
				for(var i:Number = 0; i < list.length; i ++) {
					if(list[i].func == back && list[i].thisObj == thisObj) {
						list.splice(i,1);
						i--;
					}
				}
			}
		}
		
		public function registerZeroOnce(cmd:Number,back:Function,thisObj:*):void {
			if(zbacks[cmd] == null) {
				zbacks[cmd] = [];
			}
			zbacks[cmd].push({func:back,thisObj:thisObj,once:true,id:VBWebSocket.id++});
		}
	}
}