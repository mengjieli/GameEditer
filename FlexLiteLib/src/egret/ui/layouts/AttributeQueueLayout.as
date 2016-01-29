package egret.ui.layouts
{
	import egret.components.supportClasses.GroupBase;
	import egret.core.IVisualElement;
	import egret.layouts.supportClasses.LayoutBase;
	
	/**
	 * 属性列表的属性布局类
	 * @author featherJ
	 * 
	 */	
	public class AttributeQueueLayout extends LayoutBase
	{
		/**
		 * 横向间隔 
		 */		
		public var hGap:Number = 0;
		/**
		 * 纵向间隔
		 */		
		public var vGap:Number = 0;
		/**
		 * 右栏之后再水平中，纵向居中排列的附加控件个数 
		 */		
		public var numAdditional:int = 0;
		
		/**
		 * 左栏之前在水平居中，纵向居中排列的附加控件个数 
		 */		
		public var numHead:int = 0;
		
		/**
		 * 行高，如果设置了这值则会固定每行的行高。 
		 */		
		public var rowHeight:Number = NaN;
		
		private var _paddingTop:Number = 0;
		/**
		 * 容器的顶边缘与第一个布局元素的顶边缘之间的像素数,若为NaN将使用padding的值，默认值：0。
		 */
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			if (_paddingTop == value)
				return;
			
			_paddingTop = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		private var _paddingBottom:Number = 0;
		/**
		 * 容器的底边缘与最后一个布局元素的底边缘之间的像素数,若为NaN将使用padding的值，默认值：0。
		 */
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if (_paddingBottom == value)
				return;
			
			_paddingBottom = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		/**
		 * 标记目标容器的尺寸和显示列表失效
		 */		
		private function invalidateTargetSizeAndDisplayList():void
		{
			if(target)
			{
				target.invalidateSize();
				target.invalidateDisplayList();
			}
		}
		
		override public function measure():void
		{
			var target:GroupBase = this.target;
			var length:int = target.numElements;
			
			var elements:Array = [];
			for(var i:int = 0;i<length;i++)
			{
				if(target.getElementAt(i).includeInLayout)
				{
					elements.push(target.getElementAt(i));
				}
			}
			length = elements.length;
			if(length % (2+numHead+numAdditional) != 0)
			{
				super.measure();
				return;
			}
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var headMaxWidth:Number = 0;
			var firstMaxWidth:Number = 0;
			var secondMaxWidth:Number = 0;
			var additionalMaxWidth:Number = 0;
			
			var headMaxWidthArr:Array = [];
			for(i = 0;i < numHead;i++)
			{
				headMaxWidthArr.push(0);
			}
			
			var additionalMaxWidthArr:Array = [];
			for(i = 0;i < numAdditional;i++)
			{
				additionalMaxWidthArr.push(0);
			}
			
			for(i=0;i<length;i+=2+numHead+numAdditional)
			{
				var index:int = 0;
				for(var j:int = i;j<i+numHead;j++)
				{
					if(elements[j].preferredWidth > headMaxWidthArr[index])
					{
						headMaxWidthArr[index] = elements[j].preferredWidth;
					}
					index++;
				}
				if(elements[i+numHead].preferredWidth > firstMaxWidth)
				{
					firstMaxWidth = elements[i+numHead].preferredWidth;
				}
				if(elements[i+numHead+1].preferredWidth > secondMaxWidth)
				{
					secondMaxWidth = elements[i+numHead+1].preferredWidth;
				}
				index = 0;
				for(j = i+numHead+2;j<i+numHead+2+numAdditional;j++)
				{
					if(elements[j].preferredWidth > additionalMaxWidthArr[index])
					{
						additionalMaxWidthArr[index] = elements[j].preferredWidth;
					}
					index++;
				}
			}
			
			for(i = 0;i<headMaxWidthArr.length;i++)
			{
				headMaxWidth += headMaxWidthArr[i];
			}
			headMaxWidth += numHead*hGap;
			
			for(i = 0;i<additionalMaxWidthArr.length;i++)
			{
				additionalMaxWidth += additionalMaxWidthArr[i];
			}
			additionalMaxWidth += numAdditional*hGap;
			
			if(secondMaxWidth < target.preferredWidth-firstMaxWidth-additionalMaxWidth-hGap-headMaxWidth)
			{
				secondMaxWidth = target.preferredWidth-firstMaxWidth-additionalMaxWidth-hGap-headMaxWidth;
			}
			
			var currentH:Number = paddingTop;
			for(i = 0;i<length;i+=2+numAdditional+numHead)
			{
				//当前行的最大高度
				var maxH:Number = NaN;
				if(isNaN(rowHeight))
				{
					for(j = i;j<i+2+numAdditional+numHead;j++)
					{
						if(isNaN(maxH))
							maxH = IVisualElement(elements[j]).preferredHeight;
						if(IVisualElement(elements[j]).preferredHeight > maxH)
							maxH = IVisualElement(elements[j]).preferredHeight;
					}
				}else
				{
					maxH = rowHeight;
				}
				currentH += maxH+vGap;
			}
			currentH -= vGap;
			currentH += paddingBottom;
			if(currentH < 0) currentH = 0;
			target.measuredHeight = currentH;
			target.measuredWidth = headMaxWidth+firstMaxWidth+hGap+secondMaxWidth+additionalMaxWidth;
		}
		
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var target:GroupBase = this.target;
			var length:int = target.numElements;
			
			var elements:Array = [];
			for(var i:int = 0;i<length;i++)
			{
				if(target.getElementAt(i).includeInLayout)
				{
					elements.push(target.getElementAt(i));
				}
			}
			length = elements.length;
			
			if(length % (2+numHead+numAdditional) != 0)
			{
				super.updateDisplayList(unscaledWidth,unscaledHeight);
				return;
			}
			
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			var headMaxWidth:Number = 0;
			var firstMaxWidth:Number = 0;
			var secondMaxWidth:Number = 0;
			var additionalMaxWidth:Number = 0;
			var layoutBoundsX:int;
			var layoutBoundsY:int;
			var layoutBoundsH:Number;
			var layoutBoundsW:Number;
			
			
			var headMaxWidthArr:Array = [];
			for(i = 0;i < numHead;i++)
			{
				headMaxWidthArr.push(0);
			}
			
			var additionalMaxWidthArr:Array = [];
			for(i = 0;i < numAdditional;i++)
			{
				additionalMaxWidthArr.push(0);
			}
			
			for(i=0;i<length;i+=2+numHead+numAdditional)
			{
				var index:int = 0;
				for(var j:int = i;j<i+numHead;j++)
				{
					if(elements[j].preferredWidth > headMaxWidthArr[index])
					{
						headMaxWidthArr[index] = elements[j].preferredWidth;
					}
					index++;
				}
				if(elements[i+numHead].preferredWidth > firstMaxWidth)
				{
					firstMaxWidth = elements[i+numHead].preferredWidth;
				}
				if(elements[i+numHead+1].preferredWidth > secondMaxWidth)
				{
					secondMaxWidth = elements[i+numHead+1].preferredWidth;
				}
				index = 0;
				for(j = i+numHead+2;j<i+numHead+2+numAdditional;j++)
				{
					if(elements[j].preferredWidth > additionalMaxWidthArr[index])
					{
						additionalMaxWidthArr[index] = elements[j].preferredWidth;
					}
					index++;
				}
			}
			
			for(i = 0;i<headMaxWidthArr.length;i++)
			{
				headMaxWidth += headMaxWidthArr[i];
			}
			headMaxWidth += numHead*hGap;
			
			
			
			for(i = 0;i<additionalMaxWidthArr.length;i++)
			{
				additionalMaxWidth += additionalMaxWidthArr[i];
			}
			additionalMaxWidth += numAdditional*hGap;
			
			if(secondMaxWidth < target.layoutBoundsWidth-firstMaxWidth-additionalMaxWidth-hGap-headMaxWidth)
			{
				secondMaxWidth = target.layoutBoundsWidth-firstMaxWidth-additionalMaxWidth-hGap-headMaxWidth;
			}
			
			var currentH:Number = paddingTop;
			for(i = 0;i<length;i+=2+numAdditional+numHead)
			{
				//当前行的最大高度
				var maxH:Number = NaN;
				if(isNaN(rowHeight))
				{
					for(j = i;j<i+2+numAdditional+numHead;j++)
					{
						if(isNaN(maxH))
							maxH = IVisualElement(elements[j]).layoutBoundsHeight;
						if(IVisualElement(elements[j]).layoutBoundsHeight > maxH)
							maxH = IVisualElement(elements[j]).layoutBoundsHeight;
					}
				}else
				{
					maxH = rowHeight;
				}
				
				//head
				index = 0;
				for(j = i;j<i+numHead;j++)
				{
					var headLayoutBoundsX:Number = 0;
					var headLayoutBoundsY:Number = currentH;
					var headLayoutBoundsW:Number = 0;
					var headLayoutBoundsH:Number = 0;
					
					for(var k:int = 0;k<index;k++)
					{
						headLayoutBoundsX += headMaxWidthArr[k]+hGap;
					}
					var headElement:IVisualElement = elements[j];
					if(isNaN(headElement.percentHeight))
					{
						headLayoutBoundsY += maxH/2-headElement.layoutBoundsHeight/2;
						headLayoutBoundsH = headElement.layoutBoundsHeight;
					}else
					{
						headLayoutBoundsH = maxH*headElement.percentHeight/100;
					}
					
					if(isNaN(headElement.percentWidth))
					{
						headLayoutBoundsX += headMaxWidthArr[index]/2-headElement.layoutBoundsWidth/2;
						headLayoutBoundsW = headElement.layoutBoundsWidth;
					}else
					{
						headLayoutBoundsW = headMaxWidthArr[index]*headElement.percentWidth/100;
					}
					index++;
					headElement.setLayoutBoundsPosition(headLayoutBoundsX,headLayoutBoundsY);
					headElement.setLayoutBoundsSize(headLayoutBoundsW,headLayoutBoundsH);
				}
				
				var firstElement:IVisualElement = elements[i+numHead];
				var secondElement:IVisualElement = elements[i+numHead+1];
				
				//first
				layoutBoundsW = NaN;
				layoutBoundsH = NaN;
				if(!isNaN(firstElement.percentWidth))
					layoutBoundsW = firstMaxWidth*firstElement.percentWidth/100;
				else
					layoutBoundsW = firstElement.layoutBoundsWidth;
				if(!isNaN(firstElement.percentHeight))
					layoutBoundsH = maxH*firstElement.percentHeight/100;
				else
					layoutBoundsH = firstElement.layoutBoundsHeight;
				if(isNaN(firstElement.left) && isNaN(firstElement.right))
				{
					layoutBoundsX = headMaxWidth + firstMaxWidth-layoutBoundsW;
				}else
				{
					if(isNaN(firstElement.left) && !isNaN(firstElement.right))
					{
						var right:Number = firstElement.right;
						if(right>firstMaxWidth-layoutBoundsW)
							right = firstMaxWidth-layoutBoundsW;
						layoutBoundsX = headMaxWidth+ firstMaxWidth-layoutBoundsW-right;
					}else if(!isNaN(firstElement.left) && isNaN(firstElement.right))
					{
						var left:Number = firstElement.left;
						if(left>firstMaxWidth-layoutBoundsW)
							left = firstMaxWidth-layoutBoundsW;
						layoutBoundsX = headMaxWidth+ left;
					}else if(!isNaN(firstElement.left) && !isNaN(firstElement.right))
					{
						left = firstElement.left;
						right = firstElement.right;
						if(left+right > firstElement.minWidth)
						{
							layoutBoundsX = headMaxWidth+ firstMaxWidth/2 - firstElement.minWidth/2;
							layoutBoundsW = firstElement.minWidth;
						}else
						{
							layoutBoundsX = headMaxWidth+left;
							layoutBoundsW = firstMaxWidth-left-right;
						}
					}
				}
				
				if(isNaN(firstElement.top) && isNaN(firstElement.bottom))
				{
					layoutBoundsY = currentH+maxH/2-layoutBoundsH/2;
				}else
				{
					if(isNaN(firstElement.top) && !isNaN(firstElement.bottom))
					{
						var bottom:Number = firstElement.bottom;
						if(bottom>maxH-layoutBoundsH)
							bottom = maxH-layoutBoundsH;
						layoutBoundsY = currentH + maxH-layoutBoundsH-bottom;
					}else if(!isNaN(firstElement.top) && isNaN(firstElement.bottom))
					{
						var top:Number = firstElement.top;
						if(top>maxH-layoutBoundsH)
							top = maxH-layoutBoundsH;
						layoutBoundsY = currentH+ top;
					}else if(!isNaN(firstElement.top) && !isNaN(firstElement.bottom))
					{
						top = firstElement.top;
						bottom = firstElement.bottom;
						if(top+bottom > firstElement.minHeight)
						{
							layoutBoundsY = currentH+ maxH/2 - firstElement.minHeight/2;
							layoutBoundsH = firstElement.minHeight;
						}else
						{
							layoutBoundsY = currentH+top;
							layoutBoundsH = maxH-top-bottom;
						}
					}
				}
				
				firstElement.setLayoutBoundsSize(layoutBoundsW,layoutBoundsH);
				firstElement.setLayoutBoundsPosition(layoutBoundsX,layoutBoundsY);
				
				//second
				layoutBoundsW = NaN;
				layoutBoundsH = NaN;
				if(!isNaN(secondElement.percentWidth))
					layoutBoundsW = secondMaxWidth*secondElement.percentWidth/100;
				else
					layoutBoundsW = secondElement.layoutBoundsWidth;
				if(!isNaN(secondElement.percentHeight))
					layoutBoundsH = maxH*secondElement.percentHeight/100;
				else
					layoutBoundsH = secondElement.layoutBoundsHeight;
				secondElement.setLayoutBoundsSize(layoutBoundsW,layoutBoundsH);
				
				layoutBoundsX = firstMaxWidth+hGap+headMaxWidth;
				layoutBoundsY = currentH+maxH/2-layoutBoundsH/2;
				secondElement.setLayoutBoundsPosition(layoutBoundsX,layoutBoundsY);
				
				
				//additional
				index = 0;
				for(j = i+headElement+2;j<i+headElement+2+numAdditional;j++)
				{
					var additionalLayoutBoundsX:Number = headMaxWidth+firstMaxWidth+hGap+secondMaxWidth+hGap;
					var additionalLayoutBoundsY:Number = currentH;
					var additionalLayoutBoundsW:Number = 0;
					var additionalLayoutBoundsH:Number = 0;
					
					for(k = 0;k<index;k++)
					{
						additionalLayoutBoundsX += additionalMaxWidthArr[k]+hGap; 
					}
					var additionalElement:IVisualElement = elements[j];
					if(isNaN(additionalElement.percentHeight))
					{
						if(isNaN(additionalElement.top) && isNaN(additionalElement.bottom))
						{
							additionalLayoutBoundsY = currentH + maxH/2-additionalElement.layoutBoundsHeight/2;
							additionalLayoutBoundsH = additionalElement.layoutBoundsHeight;
						}else
						{
							if(isNaN(additionalElement.top) && !isNaN(additionalElement.bottom))
							{
								bottom = additionalElement.bottom;
								if(bottom>maxH-additionalLayoutBoundsH)
									bottom = maxH-additionalLayoutBoundsH;
								additionalLayoutBoundsY = currentH + maxH-additionalLayoutBoundsH-bottom;
							}else if(!isNaN(additionalElement.top) && isNaN(additionalElement.bottom))
							{
								top = additionalElement.top;
								if(top>maxH-additionalLayoutBoundsH)
									top = maxH-additionalLayoutBoundsH;
								additionalLayoutBoundsY = currentH + top;
							}else if(!isNaN(additionalElement.top) && !isNaN(additionalElement.bottom))
							{
								top = additionalElement.top;
								bottom = additionalElement.bottom;
								if(top+bottom > additionalElement.minHeight)
								{
									additionalLayoutBoundsY = currentH+ maxH/2 - additionalElement.minHeight/2;
									additionalLayoutBoundsH = additionalElement.minHeight;
								}else
								{
									additionalLayoutBoundsY = currentH+top;
									additionalLayoutBoundsH = maxH-top-bottom;
								}
							}
						}
					}else
					{
						additionalLayoutBoundsH = maxH*additionalElement.percentHeight/100;
					}
					
					if(isNaN(additionalElement.percentWidth))
					{
						additionalLayoutBoundsX += additionalMaxWidthArr[index]/2-additionalElement.layoutBoundsWidth/2;
						additionalLayoutBoundsW = additionalElement.layoutBoundsWidth;
					}else
					{
						additionalLayoutBoundsW = additionalMaxWidthArr[index]*additionalElement.percentWidth/100;
					}
					
					
					additionalElement.setLayoutBoundsPosition(additionalLayoutBoundsX,additionalLayoutBoundsY);
					additionalElement.setLayoutBoundsSize(additionalLayoutBoundsW,additionalLayoutBoundsH);
					index++;
				}
				//end
				currentH += maxH+vGap;
			}
			currentH -= vGap;
			currentH += paddingBottom;
			target.setContentSize(Math.ceil(firstMaxWidth+hGap+secondMaxWidth+additionalMaxWidth),Math.ceil(currentH));
			target.invalidateSize();
		}
	}
}