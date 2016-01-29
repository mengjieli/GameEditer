package main.data.gameProject.path
{
	public class PathData
	{
		/**
		 * 相对于项目的根目录
		 */
		public var url:String;
		/**
		 * 描述的名称，方便阅读，一般为中文
		 */
		public var desc:String = "";
		/**
		 * 是否为虚拟目录
		 */
		public var virtual:Boolean = false;
		
		public function PathData()
		{
		}
		
		/**
		 * 获取路径的展示名称
		 */
		public function get name():String {
			return url.split("/")[url.split("/").length-1];
		}
		
		public function get nameDesc():String {
			if(desc != "") return desc;
			return url.split("/")[url.split("/").length-1];
		}
	}
}