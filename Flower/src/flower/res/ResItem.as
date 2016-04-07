package flower.res
{
	public class ResItem
	{
		/**
		 * 加载的路径
		 */
		public var url:String;
		
		/**
		 * 加载的类型
		 */
		public var type:String;
		
		/**
		 * 服务器加载路径
		 */
		public var serverURL:String;
		
		/**
		 * 本地加载路径
		 */
		public var localURL:String;
		
		/**
		 * 是否在本地
		 */
		public var local:Boolean = true;
		
		public function ResItem()
		{
		}
		
		public function get loadURL():String {
			if(local) {
				return localURL + url;
			}
			return serverURL + url;
		}
	}
}