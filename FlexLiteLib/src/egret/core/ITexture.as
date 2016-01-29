package egret.core
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * 位图纹理接口。表示在目标BitmapData对象上的一个区域。
	 * @author dom
	 */
	public interface ITexture
	{
		/**
		 * 九宫格矩形对象
		 */		
		function get scale9Grid():Rectangle;
		
		function set scale9Grid(value:Rectangle):void;
		/**
		 * 原始位图数据
		 */		
		function get bitmapData():BitmapData;
		
		/**
		 * 表示这个纹理在bitmapData上的x起始位置
		 */
		function get bitmapX():int;
		/**
		 * 表示这个纹理在bitmapData上的y起始位置
		 */
		function get bitmapY():int;
		/**
		 * 表示这个纹理在bitmapData上的宽度
		 */
		function get bitmapWidth():int;
		/**
		 * 表示这个纹理在bitmapData上的高度
		 */
		function get bitmapHeight():int;
		/**
		 * 表示这个纹理显示了之后在x方向的渲染偏移量
		 */
		function get offsetX():int;
		/**
		 * 表示这个纹理显示了之后在y方向的渲染偏移量
		 */
		function get offsetY():int;
		/**
		 * 纹理宽度
		 */
		function get textureWidth():int;
		/**
		 * 纹理高度
		 */
		function get textureHeight():int;
		
	}
}