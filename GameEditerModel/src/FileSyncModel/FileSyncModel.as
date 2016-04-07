package FileSyncModel
{
	import main.data.ToolData;
	import main.model.ModelBase;
	import main.net.MyByteArray;

	/**
	 * 文件同步模块，同步编辑器项目文件和客户端项目文件
	 */
	public class FileSyncModel extends ModelBase
	{
		public function FileSyncModel()
		{
			if(ToolData.getInstance().server) {
				ToolData.getInstance().server.register(2013,onFileServerStart);
			}
		}
		
		private function onFileServerStart(cmd:uint,bytes:MyByteArray):void {
			trace(cmd);
			var ip:String = bytes.readUTFV();
			var port:uint = bytes.readUIntV();
			new NodeJS("nodejs/FileSync.js",[ip,port,ToolData.getInstance().userName]);
		}
		
		override public function get modelName():String {
			return "FileSyncModel";
		}
	}
}