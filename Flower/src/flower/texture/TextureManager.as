package flower.texture
{
	import flower.Engine;
	import flower.debug.DebugInfo;

	/**
	 *纹理管理器 
	 * @author MengJie.Li
	 * 
	 */	
	public class TextureManager
	{
		private var list:Vector.<Texture2D> = new Vector.<Texture2D>();
		
		public function TextureManager()
		{
			if(classLock == true)
			{
				DebugInfo.debug("无法创建对象TextureManager，此类为单例模式，请访问TextureManager.getInstance()",DebugInfo.WARN);
				return;
			}
		}
		
		/**
		 *
		 *加载纹理 
		 * @param url 纹理地址 
		 * @param w 纹理宽
		 * @param h 纹理高
		 * @return 返回true表示第一次创建，false表示已加载过的纹理
		 * 
		 */		
		public function createTexture(nativeTexture:*,url:String,nativeURL:String,w:int,h:int):Texture2D
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].url == url)
				{
					if(Engine.DEBUG) {
						DebugInfo.debug("|重复创建纹理| " + url,DebugInfo.ERROR);
					}
					return list[i];
				}
			}
			if(Engine.TIP) {
				DebugInfo.debug("|创建纹理| " + url,DebugInfo.TIP);
			}
			var texture:Texture2D = new Texture2D(nativeTexture,url,nativeURL,w,h);
			list.push(texture);
			return texture;
		}
		
		/**
		 * 获取纹理对象引用，引用计数器回+1
		 * @param url 纹理地址
		 * @return 
		 * 
		 */		
		public function getTextureByNativeURL(url:String):Texture2D
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].nativeURL == url)
				{
					return list[i];
				}
			}
			return null;
		}
		
		
		/**
		 * 检查并释放纹理，纹理计数器为0则删除纹理，如果纹理计数器不为0则可能会报错
		 * @param url 纹理地址
		 * 
		 */	
		public function $check():void {
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].$count == 0) {
					Texture2D.safeLock = false;
					list.splice(i,1)[0].$dispose();
					Texture2D.safeLock = true;
					return;
				}
			}
		}
		///////////////////////////////////////////////////////////////////////////////////////static//////////////////////////////////////////////////////////////////////////////////////
		private static var classLock:Boolean = true;
		private static var ist:TextureManager;
		public static function getInstance():TextureManager
		{
			if(!ist)
			{
				classLock = false;
				ist = new TextureManager();
				classLock = true;
			}
			return ist;
		}
	}
}