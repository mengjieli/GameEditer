package main.model.logModel
{
	import main.data.LogData;
	import main.data.ToolData;
	import main.net.MyByteArray;

	public class GameLogModel
	{
		public function GameLogModel()
		{
			ToolData.getInstance().server.register(2011,onReceiveLog);
		}
		
		private function onReceiveLog(cmd:Number,msg:MyByteArray):void {
			var color:uint = msg.readUIntV();
			var len:Number = msg.readUIntV();
			var str:String = "";
			for(var i:Number = 0; i < len; i++) {
				str += msg.readUTFV();
			}
			ToolData.getInstance().log.addLog(color,str);
			while(ToolData.getInstance().log.logs.length > LogData.MAX) {
				ToolData.getInstance().log.shiftLog();
			}
		}
	}
}