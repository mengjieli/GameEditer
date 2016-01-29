package egret.display
{
	import flash.display.BitmapData;
	
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	/**
	 * SpriteSheet是一张由多个子位图拼接而成的集合位图，它包含多个Texture对象。
     * 每一个Texture都共享SpriteSheet的集合位图，但是指向它的不同的区域。
	 * @author dom
	 */
	public class SpriteSheet
	{
		/**
		 * 构造函数
		 * @param bitmapData 共享的位图数据
		 */		
		public function SpriteSheet(texture:*)
		{
			if(texture is BitmapData)
			{
				this.bitmapData = texture as BitmapData;
			}
			else
			{
				this.bitmapData = texture.bitmapData;
				this.bitmapX = texture.bitmapX-texture.offsetX;
				this.bitmapY = texture.bitmapY-texture.offsetY;
			}
		}
		/**
		 * 表示这个SpriteSheet的位图区域在bitmapData上的起始位置x。
		 */
		private var bitmapX:int;
		/**
		 * 表示这个SpriteSheet的位图区域在bitmapData上的起始位置y。
		 */
		private var bitmapY:int;
		/**
		 * 共享的位图数据
		 */
		private var bitmapData:BitmapData;
		/**
		 * 纹理缓存字典
		 */
		ns_egret var textureMap:Object = {};
		
		/**
		 * 根据指定纹理名称获取一个缓存的Texture对象
		 * @param name 缓存这个Texture对象所使用的名称，如果名称已存在，将会覆盖之前的Texture对象
		 * @returns Texture对象
		 */
		public function getTexture(name:String):Texture 
		{
			return textureMap[name];
		}
		
		/**
		 * 为SpriteSheet上的指定区域创建一个新的Texture对象并缓存它
		 * @param name 缓存这个Texture对象所使用的名称，如果名称已存在，将会覆盖之前的Texture对象
		 * @param bitmapX 纹理区域在bitmapData上的起始坐标x
		 * @param bitmapY 纹理区域在bitmapData上的起始坐标y
		 * @param bitmapWidth 纹理区域在bitmapData上的宽度
		 * @param bitmapHeight 纹理区域在bitmapData上的高度
		 * @param offsetX 原始位图的非透明区域x起始点
		 * @param offsetY 原始位图的非透明区域y起始点
		 * @param textureWidth 原始位图的高度，若不传入，则使用bitmapWidth的值。
		 * @param textureHeight 原始位图的宽度，若不传入，这使用bitmapHeight值。
		 * @returns 创建的Texture对象
		 */
		public function createTexture(name:String, bitmapX:int, bitmapY:int, bitmapWidth:int, 
									  bitmapHeight:int,	offsetX:int=0,offsetY:int=0,
									  textureWidth:int=0,textureHeight:int=0):Texture 
		{
				var texture:Texture = new Texture(this.bitmapData,this.bitmapX+bitmapX,this.bitmapY+bitmapY,bitmapWidth,
					bitmapHeight,offsetX,offsetY,textureWidth,textureHeight);
				textureMap[name] = texture;
				return texture;
			}
	}
}