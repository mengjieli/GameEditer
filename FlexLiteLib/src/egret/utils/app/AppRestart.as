package egret.utils.app
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	import egret.utils.SystemInfo;

	/**
	 * 重启应用程序
	 * @author xzper
	 */
	public class AppRestart
	{
		public function AppRestart()
		{
		}
		
		public static function start():void
		{
			var appConfig:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appConfig.namespace();
			var fileName:String = appConfig.ns::filename[0].toString();
			var appLauncher:File;
			if(SystemInfo.isMacOS)
			{
				var appFile:File = new File(File.applicationDirectory.nativePath);
				appLauncher = appFile.parent.resolvePath("MacOS/"+fileName);
			}
			else
			{
				appLauncher = File.applicationDirectory.resolvePath(fileName+".exe");
			}
			
			try
			{
				var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo;
				npInfo.executable = appLauncher;
				var args:Vector.<String> = new Vector.<String>;
				npInfo.arguments = args;
				var np:NativeProcess = new NativeProcess;
				np.start(npInfo);
			} 
			catch(error:Error) 
			{
			}
			NativeApplication.nativeApplication.exit();
		}
	}
}