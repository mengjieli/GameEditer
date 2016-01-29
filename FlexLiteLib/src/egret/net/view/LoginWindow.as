package egret.net.view
{
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	import egret.components.Button;
	import egret.components.CheckBox;
	import egret.components.Group;
	import egret.components.Label;
	import egret.events.UIEvent;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.net.protocol.ProtocolConfig;
	import egret.net.util.ProtocolUtil;
	import egret.net.view.skin.LinkButtonSkin;
	import egret.ui.components.TextInput;
	import egret.ui.components.Window;
	import egret.ui.layouts.AttributeQueueLayout;
	import egret.utils.tr;

	/**
	 * 登陆提示框 
	 * @author 雷羽佳
	 * 
	 */	
	public class LoginWindow extends Window
	{
		/**
		 *  
		 * @param onLogin onLogin(name:String,password:String):void
		 * 
		 */		
		public function LoginWindow()
		{
			super();
			this.width = 300;
			this.height = 205;
			this.minWidth = 300;
			this.minHeight = 205;
			this.maximizable = false;
			this.minimizable = false;
			this.resizable = false;
			this.type = NativeWindowType.UTILITY;
			this.title = tr("LoginWindow.Title");
			this.addEventListener(UIEvent.CREATION_COMPLETE,creationComplenetHandler);
		}
		
		protected function creationComplenetHandler(event:UIEvent):void
		{
//			this.nativeWindow.addEventListener(Event.CLOSING,closingHandler);
			this.nativeWindow.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(loginBtn.enabled && event.keyCode == Keyboard.ENTER)
			{
				clickHandler(null);
			}
		}
		
		/**
		 * 用户名
		 */
		public function get username():String
		{
			if(nameInput && nameInput.text)
				return nameInput.text;
			return "";
		}
		
		/**
		 * 密码
		 */
		public function get password():String
		{
			if(passwordInput && passwordInput.text)
				return passwordInput.text;
			return "";
		}
		
		private var _closeDirect:Boolean = false;
		
		private var nameInput:TextInput;
		private var passwordInput:TextInput;
		private var errorLabel:Label;
		private var loginBtn:Button;
		private var rememberPasswordCheckBox:CheckBox;
		override protected function createChildren():void
		{
			super.createChildren();
			
			var userName:String = "";
			var password:String = "";
			var remember:Boolean = false;
			
			userName = ProtocolUtil.read("userName") ?  ProtocolUtil.read("userName") : "";
			password = ProtocolUtil.read("password") ?  ProtocolUtil.read("password") : "";
			remember = ProtocolUtil.read("remember") ?  ProtocolUtil.read("remember") : false;
			
			var group:Group = new Group();
			var attL:AttributeQueueLayout = new AttributeQueueLayout();
			attL.hGap = 10;
			attL.vGap = 10;
			group.top = group.left = group.right = 15;
			group.layout = attL;
			this.addElement(group);
			var label:Label = new Label();
			label.text = tr("LoginWindow.Email");
			group.addElement(label);
			nameInput = new TextInput();
			nameInput.percentWidth = 100;
			nameInput.text = userName;
			nameInput.prompt = "example@example.com"
			nameInput.addEventListener(Event.CHANGE,inputChangeHandler);
			group.addElement(nameInput);
			
			label = new Label();
			label.text = tr("LoginWindow.Passwrod");
			group.addElement(label);
			passwordInput = new TextInput();
			passwordInput.displayAsPassword = true;
			passwordInput.percentWidth = 100;
			passwordInput.text = password;
			passwordInput.addEventListener(Event.CHANGE,inputChangeHandler);
			group.addElement(passwordInput);
			
			errorLabel = new Label();
			errorLabel.left = errorLabel.right = 10;
			errorLabel.textAlign = TextFormatAlign.CENTER;
			errorLabel.maxDisplayedLines = 1;
			errorLabel.bottom = 40;
			errorLabel.visible = false;
			this.addElement(errorLabel);
			
			
			var hGroup:Group = new Group();
			var hL:HorizontalLayout = new HorizontalLayout();
			hL.gap = 15;
			hL.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = hL;
			hGroup.right = 15;
			hGroup.bottom = 60;
			this.addElement(hGroup);
			
			rememberPasswordCheckBox = new CheckBox();
			hGroup.addElement(rememberPasswordCheckBox);
			rememberPasswordCheckBox.label = tr("LoginWindow.RemeberPassword");
			rememberPasswordCheckBox.selected = remember;
			
			var findPasswordBtn:Button = new Button();
			findPasswordBtn.skinName = LinkButtonSkin;
			findPasswordBtn.label = tr("LoginWindow.FindPassword");
			findPasswordBtn.useHandCursor = true;
			findPasswordBtn.buttonMode = true;
			findPasswordBtn.addEventListener(MouseEvent.CLICK,findPasswordHandler);
			hGroup.addElement(findPasswordBtn);
			
			hGroup = new Group();
			hL = new HorizontalLayout();
			hL.gap = 20;
			hGroup.layout = hL;
			hGroup.bottom = 10;
			hGroup.horizontalCenter = 0;
			this.addElement(hGroup);
			
			var button:Button = new Button();
			button.label = tr("LoginWindow.Register");
			button.addEventListener(MouseEvent.CLICK,registerClickHandler);
			hGroup.addElement(button);
			
			loginBtn = new Button();
			loginBtn.label = tr("LoginWindow.Login");
			loginBtn.enabled = false;
			loginBtn.addEventListener(MouseEvent.CLICK,clickHandler);
			hGroup.addElement(loginBtn);
			inputChangeHandler(null);
		}
		
		protected function findPasswordHandler(event:MouseEvent):void
		{
			var url:URLRequest = new URLRequest(ProtocolConfig.FIND_PASSWORD_URL);
			navigateToURL(url,"_blank");
		}
		
		protected function registerClickHandler(event:MouseEvent):void
		{
			var url:URLRequest = new URLRequest(ProtocolConfig.REGISTER_URL);
			navigateToURL(url,"_blank");
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			errorLabel.visible = true;
			errorLabel.text = tr("LoginWindow.Loading");
			errorLabel.textColor = 0xfefefe;
			
			ProtocolUtil.write("userName",nameInput.text);
			if(rememberPasswordCheckBox.selected)
			{
				ProtocolUtil.write("password",passwordInput.text);
				ProtocolUtil.write("remember",true);
			}else
			{
				ProtocolUtil.write("password","");
				ProtocolUtil.write("remember",false);
			}
			this.dispatchEvent(new Event("login"));
		}
		
		protected function inputChangeHandler(event:Event):void
		{
			if(nameInput.text.length > 0 && passwordInput.text.length > 0)
			{
				loginBtn.enabled = true;
			}else
			{
				loginBtn.enabled = false;
			}
		}
		
		public function showError(error:String):void
		{
			errorLabel.textColor = 0xff0000;
			errorLabel.text = error;
			errorLabel.visible = true;
		}
		
		public function showText(text:String):void
		{
			errorLabel.textColor = 0xfefefe;
			errorLabel.text = text;
			errorLabel.visible = true;
		}
		
		public function closeDirect():void
		{
			_closeDirect = true;
			close();
		}
	}
}