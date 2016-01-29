package main.model.loginModel
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import egret.components.Button;
	import egret.components.EditableText;
	import egret.components.Label;
	import egret.core.UIComponent;
	import egret.ui.components.Window;
	
	import main.data.ToolData;
	import main.model.errorTipModel.TipModel;
	import main.net.MyByteArray;
	import main.panels.netWaitPanel.NetWaitingPanel;

	public class LoginPanel extends Window
	{
		public function LoginPanel()
		{
			this.title = "登录服务器";
			this.width = 400;
			this.height = 300;
		}
		
		
		private var userTxt:EditableText;
		private var passwordTxt:EditableText;
		protected override function createChildren():void
		{
			super.createChildren();
			this.minimizable = this.maximizable = this.closeButton.visible = false;
			
			var label:Label;
			
			label = new Label();
			label.text = "用户名";
			this.addElement(label);
			label.x = 60;
			label.y = 50;
			var sp:UIComponent = new UIComponent();
			sp.graphics.beginFill(0xdddddd,1);
			sp.graphics.drawRect(0,0,150,20);
			this.addElement(sp);
			sp.x = 120;
			sp.y = 50;
			userTxt = new EditableText();
			userTxt.width = 150;
			userTxt.height = 20;
			this.addElement(userTxt);
			userTxt.x = 120;
			userTxt.y = 50;
			userTxt.textColor = 0;
			
			label = new Label();
			label.text = "密码";
			this.addElement(label);
			label.x = 60;
			label.y = 90;
			sp = new UIComponent();
			sp.graphics.beginFill(0xdddddd,1);
			sp.graphics.drawRect(0,0,150,20);
			this.addElement(sp);
			sp.x = 120;
			sp.y = 90;
			passwordTxt = new EditableText();
			passwordTxt.width = 150;
			passwordTxt.height = 20;
			this.addElement(passwordTxt);
			passwordTxt.displayAsPassword = true;
			passwordTxt.x = 120;
			passwordTxt.y = 90;
			passwordTxt.textColor = 0;
			
			var btn:Button;
			btn = new Button();
			btn.label = "登录";
			btn.horizontalCenter = 0;
			btn.bottom = 40;
			this.addElement(btn);
			btn.addEventListener(MouseEvent.CLICK,onLogin);
			
			ToolData.getInstance().server.registerZero(1,this.onLoginBack);
		}
		
		private var user:String;
		private var password:String;
		private function onLogin(e:MouseEvent):void {
			var bytes:MyByteArray = new MyByteArray();
			bytes.writeUIntV(1);
			bytes.writeUTFV("client");
			bytes.writeUTFV(userTxt.text);
			bytes.writeUTFV(passwordTxt.text);
			bytes.writeUTFV("*");
			ToolData.getInstance().server.send(bytes);
			user = userTxt.text;
			password = passwordTxt.text;
		}
		
		private function onLoginBack(cmd:Number,errorCode:Number):void {
			if(errorCode == 0) {
				ToolData.getInstance().server.removeZeroe(1,this.onLoginBack);
				this.close();
				ToolData.getInstance().saveConfigValue("loginUser",user);
				ToolData.getInstance().saveConfigValue("loginPassword",password);
				NetWaitingPanel.hide();
				TipModel.show("登录成功");
			}
		}
	}
}