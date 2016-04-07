package flower.net
{
	import flower.events.Event;
	import flower.events.EventDispatcher;

	public class WebSocket extends EventDispatcher
	{
		private var _ip:String;
		private var _port:uint;
		protected var localWebSocket:*;
		
		public function WebSocket()
		{
		}
		
		public function connect(ip:String,port:uint):void {
			if(localWebSocket) {
				System.releaseWebSocket(localWebSocket);
			}
			this._ip = ip;
			this._port = port;
			localWebSocket = System.bindWebSocket(ip,port,this,onConnect,onReceiveMessage,onError,onClose);
		}
		
		public function get ip():String {
			return this._ip;
		}
		
		public function get port():uint {
			return this._port;
		}
		
		protected function onConnect():void {
			this.dispatchWidth(Event.CONNECT);
		}
		
		protected function onReceiveMessage(type:String,data:*):void {
		}
		
		public function send(data:*):void {
			System.sendWebSocketUTF(localWebSocket,data);
		}
		
		protected function onError():void {
			this.dispatchWidth(Event.ERROR);
		}
		
		protected function onClose():void {
			this.dispatchWidth(Event.CLOSE);
		}
		
		public function close():void {
			if(localWebSocket) {
				System.releaseWebSocket(localWebSocket);
			}
		}
	}
}