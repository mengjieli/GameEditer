package flower.texture
{
	import flower.Engine;
	import flower.debug.DebugInfo;

	/**
	 *2D纹理，拥有cocos2dx 纹理对象Texture2D的引用，并管理纹理计数器 
	 * @author MengJie.Li
	 * 
	 */	
	public class Texture2D
	{
		/**宽，用以计算内存，和自动释放一些无用纹理*/
		private var _width:int;
		/**高*/
		private var _height:int;
		/**纹理地址*/
		private var _url:String;
		/**实际的加载地址*/
		private var _nativeURL:String;
		/**引用计数*/
		public var $count:int;
		/**cocos2dx底层纹理引用*/
		private var _nativeTexture:*;
		/**是否已经释放了**/
		private var _hasDispose:Boolean = false;
		
		public function Texture2D(nativeTexture:*,url:String,nativeURL:String,w:int,h:int):void
		{
			this._nativeTexture = nativeTexture;
			this._url = url;
			this._nativeURL = nativeURL;
			this.$count = 0;
			this._width = w;
			this._height = h;
		}
		
		/**
		 *释放纹理 ，外部不要使用，使用TextureManager.disposeTexure()代替
		 * 
		 */		
		public function $dispose():void
		{
			if(safeLock == true)
			{
				DebugInfo.debug("|释放纹理| 操作失败，此方法提供内部结构使用，外部禁止使用，请用TextureManager.disposeTexure()代替，url:" + url,DebugInfo.ERROR);
				return;
			}
			if($count != 0)
			{
				DebugInfo.debug("|释放纹理| 纹理计数器不为0，此纹理不会被释放，计数为 " + $count + "，地址为" + url,DebugInfo.ERROR);
				return;
			}
			System.disposeTexture(this._nativeTexture,_nativeURL);
			_nativeTexture = null;
			if(Engine.TIP) {
				DebugInfo.debug("|释放纹理| " + url,DebugInfo.TIP);
			}
			_hasDispose = true;
		}
		
		/**
		 *计数器+1，提供给安全的对象使用，手动操作可能会出错
		 * 安全的对象是指类似cocos2dx.display.Bitmap这样的对象，使用时计数器+1，不用时计数器-1，这样不会导致纹理不会被释放
		 * 如果要使用这个函数请注意释放
		 * 
		 */		
		public function $addCount():void
		{
			this.$count++;
		}
		
		/**
		 * 计数器-1 ，提供给安全的对象使用，手动操作可能会出错
		 * 安全的对象是指类似cocos2dx.display.Bitmap这样的对象，使用时计数器+1，不用时计数器-1，这样不会导致纹理不会被释放
		 * 如果要使用这个函数请注意释放
		 * 
		 */		
		public function $delCount():void
		{
			this.$count--;
			if(this.$count < 0) {
				this.$count = 0;
			}
			if(this.$count == 0)
			{
				if(Engine.DEBUG && this == Texture2D.blank) {
					DebugInfo.debug2(DebugInfo.ERROR,"空白图像被释放了");
					return;
				}
			}
		}
		
		/**
		 *获取计数器 
		 * 
		 */		
		public function getCount():int
		{
			return this.$count;
		}
		
		/**
		 *获取纹理地址(不等于实际加载地址)
		 * @return 
		 * 
		 */		
		public function get url():String
		{
			return this._url;
		}
		
		/**
		 * 获取纹理的实际加载地址
		 */
		public function get nativeURL():String {
			return this._nativeURL;
		}
		
		/**
		 * 纹理实际像素宽
		 */
		public function get width():int {
			return this._width;
		}
		
		/**
		 * 纹理实际像素高
		 */
		public function get height():int {
			return this._height;
		}
		
		/**
		 * 是否已经释放纹理，如果保存了 texture2D 变量，使用前最好查看下这个值是否为 true
		 * true 表示已经释放
		 * false 表示未释放
		 */
		public function get hasDispose():Boolean {
			return this._hasDispose;
		}
		
		/**
		 *获取本地纹理对象
		 * 仅供引擎内部使用
		 * @return CCTexture2D
		 * 
		 */		
		public function get $nativeTexture():*
		{
			return this._nativeTexture;
		}
		
		/**安全锁，提供内部机制使用，外部禁止使用*/
		public static var safeLock:Boolean = true;
		
		/**
		 * 1x1的图像，因为 Coco里面无法设置 Sprite 的图像为空
		 */
		public static var blank:Texture2D;
	}
}

