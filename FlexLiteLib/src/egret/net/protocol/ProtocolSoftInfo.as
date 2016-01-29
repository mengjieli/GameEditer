package egret.net.protocol
{
	import flash.net.URLVariables;
	
	/**
	 * 信息收集
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolSoftInfo extends ProtocolNetBase
	{
		/**
		 * 该参数为了区别不同软件，此处如果是Egret Wing，则填写wing 
		 */		
		public var softid:String = "";
		/**
		 * 用户的UID，账户唯一ID
		 */	
		public var uid:String = "";
		/**
		 * 存储在本地的验证登陆的唯⼀一串 
		 */		
		public var cookie:String = "";
		/**
		 * 系统类型，win或者mac
		 */		
		public var systemtype:String = "";
		/**
		 * 系统版本
		 */		
		public var systemversion:String = "";
		/**
		 * 软件版本
		 */		
		public var softversion:String = "";
		/**
		 * AIR环境的版本
		 */		
		public var airversion:String = "";
		/**
		 * 项目名称
		 */		
		public var projectname:String = "";
		/**
		 * 开启软件的时间
		 */		
		public var starttime:String = "";
		/**
		 * 关闭软件的时间
		 */		
		public var closetime:String = "";
		/**
		 * 软件实际使用时间
		 */		
		public var usedtime:String = "";
		
		
		public function ProtocolSoftInfo()
		{
			action = ProtocolActionType.SOFT_INFO;
		}
		
		override protected function getVariables():URLVariables
		{
			var urlVariableds:URLVariables = new URLVariables();
			urlVariableds["action"] = getEncrypt(action);
			urlVariableds["softid"] = getEncrypt(softid);
			urlVariableds["uid"] = getEncrypt(uid);
			urlVariableds["cookie"] = cookie;
			urlVariableds["systemtype"] = getEncrypt(systemtype);
			urlVariableds["systemversion"] = getEncrypt(systemversion);
			urlVariableds["softversion"] = getEncrypt(softversion);
			urlVariableds["airversion"] = getEncrypt(airversion);
			urlVariableds["projectname"] = getEncrypt(projectname);
			urlVariableds["starttime"] = getEncrypt(starttime);
			urlVariableds["closetime"] = getEncrypt(closetime);
			urlVariableds["usedtime"] = getEncrypt(usedtime);
			return urlVariableds;
		}
	}
}


