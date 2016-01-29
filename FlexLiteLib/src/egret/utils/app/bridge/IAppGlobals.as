package egret.utils.app.bridge
{
	public interface IAppGlobals
	{
		/**
		 * 更新服务器的地址
		 */
		function get updateServer():String;
		
		/**
		 * 应用程序对应的更新url
		 */
		function getUpdateURL(appID:String):String;
		
		/**
		 * 是否使用开发版本
		 */
		function getUseDev(appID:String):Boolean;
		function setUseDev(appID:String , value:Boolean):void;
		
		/**
		 * 检查是否需要更新
		 * @param appID 应用程序ID
		 * @param complete 检查完毕的回调函数 complete(result:String):void , 
		 * state为字符串可能值为apperror表示应用程序无法找到  neterror表示网络连接错误 ， true表示需要更新 ， false表示不需要更新
		 */
		function checkNeedUpdate(appID:String , complete:Function):void;
		
		/**
		 * 检查更新
		 * @param appID 应用程序ID
		 * @param needTips 是否需要UI提示
		 */
		function checkUpdate(appID:String , needTips:Boolean = false):void;
		
		/**
		 * 检查服务器版本号
		 * @param appPath 应用程序ID
		 * @param complete 检查完毕的回调函数 complete(version:String , versionLabel:String):void , 
		 * version为最新版本号，versionLabel为第二版本
		 */
		function checkVersion(appID:String , complete:Function):void;
		
		/**
		 * 获取应用程序的描述文件
		 */
		function getAppXML(appPath:String):XML;
		
		/**
		 * 获取程序的安装路径，如果不存在在返回空字符串
		 */
		function findInstallPath(appID:String):String;
		
		/**
		 * 判断versionA是否小于versionB
		 */
		function compareVersion(versionA:String,versionB:String):Boolean;
	}
}