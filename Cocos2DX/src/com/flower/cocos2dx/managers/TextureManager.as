package com.flower.cocos2dx.managers
{
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.managers.texture.Texture2D;

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
		public function loadTexture(url:String,w:int,h:int):Texture2D
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].url == url)
				{
					//DebugInfo.debug("|加载纹理| 已加载的纹理 : " + url,DebugInfo.WARN);
					return null;
				}
			}
			DebugInfo.debug("|加载纹理| " + url,DebugInfo.TIP);
			var texture:Texture2D = new Texture2D(url,w,h);
			list.push(texture);
			return texture;
		}
		
		/**
		 *释放纹理，纹理计数器为0则删除纹理，如果纹理计数器不为0则可能会报错
		 * @param url 纹理地址
		 * 
		 */		
		public function delTexture(texture:Texture2D):void
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i] == texture)
				{
					Texture2D.safeLock = false;
					list.slice(i,1)[0].dispose();
					DebugInfo.debug("|删除纹理| " + texture.getUrl(),DebugInfo.TIP);
					Texture2D.safeLock = true;
					return;
				}
			}
			DebugInfo.debug("|释放纹理| 未找到的纹理 : " + texture.getUrl(),DebugInfo.WARN);
		}
		
		/**
		 *获取纹理对象引用，引用计数器回+1
		 * @param url 纹理地址
		 * @return 
		 * 
		 */		
		public function getNewTexture(url:String):Texture2D
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i].url == url)
				{
					list[i].addCount();
					return list[i];
				}
			}
			DebugInfo.debug("|获取纹理| 未找到的纹理 : " + url,DebugInfo.WARN);
			return null;
		}
		
		/**
		 *释放纹理计数器，不是直接删除纹理，只会计数器-1，如果计数器为0则会删除该纹理 
		 * @param url 纹理地址
		 * @return 
		 * 
		 */		
		public function disposeTexure(texture:Texture2D):void
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i] == texture)
				{
					list[i].delCount();
					return;
				}
			}
			DebugInfo.debug("|释放纹理| 未找到的纹理 " + texture.getUrl(),DebugInfo.WARN);
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