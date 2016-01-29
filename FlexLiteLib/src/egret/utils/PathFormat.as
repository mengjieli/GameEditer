package egret.utils
{
	import flash.filesystem.File;
	/**
	 * 路径格式化的工具
	 * @xzper
	 */
	public class PathFormat
	{
		public function PathFormat()
		{
		}
		
		/**
		 * 返回指定路径是否是文件夹
		 */
		public static function isDirectory(path:String):Boolean
		{
			var file:File = new File(path);
			if(file.exists)
			{
				if(file.isSymbolicLink)
					return false;
				return file.isDirectory;
			}
			else
			{
				if(path.charAt(path.length-1)=="/")
					return true;
				else
					return false;
			}
		}
		
		/**
		 * 去除字符串首尾的引号
		 */
		public static function clearQuotes(value:String):String
		{
			var firstChar:String = value.charAt(0);
			var lastChar:String = value.charAt(value.length-1);
			if(firstChar == lastChar&&(firstChar=="\""||firstChar=="'"))
			{
				value = value.substring(1,value.length-1);
			}
			return value;
		}
		
		/**
		 * 格式化路径
		 */
		public static function formatPath(path:String):String
		{
			path = clearQuotes(path);
			if(isDirectory(path))
			{
				return FileUtil.escapePath(path);
			}
			else
			{
				return FileUtil.escapeUrl(path);
			}
		}
	}
}