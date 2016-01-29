package main.model.errorTipModel
{
	import flash.filesystem.FileStream;
	
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.net.MyByteArray;

	public class ErrorTipModel
	{
		private var tips:Object = {};
		
		public function ErrorTipModel()
		{
			ToolData.getInstance().server.register(0,onZero);
			
			var file:FileStream = FileUtil.open("locales/ErrorCode.txt");
			var str:String = file.readUTFBytes(file.bytesAvailable);
			file.close();
			var array:Array = str.split("\n");
			for(var i:Number = 0; i < array.length; i++) {
				var line:String = array[i];
				var code:Number = Number(line.split(" ")[0]);
				var tip:String = line.split(" ")[1];
				tips[code] = tip;
				
			}
		}
		
		private function onZero(cmd:Number,bytes:MyByteArray):void {
			var backCmd:Number = bytes.readUIntV();
			var errorCode:Number = bytes.readUIntV();
			if(errorCode != 0) {
				var tip:String = tips[errorCode];
				if(tip && errorCode == 5) {
					tip += ":" + backCmd;
				}
				TipModel.show(tip?tip:"未知错误码:" + errorCode,0xff838f);
			}
		}
	}
}