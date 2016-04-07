package FileSyncModel
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;

	public class Thread
	{
		private var worker:Worker;
		private var parent:Worker;
		private var mainToBack:MessageChannel;
		private var backToMain:MessageChannel;
		private var common:ByteArray;
		private var workerBytes:ByteArray;
		
		public function Thread()
		{
			trace(Worker.current.isPrimordial);
			if(Worker.current.isPrimordial) {
				worker = WorkerDomain.current.createWorker(loaderInfo.bytes);
				//创建到worker的MessageChannel通信对象
				mainToBack = Worker.current.createMessageChannel(worker);
				//创建来自worker的MessageChannel通信对象并添加监听.
				backToMain = worker.createMessageChannel(Worker.current);
				backToMain.addEventListener(Event.CHANNEL_MESSAGE,onBackToMain, false, 0, true);
				
				common = new ByteArray();
				common.shareable = true;
				common.writeUTF("/Users/mengjieli/Documents/paik/paike_client/ParkerEmpire/assets");
				worker.setSharedProperty("common",common);
				worker.setSharedProperty("mainToBack",mainToBack);
				worker.setSharedProperty("backToMain",backToMain);
				
				worker.start();
				
				mainToBack.send("checkFile");
			} else {
				workerBytes = new ByteArray();
				workerBytes.shareable = true;
				parent = Worker.current;
				parent.setSharedProperty("workerBytes",workerBytes);
				common = parent.getSharedProperty("common");
				backToMain = parent.getSharedProperty("backToMain");
				mainToBack = parent.getSharedProperty("mainToBack");
				mainToBack.addEventListener(Event.CHANNEL_MESSAGE,onMainToBack, false, 0, true);
			}
		}
		
		
		private function onMainToBack(e:Event):void {
			var msg:String = mainToBack.receive();
			//trace("线程",msg);
			if(msg == "checkFile") {
				common.position = 0;
				var fileURL:String = common.readUTF();
								common.writeInt(123);
								workerBytes.writeInt(456);
								backToMain.send("ok");
			}
		}
		
		private function onBackToMain(e:Event):void {
			var msg:String = backToMain.receive();
			if(!workerBytes) {
				workerBytes = worker.getSharedProperty("workerBytes");
			}
			trace("主线程",msg,common.length,workerBytes.length);
		}
	}
}