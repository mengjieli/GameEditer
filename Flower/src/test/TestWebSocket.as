package test
{
	import flower.events.Event;
	import flower.net.VBWebSocket;
	import flower.utils.VByteArray;

	public class TestWebSocket
	{
		private var socket:VBWebSocket;
		
		public function TestWebSocket()
		{
			socket = new VBWebSocket();
			socket.connect("localhost",9999);
			socket.addListener(Event.CONNECT,this.onConnect,this);
			socket.addListener(Event.ERROR,onError,this);
			socket.addListener(Event.CLOSE,onClose,this);
			socket.register(2,onLoginBack,this);
		}
		
		private function onConnect(e:Event):void {
			var bytes:VByteArray = new VByteArray();
			bytes.writeUInt(1);
			bytes.writeUTF("limengjie");
			bytes.writeInt(-1);
			socket.send(bytes);
		}
		
		private function onLoginBack(cmd:int,bytes:VByteArray):void {
			var str:String = bytes.readUTF();
			var num:int = bytes.readInt();
			trace(str,num,bytes.position,bytes.bytesAvailable);
		}
		
		private function onError(e:Event):void {
			trace("connect error");
		}
		
		private function onClose(e:Event):void {
			trace("connect close");
		}
	}
}