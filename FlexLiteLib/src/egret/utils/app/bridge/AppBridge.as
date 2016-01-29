package egret.utils.app.bridge
{
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import egret.utils.FileUtil;
	import egret.utils.LoaderUtil;
	import egret.utils.SwcParser;
	import egret.utils.app.AppConnection;

	/**
	 * @author xzper
	 */
	public class AppBridge
	{
		public function AppBridge()
		{
		}
		
		/**
		 * @copy  IAppGlobals#updateServer
		 */
		public static function get updateServer():String
		{
			if(bridge)
				return bridge.updateServer;
			return "";
		}
		
		/**
		 * @copy  IAppGlobals#getUpdateURL()
		 */
		public static function getUpdateURL(appID:String):String
		{
			if(bridge)
				return bridge.getUpdateURL(appID);
			return "";
		}
		
		/**
		 * @copy  IAppGlobals#checkNeedUpdate()
		 */
		public static function checkNeedUpdate(appID:String , complete:Function):void
		{
			if(bridge)
				bridge.checkNeedUpdate(appID , complete);
		}
		
		/**
		 * @copy  IAppGlobals#checkUpdate()
		 */
		public static function checkUpdate(appID:String , needTips:Boolean = false):void
		{
			if(bridge)
				bridge.checkUpdate(appID , needTips);
		}
		
		/**
		 * @copy  IAppGlobals#checkVersion()
		 */
		public static function checkVersion(appID:String , complete:Function):void
		{
			if(bridge)
				bridge.checkVersion(appID , complete);
		}
		
		/**
		 * @copy  IAppGlobals#compareVersion()
		 */
		public static function compareVersion(versionA:String,versionB:String):Boolean
		{
			if(bridge)
				return bridge.compareVersion(versionA,versionB);
			else
				return false;
		}
		
		/**
		 * @copy  IAppGlobals#findInstallPath()
		 */
		public static function findInstallPath(appID:String):String
		{
			if(bridge)
				return bridge.findInstallPath(appID);
			else
				return "";
		}
		
		/**
		 * @copy  IAppGlobals#getUseDev()
		 */
		public static function getUseDev(appID:String):Boolean
		{
			if(bridge)
				return bridge.getUseDev(appID);
			else
				return false;
		}
		
		/**
		 * @copy  IAppGlobals#setUseDev()
		 */
		public static function setUseDev(appID:String,value:Boolean):void
		{
			if(bridge)
				bridge.setUseDev(appID,value);
		}
		
		/**
		 * @copy  IAppGlobals#getAppXML()
		 */
		public static function getAppXML(appPath:String):XML
		{
			if(bridge)
				return bridge.getAppXML(appPath);
			else
				return null;
		}
		
		/**
		 * 是否已经加载完成
		 */
		public static function get hasLoad():Boolean
		{
			return bridge?true:false;
		}
		
		/**
		 * 加载应用程序EgretBridge.swc
		 * @param complete 加载完成的回调 function(result:Boolean):void 
		 * @param path 
		 */
		public static function load(complete:Function , path:String = ""):void
		{
			if(!path || !FileUtil.exists(path))
				path = AppConnection.appManagerPath+"bin/EgretBridge.swc";
			var byteArray:ByteArray = SwcParser.open(path);
			if(byteArray)
			{
				comp = complete;
				LoaderUtil.loadLoaderFromBytes(byteArray,onSwcComplete,null,onError);
			}else
			{
				complete(false);
			}
		}
		
		private static function onError(event:IOErrorEvent):void
		{
			if(comp != null)
				comp(false);
			comp = null;
		}
		
		private static var comp:Function;
		private static var bridge:IAppGlobals;
		
		private static function onSwcComplete(data:Loader):void
		{
			var domain:ApplicationDomain = data.contentLoaderInfo.applicationDomain;
			var AppGlobals:Class = domain.getDefinition("egret.bridge.AppGlobals") as Class;
			bridge = new AppGlobals() as IAppGlobals;
			if(comp != null)
				comp(true);
			comp = null;
		}
		
	}
}