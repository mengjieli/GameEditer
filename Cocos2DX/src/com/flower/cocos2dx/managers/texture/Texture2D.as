package com.flower.cocos2dx.managers.texture
{
	import com.flower.Flower;
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.managers.TextureManager;
	
	import cocos2dx.manager.CCTextureCache;
	import cocos2dx.teture.CCTexture2D;

	/**
	 *2D纹理，拥有cocos2dx 纹理对象Texture2D的引用，并管理纹理计数器 
	 * @author MengJie.Li
	 * 
	 */	
	public class Texture2D
	{
		/**宽，用以计算内存，和自动释放一些无用纹理*/
		public var width:int;
		/**高*/
		public var height:int;
		/**纹理的地址*/
		public var url:String;
		/**引用计数*/
		private var count:int;
		/**cocos2dx底层纹理引用*/
		private var _txt:CCTexture2D;
		
		public function Texture2D(val:String,w:int,h:int):void
		{
			this.url = val;
			this.count = 0;
			this.width = w;
			this.height = h;
			CCTextureCache.getInstance().addImage(this.url);
			_txt = CCTextureCache.getInstance().textureForKey(this.url);
		}
		
		/**
		 *释放纹理 ，外部不要使用，使用TextureManager.disposeTexure()代替
		 * 
		 */		
		public function dispose():void
		{
			if(safeLock == true)
			{
				DebugInfo.debug("|释放纹理| 操作失败，此方法提供内部结构使用，外部禁止使用，请用TextureManager.disposeTexure()代替，url:" + url,DebugInfo.ERROR);
				return;
			}
			if(count != 0)
			{
				if(Flower.resrict)
				{
					DebugInfo.debug("|释放纹理| 纹理计数器不为0，此纹理不会被释放，计数为 " + count + "，地址为" + url,DebugInfo.ERROR);
					return;
				}
				else
				{
					DebugInfo.debug("|释放纹理| 纹理计数器不为0，计数为 " + count + "，地址为" + url,DebugInfo.WARN);
				}
			}
			_txt = null;
			CCTextureCache.getInstance().removeTextureForKey(url);
		}
		
		/**
		 *计数器+1，提供给安全的对象使用，手动操作可能会出错
		 * 安全的对象是指类似cocos2dx.display.Bitmap这样的对象，使用时计数器+1，不用时计数器-1，这样不会导致纹理不会被释放
		 * 如果要使用这个函数请注意释放
		 * 
		 */		
		public function addCount():void
		{
			this.count++;
		}
		
		/**
		 *计数器-1 ，提供给安全的对象使用，手动操作可能会出错
		 * 安全的对象是指类似cocos2dx.display.Bitmap这样的对象，使用时计数器+1，不用时计数器-1，这样不会导致纹理不会被释放
		 * 如果要使用这个函数请注意释放
		 * 
		 */		
		public function delCount():void
		{
			this.count--;
			if(this.count == 0)
			{
				TextureManager.getInstance().delTexture(this);
			}
		}
		
		/**
		 *获取计数器 
		 * 
		 */		
		public function getCount():int
		{
			return this.count;
		}
		
		/**
		 *获取纹理地址 
		 * @return 
		 * 
		 */		
		public function getUrl():String
		{
			return this.url;
		}
		
		/**
		 *获取Cocos2DX纹理对象CCTexture2D 
		 * @return CCTexture2D
		 * 
		 */		
		public function getTexture():CCTexture2D
		{
			return _txt;
		}
		
		/**安全锁，提供内部机制使用，外部禁止使用*/
		public static var safeLock:Boolean = true;
	}
}