package egret.utils
{
	import flash.utils.ByteArray;
	
	/**
	 * SWC文件解析器
	 * @author dom
	 */
	public class SwcParser
	{
		/**
		 * 读取一个swc路径，返回内部的swf字节流。
		 * @param path swc路径
		 */		
		public static function open(path:String):ByteArray
		{
			var bytes:ByteArray = FileUtil.openAsByteArray(path);
			if(!bytes)
				return null;
			return parse(bytes);
		}
		/**
		 * 从一个swc的字节流文件内提取swf字节流
		 */		
		public static function parse(swcBytes:ByteArray):ByteArray
		{
//			var zipFile:ZipFile = new ZipFile(swcBytes);   
//			var zipEntry:ZipEntry = zipFile.getEntry("library.swf");   
//			var swfBytes:ByteArray = zipFile.getInput(zipEntry);
//			return swfBytes;
			return null;
		}
	}
}