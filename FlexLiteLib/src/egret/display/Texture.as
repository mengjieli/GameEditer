package egret.display
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import egret.core.ITexture;
	
	
	/**
	 * 位图纹理。表示在目标BitmapData对象上的一个区域。
	 * @author dom
	 */
	public class Texture implements ITexture
	{
		/**
		 * 构造函数
		 * @param bitmapData 原始位图数据
		 * @param bitmapX 表示这个纹理在bitmapData上的x起始位置
		 * @param bitmapY 表示这个纹理在bitmapData上的y起始位置
		 * @param bitmapWith 表示这个纹理在bitmapData上的宽度
		 * @param bitmapHeight 表示这个纹理在bitmapData上的高度
		 * @param offsetX 表示这个纹理显示了之后在x方向的渲染偏移量
		 * @param offsetY 表示这个纹理显示了之后在y方向的渲染偏移量
		 * @param textureWidth 纹理宽度
		 * @param textureHeight 纹理高度
		 */			
		public function Texture(bitmapData:BitmapData=null,bitmapX:int=0,bitmapY:int=0,
								bitmapWidth:int=-1,bitmapHeight:int=-1,offsetX:int=0,
								offsetY:int=0,textureWidth:int=0,textureHeight:int=0)
		{
			if(bitmapData){
				this._bitmapData = bitmapData;
				this._bitmapX = bitmapX;
				this._bitmapY = bitmapY;
				this._bitmapWidth = bitmapWidth==-1?bitmapData.width:bitmapWidth;
				this._bitmapHeight = bitmapHeight==-1?bitmapData.height:bitmapHeight;
				this._offsetX = offsetX;
				this._offsetY = offsetY;
				if(textureWidth==0)
				{
					textureWidth = offsetX+this._bitmapWidth;
				}
				this._textureWidth = textureWidth;
				if(textureHeight==0)
				{
					textureHeight = offsetY+this._bitmapHeight;
				}
				this._textureHeight = textureHeight;
			}
		}
		
		private var _scale9Grid:Rectangle;
		/**
		 * @inheritDoc
		 */
		public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}
		/**
		 * @inheritDoc
		 */
		public function set scale9Grid(value:Rectangle):void
		{
			_scale9Grid = value;
		}
		
		private var _bitmapData:BitmapData;
		/**
		 * 原始位图数据
		 */	
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		public function set bitmapData(value:BitmapData):void
		{
			if(this._bitmapData==value)
				return;
			this._bitmapData = bitmapData;
			this._bitmapX = 0;
			this._bitmapY = 0;
			this._bitmapWidth = bitmapData.width;
			this._bitmapHeight = bitmapData.height;
			this._offsetX = 0;
			this._offsetY = 0;
			this._textureWidth = bitmapData.width;
			this._textureHeight = bitmapData.height;
		}
		
		private var _bitmapX:int;
		/**
		 * @inheritDoc
		 */
		public function get bitmapX():int
		{
			return _bitmapX;
		}
		
		private var _bitmapY:int;
		/**
		 * @inheritDoc
		 */
		public function get bitmapY():int
		{
			return _bitmapY;
		}
		
		private var _bitmapWidth:int;
		/**
		 * @inheritDoc
		 */
		public function get bitmapWidth():int
		{
			return _bitmapWidth||_textureWidth;
		}
		
		private var _bitmapHeight:int;
		/**
		 * @inheritDoc
		 */
		public function get bitmapHeight():int
		{
			return _bitmapHeight||_textureHeight;
		}
		
		private var _offsetX:int;
		/**
		 * @inheritDoc
		 */
		public function get offsetX():int
		{
			return _offsetX;
		}
		
		private var _offsetY:int;
		/**
		 * @inheritDoc
		 */
		public function get offsetY():int
		{
			return _offsetY;
		}
		
		private var _textureWidth:int;
		/**
		 * @inheritDoc
		 */
		public function get textureWidth():int
		{
			return _textureWidth||_bitmapWidth;
		}
		
		private var _textureHeight:int;
		/**
		 * @inheritDoc
		 */
		public function get textureHeight():int
		{
			return _textureHeight||_bitmapHeight;
		}
	}
}