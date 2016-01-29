package egret.net.protocol
{
	import flash.net.URLVariables;
	/**
	 * 登录接口 
	 * @author 雷羽佳
	 * 
	 */
	public class ProtocolLogin extends ProtocolNetBase
	{
		/**
		 * 用户邮箱，邮箱来⾃自于论坛注册时使⽤用的邮箱 
		 */		
		public var email:String = "";
		/**
		 * 账号密码 
		 */		
		public var password:String = "";
		
		public function ProtocolLogin()
		{
			action = ProtocolActionType.LOGIN;
		}
		
		override protected function getVariables():URLVariables
		{
			var urlVariableds:URLVariables = new URLVariables();
			urlVariableds["action"] = getEncrypt(action);
			urlVariableds["email"] = getEncrypt(email);
			urlVariableds["password"] = getEncrypt(password);
			return urlVariableds;
		}
		
	}
}