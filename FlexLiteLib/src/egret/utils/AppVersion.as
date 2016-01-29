package egret.utils
{
	import flash.desktop.NativeApplication;
	
	/**
	 * 获取程序当前版本号
	 * @author dom
	 */
	public class AppVersion
	{
		private static var _currentVersion:String;
		private static var _currentVersionLabel:String;
		
		/**
		 * 版本号
		 */
		public static function get currentVersion():String
		{
			if(_currentVersion)
				return _currentVersion;
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;  
			var ns:Namespace = appXml.namespace();  
			_currentVersion = appXml.ns::versionNumber[0].toString();  
			return _currentVersion;
		}
		
		/**
		 * 版本的文本，可以作为第二版本号
		 */
		public static function get currentVersionLabel():String
		{
			if(_currentVersionLabel)
				return _currentVersionLabel;
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;  
			var ns:Namespace = appXml.namespace();
			if(appXml.ns::versionLabel[0])
				_currentVersionLabel = appXml.ns::versionLabel[0].toString();
			else
				_currentVersionLabel = "";
			return _currentVersionLabel;
		}
		
		/**
		 * 比较版本号，判断版本A是否小于版本B
		 */
		public static function compareVersion(versionA:String, versionB:String):Boolean
		{
			var lessThan:Boolean = false;
			var index:int=0;
			var vAs:Array = versionA.split(".");
			var vBs:Array = versionB.split(".");
			for each(var vB:String in vBs)
			{
				var vA:String = vAs[index]?vAs[index]:"0";
				if(int(vB)>int(vA))
				{
					lessThan = true;
					break;
				}
				else if(int(vB)<int(vA))
				{
					break;
				}
				index++;
			}
			return lessThan;
		}
	}
}