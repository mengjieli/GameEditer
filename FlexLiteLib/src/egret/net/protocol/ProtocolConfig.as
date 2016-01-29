package egret.net.protocol
{
	/**
	 * 协议配置 
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolConfig
	{
		
		/**
		 * 协议接口地址 
		 */		
		public static const PROTOCOL_URL:String = "http://softopen.egret-labs.org/open.php";
		/**
		 * 注册地址地址
		 */		
		public static const REGISTER_URL:String = "http://bbs.egret-labs.org/member.php?mod=new";
		/**
		 * 找回密码地址
		 */		
		public static const FIND_PASSWORD_URL:String = "http://bbs.egret-labs.org/home.php?mod=spacecp&ac=profile&op=password";
		/**
		 * 修改密码地址
		 */		
		public static const CHANGE_PASSWORD_URL:String = "http://bbs.egret-labs.org/home.php?mod=spacecp&ac=profile&op=password";
		/**
		 * 申请内测地址
		 */		
		public static const APPLY_URL:String = "http://bbs.egret-labs.org/member.php?mod=new";
		
		public static const PROTOCOL_KEY:String = "336ac2ae08c23bff9b814bbc651d9e1d";
		public static const PROTOCOL_ENABLED:Boolean = true;
		public static const PROTOCOL_LOG:Boolean = true;
	}
}