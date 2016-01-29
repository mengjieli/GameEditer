package egret.utils.maxRects
{
	import flash.geom.Point;
	
	/**
	 * MaxRects工具 
	 * @author featherJ
	 * 
	 */	
	public class MaxRectsUtil
	{
		
		private static var maxRectsCore:MaxRectsCore = new MaxRectsCore();
		private static var _maxWidth:int = -1;
		private static var _maxHeight:int = -1;
		/**
		 * 是否输出信息 
		 */		
		public static var isLog:Boolean = true;
		/**
		 * 得到合图结果 ，只有当resultType为"success"时，才有数据
		 */		
		public static function get result():Vector.<IMaxRectangle>
		{
			return _result.concat();
		}
		/**
		 * 得到合图结果类型，见 MaxRectsResultType
		 * @return 
		 * 
		 */		
		public static function get resultType():String
		{
			return _resultType;
		}
		
		private static var _resultSize:Point = new Point(0,0);
		/**
		 * 最终尺寸 
		 * @return 
		 * 
		 */		
		public static function get resultSize():Point
		{
			return _resultSize;
		}
		/**
		 * 设置最大尺寸 
		 * @param maxWidth 最大宽度
		 * @param maxHeight 最大高度
		 * 
		 */		
		public static function setMaxSize(maxWidth:int = -1,maxHeight:int = -1):void
		{
			_maxWidth = maxWidth;
			_maxHeight = maxHeight;
		}
		
		private static var sortType:String = MaxRectsSortType.AREA;
		/**
		 * 设置排序方式见MaxRectsSortType 
		 * @param type
		 */		
		public static function setSortOn(type:String):void
		{
			sortType = type;
		}
		
		private static var _gap:int = 0;
		/**
		 * 设置间隔 
		 * @param gap
		 * 
		 */		
		public static function setGap(gap:int = 0):void
		{
			_gap = gap;
		}
		
		/**
		 * 设置是否可以旋转 
		 * @param value
		 */		
		public static function setCanRotate(value:Boolean):void
		{
			maxRectsCore.setCanRotate(value);
		}
		
		private static var layoutMath:int=FreeRectangleChoiceHeuristic.BottomLeftRule;
		/**
		 *设置布局方式 
		 * @param v
		 * 
		 */		
		public static function setLayoutMath(v:int):void
		{
			layoutMath=v;
		}
		/**
		 *设置布局过程中新对象的工厂实例，布局过程产生新对象时将从该工厂实例中获取新对象，默认：MaxRectangle 
		 * @param instance
		 * 
		 */		
		public static function setFactoryInstance(instance:IMaxRectangle):void
		{
			maxRectsCore.factory=instance;
		}
		private static var _resultType:String = "";
		private static var _result:Vector.<IMaxRectangle>;
		
		//宽和搞的幂数
		private static var _w:int = 1;
		private static var _h:int = 1;
		private static var _maxW:int = 0;
		private static var _maxH:int = 0;
		
		/**
		 * 插入切片开始合图，需要保证每一个切片的面积都大于0
		 * @param rectangles
		 * 
		 */		
		public static function insertRectangles(rectangles:Vector.<IMaxRectangle>):void
		{
			_result = null;
			//先过滤一遍碎图，看有没有尺寸为0的图
			var newRects:Vector.<IMaxRectangle> = new Vector.<IMaxRectangle>();
			for(var i:int = 0;i<rectangles.length;i++)
			{
				if(rectangles[i].width > 0 && rectangles[i].height>0)
				{
					newRects.push(rectangles[i]);
				}
			}
			if(newRects.length != rectangles.length)
			{
				_resultType = MaxRectsResultType.SHEET_EMPTY;
				log("有图的尺寸不对，宽和高都不能为零");
				return;
			}
			
			//增加间隙
			if(_gap>0)
			{
				for(i = 0;i<newRects.length;i++)
				{
					newRects[i].width += _gap;
					newRects[i].height += _gap;
				}
			}
			
			//得到碎图的最大宽，最大高，和最大面积
			_maxW = 0;
			_maxH = 0;
			var area:int = 0;
			for(i = 0;i<newRects.length;i++)
			{
				if(newRects[i].width>_maxW)
				{
					_maxW = newRects[i].width;
				}
				if(newRects[i].height>_maxH)
				{
					_maxH = newRects[i].height;
				}
				area += newRects[i].width*newRects[i].height;
			}
			log("maxW:"+_maxW+" maxH:"+_maxH+" area:"+area);
			//现将幂按照碎图的最大宽高做一次过滤
			_w = 1;
			_h = 1;
			while(Math.pow(2,_w)<_maxW)_w++;
			while(Math.pow(2,_h)<_maxH)_h++;
			log("第一次过滤 宽幂:"+_w+" 宽:"+Math.pow(2,_w)+" 高幂:"+_h+" 高:"+Math.pow(2,_h));
			_baseW = _w;
			_baseH = _h;
			while(Math.pow(2,_w)*Math.pow(2,_h) < area)
			{
				calculateNext();
			}
			_baseW = _w;
			_baseH = _h;
			log("第二次过滤 宽幂:"+_w+" 宽:"+Math.pow(2,_w)+" 高幂:"+_h+" 高:"+Math.pow(2,_h));
			
			if(sortType == MaxRectsSortType.AREA)
			{
				//按面积排序一遍
				for(i = 0;i<newRects.length;i++)
				{
					for(var j:int = i;j<newRects.length;j++)
					{
						if(newRects[i].height*newRects[i].width < newRects[j].height*newRects[j].width)
						{
							var temp:IMaxRectangle = newRects[i];
							newRects[i] = newRects[j];
							newRects[j] = temp;
						}
					}
				}
			}else if(sortType == MaxRectsSortType.SIZE)
			{
				if(_maxW>_maxH)
				{
					//按宽排序一遍
					for(i = 0;i<newRects.length;i++)
					{
						for(j = i;j<newRects.length;j++)
						{
							if(newRects[i].width < newRects[j].width)
							{
								temp = newRects[i];
								newRects[i] = newRects[j];
								newRects[j] = temp;
							}
						}
					}
				}else
				{
					//按高排序一遍
					for(i = 0;i<newRects.length;i++)
					{
						for(j = i;j<newRects.length;j++)
						{
							if(newRects[i].height < newRects[j].height)
							{
								temp = newRects[i];
								newRects[i] = newRects[j];
								newRects[j] = temp;
							}
						}
					}
				}
			}
		
			
			var finish:Boolean = false;
			var n:int = 0;
			
			var tooBig:Boolean = false;
			while(!finish)
			{
				var currentW:int = Math.pow(2,_w);
				var currentH:int = Math.pow(2,_h);
				var tempRectangles:Vector.<IMaxRectangle> = newRects.concat();
				log(n+"次计算，"+"宽:"+currentW+" 高:"+currentH+"     "+"宽幂:"+_w+" 高幂:"+_h);
				maxRectsCore.init(currentW,currentH);
				maxRectsCore.insertGroup(tempRectangles,layoutMath);
				var results:Vector.<IMaxRectangle> = maxRectsCore.usedRectangles;
				finish = true;
				var hasError:Boolean = false;
				for(i = 0;i<results.length;i++)
				{
					if(results[i].x == 0 && results[i].y == 0 && results[i].width == 0 && results[i].height == 0)
					{
						hasError = true;
						break;
					}
				}
				if(hasError)
				{
					calculateNext();
					finish = false;
				}
				n++;
				if((currentW > _maxWidth && _maxWidth >0) || 
					(currentH > _maxHeight && _maxHeight>0))
				{
					finish = true;
					tooBig = true;
				}
			}
			if(tooBig)
			{
				_resultType = MaxRectsResultType.SHEET_TO_BIG;
				log("图太多了，最大尺寸都不够")
				return;
			}
			log("成功了"+"最终宽度:"+currentW+" 最终高度:"+currentH)
			_resultSize.x = currentW;
			_resultSize.y = currentH;
			_resultType = MaxRectsResultType.SUCCESS;
			_result = maxRectsCore.usedRectangles;
			if(_gap>0)
			{
				for(i = 0;i<_result.length;i++)
				{
					_result[i].width -= _gap;
					_result[i].height -= _gap;
					_result[i].x += int(_gap/2);
					_result[i].y += int(_gap/2);
				}
			}
		}
		
		
		private static var _baseW:int = 1;
		private static var _baseH:int = 1;
		
		private static function calculateNext():void
		{
			if(_maxW>_maxH)
			{
				if(_w == _h)
				{
					_h++;
					_w = _baseW
					return;
				}
				if(_h > _w+1)
				{
					_w++;
					return;
				}
				if(_h == _w+1)
				{
					_w = _h;
					_h = _baseH;
					return;
				}
				if(_w>_h+1)
				{
					_h++;
					return;
				}
				if(_w == _h+1)
				{
					_h = _w;
					return;
				}
			}else
			{
				if(_h == _w)
				{
					_w++;
					_h = _baseH
					return;
				}
				if(_w > _h+1)
				{
					_h++;
					return;
				}
				if(_w == _h+1)
				{
					_h = _w;
					_w = _baseW;
					return;
				}
				if(_h>_w+1)
				{
					_w++;
					return;
				}
				if(_h == _w+1)
				{
					_w = _h;
					return;
				}
			}
		}
		
		private static function log(str:String):void
		{
			if(isLog)
				trace(str);
		}
	}
}