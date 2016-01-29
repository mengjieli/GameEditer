package main.model.loginModel
{
	import main.data.ToolData;
	import main.model.errorTipModel.TipModel;
	import main.net.MyByteArray;

	public class LoginNotifyModel
	{
		public function LoginNotifyModel()
		{
			ToolData.getInstance().server.register(2007,onNotifyLogin);
			ToolData.getInstance().server.register(2009,onNotifyDisconnectGame);
		}
		
		private function onNotifyLogin(cmd:Number,msg:MyByteArray):void {
			var id:Number = msg.readUIntV();
			var ip:String = msg.readUTFV();
			ToolData.getInstance().mobile.id = id;
			ToolData.getInstance().mobile.name = ip;
			ToolData.getInstance().mobile.connected = true;
		}
		
		private function onNotifyDisconnectGame(cmd:Number,msg:MyByteArray):void {
			var id:Number = msg.readUIntV();
			if(id == ToolData.getInstance().mobile.id) {
				TipModel.show("与游戏客户端断开链接",0xfd5a14);
				ToolData.getInstance().mobile.id = 0;
				ToolData.getInstance().mobile.name = "";
				ToolData.getInstance().mobile.connected = false;
			}
		}
	}
}