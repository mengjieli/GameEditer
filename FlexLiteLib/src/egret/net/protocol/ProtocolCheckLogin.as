package egret.net.protocol
{
	import flash.net.URLVariables;
	
	/**
	 * 验证登陆接口
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolCheckLogin extends ProtocolNetBase
	{
		/**
		 * 用户的UID，账户唯一ID
		 */		
		public var uid:String = "";
		/**
		 * 存储在本地的验证登陆的唯一串 
		 */		
		public var cookie:String = "";
		public function ProtocolCheckLogin()
		{
			action = ProtocolActionType.CHECK_LOGIN;
		}
		
		override protected function getVariables():URLVariables
		{
			var urlVariableds:URLVariables = new URLVariables();
			urlVariableds["action"] = getEncrypt(action);
			urlVariableds["uid"] = getEncrypt(uid);
			urlVariableds["cookie"] = cookie;
			return urlVariableds;
		}
	}
}


