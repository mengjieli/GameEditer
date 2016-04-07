package main.model.loginModel
{
	import flash.events.EventDispatcher;
	
	import main.data.ToolData;
	import main.model.errorTipModel.TipModel;
	import main.net.MyByteArray;
	import main.panels.netWaitPanel.NetWaitingPanel;

	public class LoginModel extends EventDispatcher
	{
		public function LoginModel()
		{
			var loginName:String = ToolData.getInstance().getConfigValue("loginUser");
			var loginPassword:String = ToolData.getInstance().getConfigValue("loginPassword");
			ToolData.getInstance().userName = loginName;
			if(!loginName || loginName == "") {
				new LoginPanel().open(false);
			} else {
				this.autoLogin();
			}
			ToolData.getInstance().server.registerZero(1,this.onLoginBack);
		}
		
		private function autoLogin():void {
			NetWaitingPanel.show("自动登录中 ...");
			var loginName:String = ToolData.getInstance().getConfigValue("loginUser");
			var loginPassword:String = ToolData.getInstance().getConfigValue("loginPassword");
			var bytes:MyByteArray = new MyByteArray();
			bytes.writeUIntV(1);
			bytes.writeUTFV("client");
			bytes.writeUTFV(loginName);
			bytes.writeUTFV(loginPassword);
			bytes.writeUTFV("*");
			ToolData.getInstance().server.send(bytes);
		}
		
		private function onLoginBack(cmd:Number,errorCode:Number):void {
			ToolData.getInstance().server.removeZeroe(1,this.onLoginBack);
			if(errorCode == 0) {
				NetWaitingPanel.hide();
//				TipModel.show("登录成功");
			} else {
				new LoginPanel().open(false);
			}
		}
	}
}