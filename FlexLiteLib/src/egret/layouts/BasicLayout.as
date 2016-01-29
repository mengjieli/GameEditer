package egret.layouts
{
	import flash.geom.Rectangle;
	
	import egret.core.ILayoutElement;
	import egret.core.UIGlobals;
	import egret.layouts.supportClasses.LayoutBase;
	
	[EXML(show="false")]
	
	/**
	 * 基本布局
	 * @author dom
	 */
	public class BasicLayout extends LayoutBase
	{
		public function BasicLayout()
		{
			super();
		}
		
		/**
		 * 是否约束了宽度
		 * @param layoutElement
		 * @return 
		 * 
		 */		
		private static function constraintsDetermineWidth(layoutElement:ILayoutElement):Boolean
		{
			return !isNaN(layoutElement.percentWidth) || (!isNaN(layoutElement.left) && !isNaN(layoutElement.right));
		}
		/**
		 * 是否约束了高度 
		 * @param layoutElement
		 * @return 
		 * 
		 */		
		private static function constraintsDetermineHeight(layoutElement:ILayoutElement):Boolean
		{
			return !isNaN(layoutElement.percentHeight) || (!isNaN(layoutElement.top) && !isNaN(layoutElement.bottom));
		}
		
		
		static private function maxSizeToFitIn(totalSize:Number,
											   center:Number,
											   lowConstraint:Number,
											   highConstraint:Number,
											   position:Number):Number
		{
			if (!isNaN(center))
			{
				// (1) x == (totalSize - childWidth) / 2 + hCenter
				// (2) x + childWidth <= totalSize
				// (3) x >= 0
				//
				// Substitue x in (2):
				// (totalSize - childWidth) / 2 + hCenter + childWidth <= totalSize
				// totalSize - childWidth + 2 * hCenter + 2 * childWidth <= 2 * totalSize
				// 2 * hCenter + childWidth <= totalSize se we get:
				// (3) childWidth <= totalSize - 2 * hCenter
				//
				// Substitute x in (3):
				// (4) childWidth <= totalSize + 2 * hCenter
				//
				// From (3) & (4) above we get:
				// childWidth <= totalSize - 2 * abs(hCenter)
				
				return totalSize - 2 * Math.abs(center);
			}
			else if (!isNaN(lowConstraint))
			{
				// childWidth + left <= totalSize
				return totalSize - lowConstraint;
			}
			else if (!isNaN(highConstraint))
			{
				// childWidth + right <= totalSize
				return totalSize - highConstraint;
			}
			else
			{
				// childWidth + childX <= totalSize
				return totalSize - position;
			}
		}
		
		/**
		 * 此布局不支持虚拟布局，设置这个属性无效
		 */		
		override public function set useVirtualLayout(value:Boolean):void
		{
		}
		
		private var _mouseWheelSpeed:uint = 20;
		/**
		 * 鼠标滚轮每次滚动时目标容器的verticalScrollPosition
		 * 或horizontalScrollPosition改变的像素距离。必须大于0， 默认值20。
		 */
		public function get mouseWheelSpeed():uint
		{
			return _mouseWheelSpeed;
		}
		public function set mouseWheelSpeed(value:uint):void
		{
			if(value==0)
				value = 1;
			_mouseWheelSpeed = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.left = scrollRect.left - _mouseWheelSpeed;
			bounds.right = scrollRect.left; 
			return bounds;
		} 
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.left = scrollRect.right;
			bounds.right = scrollRect.right + _mouseWheelSpeed;
			return bounds;
		} 
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.top = scrollRect.top - _mouseWheelSpeed;
			bounds.bottom = scrollRect.top;
			return bounds;
		} 
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.top = scrollRect.bottom;
			bounds.bottom = scrollRect.bottom + _mouseWheelSpeed;
			return bounds;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function measure():void
		{
			super.measure();
			
			if (target==null)
				return;
			
			var width:Number = 0;
			var height:Number = 0;
			if(!UIGlobals.getForEgret(this))
			{
				var minWidth:Number = 0;
				var minHeight:Number = 0;
			}
			
			var count:int = target.numElements;
			for (var i:int = 0; i < count; i++)
			{
				var layoutElement:ILayoutElement = target.getElementAt(i) as ILayoutElement;
				if (!layoutElement||!layoutElement.includeInLayout)
					continue;
				
				var hCenter:Number   = layoutElement.horizontalCenter;
				var vCenter:Number   = layoutElement.verticalCenter;
				var left:Number      = layoutElement.left;
				var right:Number     = layoutElement.right;
				var top:Number       = layoutElement.top;
				var bottom:Number    = layoutElement.bottom;
				
				var extX:Number;
				var extY:Number;
				
				if (!isNaN(left) && !isNaN(right))
				{
					extX = left + right;                
				}
				else if (!isNaN(hCenter))
				{
					extX = Math.abs(hCenter) * 2;
				}
				else if (!isNaN(left) || !isNaN(right))
				{
					extX = isNaN(left) ? 0 : left;
					extX += isNaN(right) ? 0 : right;
				}
				else
				{
					extX = layoutElement.preferredX;
				}
				
				if (!isNaN(top) && !isNaN(bottom))
				{
					extY = top + bottom;                
				}
				else if (!isNaN(vCenter))
				{
					extY = Math.abs(vCenter) * 2;
				}
				else if (!isNaN(top) || !isNaN(bottom))
				{
					extY = isNaN(top) ? 0 : top;
					extY += isNaN(bottom) ? 0 : bottom;
				}
				else
				{
					extY = layoutElement.preferredY;
				}
				
				
				var preferredWidth:Number = layoutElement.preferredWidth;
				var preferredHeight:Number = layoutElement.preferredHeight;
				
				if(UIGlobals.getForEgret(this))
				{
					width = Math.ceil(Math.max(width, extX + preferredWidth));
					height = Math.ceil(Math.max(height, extY + preferredHeight));
				}else
				{
					width = Math.max(width, extX + preferredWidth);
					height = Math.max(height, extY + preferredHeight);
					
					var elementMinWidth:Number =
						constraintsDetermineWidth(layoutElement) ? layoutElement.getMinBoundsWidth() :
						preferredWidth;
					var elementMinHeight:Number =
						constraintsDetermineHeight(layoutElement) ? layoutElement.getMinBoundsHeight() : 
						preferredHeight;
					
					minWidth = Math.max(minWidth, extX + elementMinWidth);
					minHeight = Math.max(minHeight, extY + elementMinHeight);
				}
			}
			if(UIGlobals.getForEgret(this))
			{
				target.measuredWidth = width;
				target.measuredHeight = height;
			}else
			{
				target.measuredWidth = Math.ceil(Math.max(width, minWidth));
				target.measuredHeight = Math.ceil(Math.max(height, minHeight));
				target.measuredMinWidth = Math.ceil(minWidth);
				target.measuredMinHeight = Math.ceil(minHeight);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (target==null)
				return;
			
			var count:int = target.numElements;
			
			var maxX:Number = 0;
			var maxY:Number = 0;
			for (var i:int = 0; i < count; i++)
			{
				var layoutElement:ILayoutElement = target.getElementAt(i) as ILayoutElement;
				if (layoutElement==null||!layoutElement.includeInLayout)
					continue;
				
				var hCenter:Number          = layoutElement.horizontalCenter;
				var vCenter:Number          = layoutElement.verticalCenter;
				var left:Number             = layoutElement.left;
				var right:Number            = layoutElement.right;
				var top:Number              = layoutElement.top;
				var bottom:Number           = layoutElement.bottom;
				var percentWidth:Number     = layoutElement.percentWidth;
				var percentHeight:Number    = layoutElement.percentHeight;
				
				if(!UIGlobals.getForEgret(this))
				{
					var elementMaxWidth:Number = NaN; 
					var elementMaxHeight:Number = NaN;
				}
				
				var childWidth:Number = NaN;
				var childHeight:Number = NaN;
				
				
				if(!isNaN(left) && !isNaN(right))
				{
					childWidth = unscaledWidth - right - left;
				}
				else if (!isNaN(percentWidth))
				{
					childWidth = Math.round(unscaledWidth * Math.min(percentWidth * 0.01, 1));
					if(!UIGlobals.getForEgret(this))
					{
						elementMaxWidth = Math.min(layoutElement.getMaxBoundsWidth(),
							maxSizeToFitIn(unscaledWidth, hCenter, left, right, layoutElement.layoutBoundsX));
					}
				}
				
				if (!isNaN(top) && !isNaN(bottom))
				{
					childHeight = unscaledHeight - bottom - top;
				}
				else if (!isNaN(percentHeight))
				{
					childHeight = Math.round(unscaledHeight * Math.min(percentHeight * 0.01, 1));
					if(!UIGlobals.getForEgret(this))
					{
						elementMaxHeight = Math.min(layoutElement.getMaxBoundsHeight(),
							maxSizeToFitIn(unscaledHeight, vCenter, top, bottom, layoutElement.layoutBoundsY));
					}
				}
				
				if(!UIGlobals.getForEgret(this))
				{
					if (!isNaN(childWidth))
					{
						if (isNaN(elementMaxWidth))
							elementMaxWidth = layoutElement.getMaxBoundsWidth();
						childWidth = Math.max(layoutElement.getMinBoundsWidth(), Math.min(elementMaxWidth, childWidth));
					}
					if (!isNaN(childHeight))
					{
						if (isNaN(elementMaxHeight))
							elementMaxHeight = layoutElement.getMaxBoundsHeight();
						childHeight = Math.max(layoutElement.getMinBoundsHeight(), Math.min(elementMaxHeight, childHeight));
					}
				}
				
				layoutElement.setLayoutBoundsSize(childWidth, childHeight);
				
				var elementWidth:Number = layoutElement.layoutBoundsWidth;
				var elementHeight:Number = layoutElement.layoutBoundsHeight;
				
				
				var childX:Number = NaN;
				var childY:Number = NaN;
				
				if (!isNaN(hCenter))
					childX = Math.round((unscaledWidth - elementWidth) / 2 + hCenter);
				else if (!isNaN(left))
					childX = left;
				else if (!isNaN(right))
					childX = unscaledWidth - elementWidth - right;
				else
					childX = layoutElement.layoutBoundsX;
				
				if (!isNaN(vCenter))
					childY = Math.round((unscaledHeight - elementHeight) / 2 + vCenter);
				else if (!isNaN(top))
					childY = top;
				else if (!isNaN(bottom))
					childY = unscaledHeight - elementHeight - bottom;
				else
					childY = layoutElement.layoutBoundsY;
				
				layoutElement.setLayoutBoundsPosition(childX, childY);
				
				maxX = Math.max(maxX,childX+elementWidth);
				maxY = Math.max(maxY,childY+elementHeight);
				
				
			}
			if(UIGlobals.getForEgret(this))
			{
				target.setContentSize(maxX,maxY);
			}else
			{
				target.setContentSize(Math.ceil(maxX),Math.ceil(maxY));
			}
		}
	}
}