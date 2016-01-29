package egret.effects.effectClasses
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class TransformUtil
	{
		/**
		 * 将显示对象按照给定的转换中心调整位置
		 * @param obj 要转换的显示对象
		 * @param transformCenter 转换中心点，以显示对象为坐标系
		 * @param translation 新的转换中心的位置，以显示对象的父容器为坐标系
		 * @param scaleX 新的缩放值scaleX，如果为NaN则不设置
		 * @param scaleY 新的缩放值scaleY，如果为NaN则不设置
		 * @param rotation 新的旋转角度，如果为NaN则不设置
		 */
		public static function transformAround(obj:DisplayObject,
											   transformCenter:Point,
											   translation:Point = null,
											   scaleX:Number = NaN,
											   scaleY:Number = NaN,
											   rotation:Number = NaN):void
		{
			if (translation == null && transformCenter != null)
			{
				if (xformPt == null)
					xformPt = new Point();
				xformPt.x = transformCenter.x;
				xformPt.y = transformCenter.y;
				var xformedPt:Point = transformPointToParent(obj , xformPt);
			}
			if (!isNaN(rotation))
				obj.rotation = rotation;
			if (!isNaN(scaleX))
				obj.scaleX = scaleX;
			if (!isNaN(scaleY))
				obj.scaleY = scaleY;
			
			if (transformCenter == null)
			{
				if (translation != null)
				{
					obj.x = translation.x;
					obj.y = translation.y;
				}
			}
			else
			{
				if (xformPt == null)
					xformPt = new Point();
				xformPt.x = transformCenter.x;
				xformPt.y = transformCenter.y;
				var postXFormPoint:Point = transformPointToParent(obj , xformPt);
				if (translation != null)
				{
					obj.x += translation.x - postXFormPoint.x;
					obj.y += translation.y - postXFormPoint.y;
				}
				else
				{
					obj.x += xformedPt.x - postXFormPoint.x;
					obj.y += xformedPt.y - postXFormPoint.y;
				}
			}
		}
		
		private static var xformPt:Point;
		public static function transformPointToParent(obj:DisplayObject,localPosition:Point = null):Point
		{
			if (xformPt == null)
				xformPt = new Point();
			if (localPosition)
			{
				xformPt.x = localPosition.x;
				xformPt.y = localPosition.y;
			}
			else
			{
				xformPt.x = 0;
				xformPt.y = 0;
			}
			if(obj.transform.matrix != null)
				return obj.transform.matrix.transformPoint(xformPt);
			else
			{
				return new Point(xformPt.x,xformPt.y);
			}
		}
	}
}