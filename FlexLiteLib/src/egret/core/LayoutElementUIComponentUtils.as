package egret.core
{
	import flash.geom.Matrix;

	/**
	 * ILayoutElement接口中计算IUIComponent部分数值用的工具类
	 * @author featherJ
	 * 
	 */	
	public class LayoutElementUIComponentUtils
	{
		
		private static const DEFAULT_MAX_WIDTH:Number = 10000;
		private static const DEFAULT_MAX_HEIGHT:Number = 10000;
		
		public function LayoutElementUIComponentUtils()
		{
		}
		
		
		public static function getMinBoundsWidth(obj:IUIComponent, transformMatrix:Matrix):Number
		{
			var width:Number = getMinUBoundsWidth(obj);
//			if (transformMatrix)
//			{
//				width = MatrixUtil.transformSize(width, getMinUBoundsHeight(obj), transformMatrix).x;
//			}
			return width;
		}
		
		public static function getMinBoundsHeight(obj:IUIComponent,transformMatrix:Matrix):Number
		{
			var height:Number = getMinUBoundsHeight(obj);
//			if (transformMatrix)
//			{
//				height = MatrixUtil.transformSize(getMinUBoundsWidth(obj), height, transformMatrix).y;
//			}
			return height;
		}
		
		public static function getMaxBoundsWidth(obj:IUIComponent, transformMatrix:Matrix):Number
		{
			var width:Number = getMaxUBoundsWidth(obj);
//			if (transformMatrix)
//			{
//				width = MatrixUtil.transformSize(width, getMaxUBoundsHeight(obj), transformMatrix).x;
//			}
			return width;
		}
		
		public static function getMaxBoundsHeight(obj:IUIComponent, transformMatrix:Matrix):Number
		{
			var height:Number = getMaxUBoundsHeight(obj);
//			if (transformMatrix)
//			{
//				height = MatrixUtil.transformSize(getMaxUBoundsWidth(obj), height, transformMatrix).y;
//			}
			return height;
		}
		
		private static function getMinUBoundsWidth(obj:IUIComponent):Number
		{
			var minWidth:Number;
			if (!isNaN(obj.explicitMinWidth))
			{
				minWidth = obj.explicitMinWidth;
			}
			else
			{
				minWidth = isNaN(obj.measuredMinWidth) ? 0 : obj.measuredMinWidth;
				if (!isNaN(obj.explicitMaxWidth))
					minWidth = Math.min(minWidth, obj.explicitMaxWidth);
			}
			return minWidth;	
		}
		
		private static function getMinUBoundsHeight(obj:IUIComponent):Number
		{
			var minHeight:Number;
			if (!isNaN(obj.explicitMinHeight))
			{
				minHeight = obj.explicitMinHeight;
			}
			else
			{
				minHeight = isNaN(obj.measuredMinHeight) ? 0 : obj.measuredMinHeight;
				if (!isNaN(obj.explicitMaxHeight))
					minHeight = Math.min(minHeight, obj.explicitMaxHeight);
			}
			return minHeight;	
		}
		
		private static function getMaxUBoundsWidth(obj:IUIComponent):Number
		{
			var maxWidth:Number;
			if (!isNaN(obj.explicitMaxWidth))
				maxWidth = obj.explicitMaxWidth;
			else
				maxWidth = DEFAULT_MAX_WIDTH;
			return maxWidth;	
		}
		
		private static function getMaxUBoundsHeight(obj:IUIComponent):Number
		{
			// explicit trumps explicitMax trumps Number.MAX_VALUE.
			var maxHeight:Number;
			if (!isNaN(obj.explicitMaxHeight))
				maxHeight = obj.explicitMaxHeight;
			else
				maxHeight = DEFAULT_MAX_HEIGHT;
			return maxHeight;
		}
	}
}