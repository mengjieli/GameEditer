package egret.utils
{
	import flash.filesystem.File;
	
	import egret.utils.app.bridge.AppBridge;

	/**
	 * 获取EgretPath的工具
	 */
	public class EgretPath
	{
		public function EgretPath()
		{
		}
		
		/**
		 * 获取node可执行文件的位置, 使用此方法请确保AppBridge已经初始化完毕
		 */
		public static function getNodeFile():File
		{
			var egretPath:String = getInstallerPath();
			if(egretPath)
			{
				var file:File = new File(egretPath);
				if(SystemInfo.isMacOS)
				{
					file = file.resolvePath("Contents/Resources/mac/node");
				}
				else
				{
					file = file.resolvePath("win/node.exe");
				}
				if(file.exists)
					return file;
			}
			return null;
		}
		
		/**
		 * 获取Egret安装包的位置 , 使用此方法请确保AppBridge已经初始化完毕
		 */
		public static function getInstallerPath():String
		{
			return AppBridge.findInstallPath("EgretEngine");
		}
		
		/**
		 * 获取
		 * @param key 环境变量的键，例如：EGRET_PATH
		 * @param compFunc 获取完成的回调函数,示例：compFunc(value:String)
		 */			
		public static function getValue(compFunc:Function):void
		{
			var onGetEgretPath:Function = function(value:String):void
			{
				if(value)
				{
					compFunc(value);
				}
				else
				{
					var path:String;
					if(SystemInfo.isMacOS)
					{
						if(FileUtil.exists("/usr/local/lib/node_modules/egret/"))
						{
							path = "/usr/local/lib/node_modules/egret/";
						}
					}
					else
					{
						var npmPath:String = SystemInfo.nativeStoragePath+"npm\\node_modules\\egret\\";
						if(FileUtil.exists(npmPath))
						{
							path = npmPath;
						}
					}
					if(FileUtil.exists(path+"EgretEngine"))
					{
						path = FileUtil.openAsString(path+"EgretEngine");
						if(path)
						{
							path = StringUtil.trim(path);
							path = path +File.separator+"egret"+File.separator;
							compFunc(path);
							return;
						}
					}
					compFunc("");
				}
			}
			Environment.getValue("EGRET_PATH",onGetEgretPath);
		}
	}
}