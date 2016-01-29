package egret.utils
{
	import flash.filesystem.File;
	
	/**
	 * 本地工作空间目录读取工具类
	 * @author dom
	 */
	public class EgretWorkspace
	{
		private static var _workspacePath:String = "";
		/**
		 * 工作空间目录,结尾已经包含“/”分隔符。
		 */		
		public static function get workspacePath():String
		{
			if(!_workspacePath)
			{
				readWorkspacePath();
			}
			return _workspacePath;
		}
		
		private static function readWorkspacePath():void
		{
			var path:String = File.userDirectory.nativePath+"/egret_workspace.txt";
			if(FileUtil.exists(path))
			{
				_workspacePath = FileUtil.openAsString(path);
				_workspacePath = StringUtil.trim(_workspacePath);
				_workspacePath = FileUtil.escapePath(_workspacePath);				
			}
			else
			{
				if(SystemInfo.isMacOS)
				{
					_workspacePath = "/Users/egret/Documents/Program/Flash/";
				}
				else
				{
					_workspacePath = "D:/Program/Flash/";
				}
				
			}
		}
	}
}