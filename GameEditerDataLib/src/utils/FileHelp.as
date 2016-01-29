package utils
{
	import flash.filesystem.File;

	public class FileHelp
	{
		public function FileHelp()
		{
		}
		
		/**
		 * 读取具有某种结尾的所有文件列表
		 */
		public static function getFileListWidthEnd(file:File,end:String = "*"):Vector.<File> {
			var res:Vector.<File> = new Vector.<File>();
			if(file.isDirectory == false) return res;
			var array:Array = file.getDirectoryListing();
			for(var i:int = 0; i < array.length; i++) {
				file = array[i];
				if(file.isDirectory == false) {
					if(end == "*" || end == getURLEnd(file.url)) {
						res.push(file);
					}
				} else {
					res = res.concat(getFileListWidthEnd(file,end));
				}
			}
			return res;
		}
		
		public static function getURLEnd(url:String):String {
			var end:String = "";
			for(var i:int = url.length - 1; i >= 0; i--) {
				if(url.charAt(i) == ".") {
					end = url.slice(i+1,url.length);
				} else if(url.charAt(i) == "/" || url.charAt(i) == ":") {
					break;
				}
			}
			return end;
		}
	}
}