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
		public static function getFileListWidthEnd(file:File,end:* = "*"):Vector.<File> {
			if(end is String) {
				end = [end];
			}
			var res:Vector.<File> = new Vector.<File>();
			if(file.isDirectory == false) return res;
			var array:Array = file.getDirectoryListing();
			for(var i:int = 0; i < array.length; i++) {
				file = array[i];
				if(file.isDirectory == false) {
					for(var e:int = 0; e < end.length; e++) {
						if(end[e] == "*" || end[e] == getURLEnd(file.url)) {
							res.push(file);
							break;
						}
					}
				} else {
					res = res.concat(getFileListWidthEnd(file,end));
				}
			}
			return res;
		}
		
		/**
		 * 通过连接获取文件的后缀名
		 */
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
		
		/**
		 * 通过连接获取文件名称
		 */
		public static function getURLName(url:String):String {
			var end:String = getURLEnd(url);
			if(end != "") end = "." + end;
			url = url.slice(0,url.length-end.length);
			var name:String = url;
			for(var i:int = url.length - 1; i >= 0; i--) {
				if(url.charAt(i) == "/") {
					name = url.slice(i+1,url.length);
					break;
				}
			}
			return name;
		}
		
		/**
		 * file:///Users/mengjieli/Documents/paik/paike_client/ParkerEmpire/assets/
		 * (假定当前应用程序目录/Users/mengjieli/Documents/flash/GameEditer/Editer/bin-debug)
		 * 转换为 ../../../../../..//Users/mengjieli/Documents/paik/paike_client/ParkerEmpire/assets/
		 */
		public static function transToRelationURL(url:String):String {
			var appURL:String = File.applicationDirectory.nativePath;
			if(url.slice(0,"file://".length) == "file://") {
				url = url.slice("file://".length,url.length);
			}
			return url;
		}
	}
}