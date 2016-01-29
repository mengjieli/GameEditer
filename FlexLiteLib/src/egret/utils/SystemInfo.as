package egret.utils
{
	import flash.filesystem.File;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.system.Capabilities;
	
	/**
	 * 系统信息查询类
	 * @author 雷羽佳
	 */
	public class SystemInfo
	{
		public function SystemInfo()
		{
		}
	
		/**
		 * 是否是mac系统 
		 */		
		public static function get isMacOS():Boolean
		{
			return Capabilities.manufacturer == "Adobe Macintosh";
		}
		
		private static var _nativeStoragePath:String = "";
		/**
		 * 本机应用程序储存目录根路径。路径已包含结尾分隔符。分隔符为原生格式。
		 * Mac：/用户目录/Library/Application Support/ 
		 * Windows：\用户目录\AppData\Roaming\
		 */		
		public static function get nativeStoragePath():String
		{
			if(_nativeStoragePath)
				return _nativeStoragePath;
			if(isMacOS)
			{
				_nativeStoragePath = File.userDirectory.nativePath+"/Library/Application Support/";
			}
			else
			{
				var file:File = new File(File.applicationStorageDirectory.nativePath);
				_nativeStoragePath = file.parent.parent.nativePath+"\\";
			}
			return _nativeStoragePath;
		}
		/**
		 * 本机IP地址
		 */	
		public static function get IP():String
		{
			var netInfo:NetworkInfo = NetworkInfo.networkInfo;
			var interfaces:Vector.<NetworkInterface>=netInfo.findInterfaces();
			var ip:String = "";
			if(interfaces != null)
			{
				for(var i:int = 0;i<interfaces.length;i++)
				{
					if(interfaces[i].active == true)
					{
						ip = interfaces[i].addresses[0].address;
						break;
					}
				}
			}
			ip = ip.toLocaleUpperCase();
			return ip;
		}
	}
}