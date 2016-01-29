package egret.net.protocol
{
	/**
	 * 协议Action类型 
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolActionType
	{
		/**
		 * 登陆 
		 */		
		public static const LOGIN:String = "login";
		/**
		 * 退出登陆 
		 */		
		public static const LOGOUT:String = "logout";
		/**
		 * 检查登陆 
		 */		
		public static const CHECK_LOGIN:String = "checklogin";
		/**
		 * 信息收集 
		 */		
		public static const SOFT_INFO:String = "softinfo";
	}
}