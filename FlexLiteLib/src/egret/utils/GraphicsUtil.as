package egret.utils
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import egret.core.ITexture;

	[ExcludeClass]
	/**
	 * 绘图工具类
	 * @author dom
	 */
	public class GraphicsUtil
	{
		
		/**
		 * 绘制虚线 
		 * @param graphics 要绘制的图形
		 * @param x1 起始坐标x
		 * @param y1 起始坐标y
		 * @param x2 结束坐标x
		 * @param y2 结束坐标y
		 * @param dash 虚线线段长度
		 * @param ed 虚线间断长度
		 * 
		 */		
		public static function drawDash (graphics:Graphics,x1:Number,y1:Number,x2:Number,y2:Number,dash:Number = 8,ed:Number = 2):void
		{
			//计算起点终点连续的角度
			var angle:Number = Math.atan2(y2 - y1,x2 - x1);
			//步长，每次循环改变的长度
			var step:Number = dash + ed;
			//每段实线水平和竖直长度
			var dashx:Number = dash * Math.cos(angle);
			var dashy:Number = dash * Math.sin(angle);
			//每段虚线水平和竖直长度
			var edx:Number = ed * Math.cos(angle);
			var edy:Number = ed * Math.sin(angle);
			//每段实线和虚线的水平和垂直长度
			var stepx:Number = step * Math.cos(angle);
			var stepy:Number = step * Math.sin(angle);
			//起点和终点的距离
			var _length:Number = Math.sqrt(Math.pow(x2 - x1,2) + Math.pow(y2 - y1,2));
			//使用循环，逐段绘制
			for (var i:int = step,px:Number=x1,py:Number=y1; i<_length; i+=step) {
				graphics.moveTo (px+edx,py+edy);
				graphics.lineTo (px+dashx,py+dashy);
				//循环递归
				px+=stepx;
				py+=stepy;
			}
		}
		
		/**
		 * 绘制四个角不同的圆角矩形
		 * @param graphics 要绘制到的对象。
		 * @param x 起始点x坐标
		 * @param y 起始点y坐标
		 * @param width 矩形宽度
		 * @param height 矩形高度
		 * @param topLeftRadius 左上圆角半径
		 * @param topRightRadius 右上圆角半径
		 * @param bottomLeftRadius 左下圆角半径
		 * @param bottomRightRadius 右下圆角半径
		 */				
		public static function drawRoundRectComplex(graphics:Graphics, x:Number, y:Number, 
													 width:Number, height:Number, 
													 topLeftRadius:Number, topRightRadius:Number, 
													 bottomLeftRadius:Number, bottomRightRadius:Number):void
		{
			var xw:Number = x + width;
			var yh:Number = y + height;
			
			var minSize:Number = width < height ? width * 2 : height * 2;
			topLeftRadius = topLeftRadius < minSize ? topLeftRadius : minSize;
			topRightRadius = topRightRadius < minSize ? topRightRadius : minSize;
			bottomLeftRadius = bottomLeftRadius < minSize ? bottomLeftRadius : minSize;
			bottomRightRadius = bottomRightRadius < minSize ? bottomRightRadius : minSize;
			
			var a:Number = bottomRightRadius * 0.292893218813453;
			var s:Number = bottomRightRadius * 0.585786437626905;
			graphics.moveTo(xw, yh - bottomRightRadius);
			graphics.curveTo(xw, yh - s, xw - a, yh - a);
			graphics.curveTo(xw - s, yh, xw - bottomRightRadius, yh);
			
			a = bottomLeftRadius * 0.292893218813453;
			s = bottomLeftRadius * 0.585786437626905;
			graphics.lineTo(x + bottomLeftRadius, yh);
			graphics.curveTo(x + s, yh, x + a, yh - a);
			graphics.curveTo(x, yh - s, x, yh - bottomLeftRadius);
			
			a = topLeftRadius * 0.292893218813453;
			s = topLeftRadius * 0.585786437626905;
			graphics.lineTo(x, y + topLeftRadius);
			graphics.curveTo(x, y + s, x + a, y + a);
			graphics.curveTo(x + s, y, x + topLeftRadius, y);
			
			a = topRightRadius * 0.292893218813453;
			s = topRightRadius * 0.585786437626905;
			graphics.lineTo(xw - topRightRadius, y);
			graphics.curveTo(xw - s, y, xw - a, y + a);
			graphics.curveTo(xw, y + s, xw, y + topRightRadius);
			graphics.lineTo(xw, yh - bottomRightRadius);
		}
		
		private static var matrix:Matrix = new Matrix();
		
		private static var destGrid:Array = [];
		private static var cacheScale9Grid:Rectangle = new Rectangle();
		private static var cacheSourceSection:Rectangle = new Rectangle();
		private static var cacheDestSection:Rectangle = new Rectangle();
		/**
		 * 绘制具有九宫格缩放规则的位图数据
		 */		
		public static function drawScale9GridBitmap(graphics:Graphics,cachedSourceGrid:Array,scale9Grid:Rectangle,
													data:Object,destWidth:int,destHeight:int,smoothing:Boolean=false,contentScale:Number=1):void
		{
			var texture:ITexture = data as ITexture;
			var bitmapData:BitmapData;
			var bitmapHeight:int;
			var bitmapWidth:int;
			var bitmapX:int;
			var bitmapY:int;
			var offsetX:int;
			var offsetY:int;
			var textureHeight:int;
			var textureWidth:int;
			if(texture)
			{
				bitmapData = texture.bitmapData;
				bitmapHeight = texture.bitmapHeight;
				bitmapWidth = texture.bitmapWidth;
				bitmapX = texture.bitmapX;
				bitmapY = texture.bitmapY;
				offsetX = texture.offsetX;
				offsetY = texture.offsetY;
				textureHeight = texture.textureHeight;
				textureWidth = texture.textureWidth;
			}
			else
			{
				bitmapData = data as BitmapData;
				bitmapHeight = bitmapData.height*contentScale;
				bitmapWidth = bitmapData.width*contentScale;
				textureHeight = bitmapData.height*contentScale;
				textureWidth = bitmapData.width*contentScale;
			}
			var s9g:Rectangle = cacheScale9Grid;
			s9g.setTo(scale9Grid.x-offsetX,scale9Grid.y-offsetY,
				scale9Grid.width,scale9Grid.height);
			destWidth -= textureWidth-bitmapWidth;
			destHeight -= textureHeight-bitmapHeight;
			//防止空心的情况出现。
			if(s9g.top==s9g.bottom)
			{
				if(s9g.bottom<bitmapHeight)
					s9g.bottom ++;
				else
					s9g.top --;
			}
			if(s9g.left==s9g.right)
			{
				if(s9g.right<bitmapWidth)
					s9g.right ++;
				else
					s9g.left --;
			}
			if (cachedSourceGrid.length==0)
			{
				cachedSourceGrid.push([new Point(0, 0), new Point(s9g.left, 0),
					new Point(s9g.right, 0), new Point(bitmapWidth, 0)]);
				cachedSourceGrid.push([new Point(0, s9g.top), new Point(s9g.left, s9g.top),
					new Point(s9g.right, s9g.top), new Point(bitmapWidth, s9g.top)]);
				cachedSourceGrid.push([new Point(0, s9g.bottom), new Point(s9g.left, s9g.bottom),
					new Point(s9g.right, s9g.bottom), new Point(bitmapWidth, s9g.bottom)]);
				cachedSourceGrid.push([new Point(0, bitmapHeight), new Point(s9g.left, bitmapHeight),
					new Point(s9g.right, bitmapHeight), new Point(bitmapWidth, bitmapHeight)]);
			}
			var destScaleGridBottom:Number = destHeight - (bitmapHeight - s9g.bottom);
			var destScaleGridRight:Number = destWidth - (bitmapWidth - s9g.right);
			if(bitmapWidth - s9g.width>destWidth)
			{
				var a:Number = (bitmapWidth-s9g.right)/s9g.left;
				var center:Number = destWidth/(1+a);
				destScaleGridRight = s9g.left = s9g.right = Math.round(isNaN(center)?0:center);
			}
			if(bitmapHeight - s9g.height>destHeight)
			{
				var b:Number = (bitmapHeight-s9g.bottom)/s9g.top;
				var middle:Number = destHeight/(1+b);
				destScaleGridBottom = s9g.top = s9g.bottom = Math.round(isNaN(middle)?0:middle);
			}
			var cachedDestGrid:Array = destGrid;
			if(cachedDestGrid.length==0)
			{
				createCachedDestGrid();
			}
			cachedDestGrid[0][1].setTo(s9g.left, 0);
			cachedDestGrid[0][2].setTo(destScaleGridRight, 0);
			cachedDestGrid[0][3].setTo(destWidth, 0);			
			cachedDestGrid[1][0].setTo(0, s9g.top);
			cachedDestGrid[1][1].setTo(s9g.left, s9g.top);
			cachedDestGrid[1][2].setTo(destScaleGridRight, s9g.top);
			cachedDestGrid[1][3].setTo(destWidth, s9g.top);
			cachedDestGrid[2][0].setTo(0, destScaleGridBottom);
			cachedDestGrid[2][1].setTo(s9g.left, destScaleGridBottom);
			cachedDestGrid[2][2].setTo(destScaleGridRight, destScaleGridBottom);
			cachedDestGrid[2][3].setTo(destWidth, destScaleGridBottom);
			cachedDestGrid[3][0].setTo(0, destHeight);
			cachedDestGrid[3][1].setTo(s9g.left, destHeight);
			cachedDestGrid[3][2].setTo(destScaleGridRight, destHeight);
			cachedDestGrid[3][3].setTo(destWidth, destHeight);
			
			
			var sourceSection:Rectangle = cacheSourceSection;
			var destSection:Rectangle = cacheDestSection;
			
			for (var rowIndex:int=0; rowIndex < 3; rowIndex++)
			{
				for (var colIndex:int = 0; colIndex < 3; colIndex++)
				{
					sourceSection.topLeft = cachedSourceGrid[rowIndex][colIndex];
					sourceSection.bottomRight = cachedSourceGrid[rowIndex+1][colIndex+1];
					sourceSection.x += bitmapX;
					sourceSection.y += bitmapY;
					
					destSection.topLeft = cachedDestGrid[rowIndex][colIndex];
					destSection.bottomRight = cachedDestGrid[rowIndex+1][colIndex+1];
					if(destSection.width==0||destSection.height==0||
						sourceSection.width==0||sourceSection.height==0)
						continue;
					matrix.identity();
					matrix.scale(destSection.width / sourceSection.width*contentScale,destSection.height / sourceSection.height*contentScale);
					matrix.translate(destSection.x - (sourceSection.x) * matrix.a, destSection.y - (sourceSection.y) * matrix.d);
					matrix.translate(offsetX, offsetY);
					
					graphics.beginBitmapFill(bitmapData, matrix,false,smoothing);
					graphics.drawRect(destSection.x + offsetX, destSection.y + offsetY, destSection.width, destSection.height);
					graphics.endFill();
				}
			}
		}
		/**
		 * 创建缓存的point节点列表
		 */		
		private static function createCachedDestGrid():void
		{
			var cachedDestGrid:Array = destGrid;
			for(var i:int=0;i<4;i++)
			{
				var list:Array = [];
				for(var j:int=0;j<4;j++)
				{
					list.push(new Point());
				}
				cachedDestGrid.push(list);
			}
		}
	}
}