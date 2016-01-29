package egret.net.protocol
{
	import flash.net.URLVariables;
	
	/**
	 * 退出登陆接口
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolLogout extends ProtocolNetBase
	{
		/**
		 * 用户的UID，账户唯一ID
		 */		
		public var uid:String = "";
		/**
		 * 存储在本地的验证登陆的唯一串
		 */	
		public var cookie:String = "";
		public function ProtocolLogout()
		{
			action = ProtocolActionType.LOGOUT;
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


