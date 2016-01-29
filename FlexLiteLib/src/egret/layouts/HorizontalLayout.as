package egret.layouts
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import egret.components.supportClasses.GroupBase;
	import egret.core.ILayoutElement;
	import egret.core.IVisualElement;
	import egret.core.NavigationUnit;
	import egret.core.UIGlobals;
	import egret.layouts.supportClasses.LayoutBase;
	
	[EXML(show="false")]
	
	/**
	 * 水平布局
	 * @author dom
	 */
	public class HorizontalLayout extends LayoutBase
	{
		public function HorizontalLayout()
		{
			super();
		}
		
		private var _horizontalAlign:String = HorizontalAlign.LEFT;
		/**
		 * 布局元素的水平对齐策略。参考HorizontalAlign定义的常量。
		 * 注意：此属性设置为CONTENT_JUSTIFY始终无效。当useVirtualLayout为true时，设置JUSTIFY也无效。
		 */
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}
		
		public function set horizontalAlign(value:String):void
		{
			if(_horizontalAlign==value)
				return;
			_horizontalAlign = value;
			if(target)
				target.invalidateDisplayList();
		}
		
		private var _verticalAlign:String = VerticalAlign.TOP;
		/**
		 * 布局元素的竖直对齐策略。参考VerticalAlign定义的常量。
		 */
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}
		
		public function set verticalAlign(value:String):void
		{
			if(_verticalAlign==value)
				return;
			_verticalAlign = value;
			if(target)
				target.invalidateDisplayList();
		}
		
		private var _gap:Number = 6;
		/**
		 * 布局元素之间的水平空间（以像素为单位）
		 */
		public function get gap():Number
		{
			return _gap;
		}
		
		public function set gap(value:Number):void
		{
			if (_gap == value) 
				return;
			_gap = value;
			invalidateTargetSizeAndDisplayList();
			if(hasEventListener("gapChanged"))
				dispatchEvent(new Event("gapChanged"));
		}
		
		private var _padding:Number = 0;
		/**
		 * 四个边缘的共同内边距。若单独设置了任一边缘的内边距，则该边缘的内边距以单独设置的值为准。
		 * 此属性主要用于快速设置多个边缘的相同内边距。默认值：0。
		 */
		public function get padding():Number
		{
			return _padding;
		}
		public function set padding(value:Number):void
		{
			if(_padding==value)
				return;
			_padding = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		
		private var _paddingLeft:Number = NaN;
		/**
		 * 容器的左边缘与布局元素的左边缘之间的最少像素数,若为NaN将使用padding的值，默认值：NaN。
		 */
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if (_paddingLeft == value)
				return;
			
			_paddingLeft = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		private var _paddingRight:Number = NaN;
		/**
		 * 容器的右边缘与布局元素的右边缘之间的最少像素数,若为NaN将使用padding的值，默认值：NaN。
		 */
		public function get paddingRight():Number
		{
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			if (_paddingRight == value)
				return;
			
			_paddingRight = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		private var _paddingTop:Number = NaN;
		/**
		 * 容器的顶边缘与第一个布局元素的顶边缘之间的像素数,若为NaN将使用padding的值，默认值：NaN。
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
		
		private var _paddingBottom:Number = NaN;
		/**
		 * 容器的底边缘与最后一个布局元素的底边缘之间的像素数,若为NaN将使用padding的值，默认值：NaN。
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
		
		/**
		 * @inheritDoc
		 */
		override public function measure():void
		{
			super.measure();
			if(!target)
				return;
			if(useVirtualLayout)
			{
				measureVirtual();
			}
			else
			{
				measureReal();
			}
		}
		
		/**
		 * 测量使用虚拟布局的尺寸
		 */		
		private function measureVirtual():void
		{
			var numElements:int = target.numElements;
			var typicalHeight:Number = typicalLayoutRect?typicalLayoutRect.height:22;
			var typicalWidth:Number = typicalLayoutRect?typicalLayoutRect.width:71;
			var measuredWidth:Number = getElementTotalSize();
			var measuredHeight:Number = Math.max(maxElementHeight,typicalHeight);
			
			var visibleIndices:Vector.<int> = target.getElementIndicesInView();
			for each(var i:int in visibleIndices)
			{
				var layoutElement:ILayoutElement = target.getElementAt(i) as ILayoutElement;
				if (layoutElement == null||!layoutElement.includeInLayout)
					continue;
				
				var preferredWidth:Number = layoutElement.preferredWidth;
				var preferredHeight:Number = layoutElement.preferredHeight;
				measuredWidth += preferredWidth;
				measuredWidth -= isNaN(elementSizeTable[i])?typicalWidth:elementSizeTable[i];;
				measuredHeight = Math.max(measuredHeight,preferredHeight);
			}
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
			var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
			
			var hPadding:Number = paddingL + paddingR;
			var vPadding:Number = paddingT + paddingB;
			target.measuredWidth = Math.ceil(measuredWidth+hPadding);
			target.measuredHeight = Math.ceil(measuredHeight+vPadding);
			if(!UIGlobals.getForEgret(this))
			{
				target.measuredMinWidth = Math.ceil(target.measuredWidth);
				target.measuredMinHeight =(verticalAlign == VerticalAlign.JUSTIFY) ? vPadding : target.measuredHeight;
			}
			
		}
		
		/**
		 * 测量使用真实布局的尺寸
		 */		
		private function measureReal():void
		{
			var size:SizesAndLimit = new SizesAndLimit();
			var justify:Boolean = verticalAlign == VerticalAlign.JUSTIFY;
			var count:int = target.numElements;
			var numElements:int = count;
			var measuredWidth:Number = 0;
			var measuredHeight:Number = 0;
			if(!UIGlobals.getForEgret(this))
			{
				var minHeight:Number            = 0; // sum of the elt minimum heights
				var minWidth:Number             = 0; // max of the elt minimum widths
			}
			
			for (var i:int = 0; i < count; i++)
			{
				var layoutElement:ILayoutElement = target.getElementAt(i) as ILayoutElement;
				if (!layoutElement||!layoutElement.includeInLayout)
				{
					numElements--;
					continue;
				}
				if(UIGlobals.getForEgret(this))
				{
					preferredWidth = layoutElement.preferredWidth;
					preferredHeight = layoutElement.preferredHeight;
					measuredWidth += preferredWidth;
					measuredHeight = Math.max(measuredHeight,preferredHeight);
				}else
				{
					getElementWidth(layoutElement, NaN, size);
					var preferredWidth:Number = size.preferredSize;
					measuredWidth += preferredWidth;
					minWidth += size.minSize;
					
					getElementHeight(layoutElement, justify, size);
					var preferredHeight:Number = size.preferredSize;
					measuredHeight = Math.max(measuredHeight,preferredHeight);
					minHeight = Math.max(minHeight, size.minSize);
				}
			}
			var gap:Number = isNaN(_gap)?0:_gap;
			measuredWidth += (numElements-1)*gap;
			if(!UIGlobals.getForEgret(this))
				minWidth += (numElements-1)*gap;
			
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
			var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
			var hPadding:Number = paddingL + paddingR;
			var vPadding:Number = paddingT + paddingB;
			target.measuredWidth = Math.ceil(measuredWidth+hPadding);
			target.measuredHeight = Math.ceil(measuredHeight+vPadding);
			if(!UIGlobals.getForEgret(this))
			{
				target.measuredMinHeight = Math.ceil(minHeight + vPadding);
				target.measuredMinWidth  = Math.ceil(minWidth + hPadding);
			}
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width, height);
			if(!target)
				return;
			
			if (target.numElements == 0)
			{
				var padding:Number = isNaN(_padding)?0:_padding;
				var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
				var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
				var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
				var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
				target.setContentSize(Math.ceil(paddingL + paddingR),
					Math.ceil(paddingT + paddingB));
				return;         
			}
			
			if(useVirtualLayout)
			{
				updateDisplayListVirtual(width,height);
			}
			else
			{
				updateDisplayListReal(width,height);
			}
		}
		
		override public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint):int
		{
			if (!target || target.numElements < 1)
				return -1; 
			
			var maxIndex:int = target.numElements - 1;
			
			if (currentIndex == -1)
			{
				if (navigationUnit == NavigationUnit.LEFT)
					return -1;
				if (navigationUnit == NavigationUnit.RIGHT)
					return 0;    
			}
			
			currentIndex = Math.max(0, Math.min(maxIndex, currentIndex));
			
			var newIndex:int; 
			var bounds:Rectangle;
			var x:Number;
			
			switch (navigationUnit)
			{
				case NavigationUnit.LEFT:
					newIndex = currentIndex - 1;  
					break;
				case NavigationUnit.RIGHT: 
					newIndex = currentIndex + 1;  
					break;
				case NavigationUnit.PAGE_UP:
				case NavigationUnit.PAGE_LEFT:
					var firstIndex:int = findIndexAt(target.scrollRect.left,0,target.numElements-1);
					var lastIndex:int = findIndexAt(target.scrollRect.right,0,target.numElements-1);
					
					var firstFullyVisible:int = firstIndex;
					if (fractionOfElementInView(firstFullyVisible) < 1)
						firstFullyVisible += 1;
					
					if (firstFullyVisible < currentIndex && currentIndex <= lastIndex)
						newIndex = firstFullyVisible;
					else
					{
						if (currentIndex == firstFullyVisible || currentIndex == firstIndex)
							x = getHorizontalScrollPositionDelta(NavigationUnit.PAGE_LEFT) + getScrollRect().left;
						else
							x = getElementBounds(currentIndex).right - getScrollRect().width;
						
						newIndex = currentIndex - 1;
						while (0 <= newIndex)
						{
							bounds = getElementBounds(newIndex);
							if (bounds && bounds.left < x)
							{
								newIndex = Math.min(currentIndex - 1, newIndex + 1);
								break;
							}
							newIndex--;    
						}
					}
					break;
				case NavigationUnit.PAGE_DOWN:
				case NavigationUnit.PAGE_RIGHT:
					firstIndex = findIndexAt(target.scrollRect.left,0,target.numElements-1);
					lastIndex = findIndexAt(target.scrollRect.right,0,target.numElements-1);
					
					var lastFullyVisible:int = lastIndex;
					if (fractionOfElementInView(lastFullyVisible) < 1)
						lastFullyVisible -= 1;
					
					if (firstIndex <= currentIndex && currentIndex < lastFullyVisible)
						newIndex = lastFullyVisible;
					else
					{
						if (currentIndex == lastFullyVisible || currentIndex == lastIndex)
							x = getHorizontalScrollPositionDelta(NavigationUnit.PAGE_RIGHT) + getScrollRect().right;
						else
							x = getElementBounds(currentIndex).left + getScrollRect().width;
						
						newIndex = currentIndex + 1;
						while (newIndex <= maxIndex)
						{
							bounds = getElementBounds(newIndex);
							if (bounds && bounds.right > x)
							{
								newIndex = Math.max(currentIndex + 1, newIndex - 1);
								break;
							}
							newIndex++;    
						}
					}
					break;
				default:
					return super.getNavigationDestinationIndex(currentIndex, navigationUnit);
			}
			return Math.max(0, Math.min(maxIndex, newIndex));  
		}
		
		/**
		 * 如果指定的索引完全在视图中，则返回 1.0；如果不在视图中，则返回 0.0；
		 * 如果部分处于视图中，则返回在 0.0 和 1.0 之间的一个值（表示处于视图中的部分的百分比）。
		 */
		public function fractionOfElementInView(index:int):Number 
		{
			var g:GroupBase = GroupBase(target);
			if (!g)
				return 0.0;
			
			if ((index < 0) || (index >= g.numElements))
				return 0.0;
			
			if (!clipAndEnableScrolling)
				return 1.0;
			
			var eltX:Number;
			var eltWidth:Number;
			if (useVirtualLayout)
			{
				eltX = getStartPosition(index);
				eltWidth = getElementSize(index);
			}
			else 
			{
				var elt:ILayoutElement = g.getElementAt(index) as ILayoutElement;
				if (!elt || !elt.includeInLayout)
					return 0.0;
				eltX = elt.layoutBoundsX;
				eltWidth = elt.layoutBoundsWidth;
			}
			
			var x0:Number = g.horizontalScrollPosition;
			var x1:Number = x0 + g.width;
			var ix0:Number = eltX;
			var ix1:Number = ix0 + eltWidth;
			
			if (ix0 >= ix1)
				return 1.0;
			if ((ix0 >= x0) && (ix1 <= x1))
				return 1.0;
			if(ix1<=x0 || ix0>=x1)
				return 0.0;
			
			return (Math.min(x1, ix1) - Math.max(x0, ix0)) / (ix1 - ix0);
		}
		
		/**
		 * 虚拟布局使用的子对象尺寸缓存 
		 */		
		private var elementSizeTable:Array = [];
		
		/**
		 * 获取指定索引的起始位置
		 */		
		private function getStartPosition(index:int):Number
		{
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var gap:Number = isNaN(_gap)?0:_gap;
			if(!useVirtualLayout)
			{
				var element:IVisualElement;
				if(target)
				{
					element = target.getElementAt(index);
				}
				return element?element.x:paddingL;
			}
			var typicalWidth:Number = typicalLayoutRect?typicalLayoutRect.width:71;
			var startPos:Number = paddingL;
			for(var i:int = 0;i<index;i++)
			{
				var eltWidth:Number = elementSizeTable[i];
				if(isNaN(eltWidth))
				{
					eltWidth = typicalWidth;
				}
				startPos += eltWidth+gap;
			}
			return startPos;
		}
		
		/**
		 * 获取指定索引的元素尺寸
		 */		
		private function getElementSize(index:int):Number
		{
			if(useVirtualLayout)
			{
				var size:Number = elementSizeTable[index];
				if(isNaN(size))
				{
					size = typicalLayoutRect?typicalLayoutRect.width:71;
				}
				return size;
			}
			if(target)
			{
				return target.getElementAt(index).width;
			}
			return 0;
		}
		
		/**
		 * 获取缓存的子对象尺寸总和
		 */		
		private function getElementTotalSize():Number
		{
			var typicalWidth:Number = typicalLayoutRect?typicalLayoutRect.width:71;
			var gap:Number = isNaN(_gap)?0:_gap;
			var totalSize:Number = 0;
			var length:int = target.numElements;
			for(var i:int = 0; i<length; i++)
			{
				var eltWidth:Number = elementSizeTable[i];
				if(isNaN(eltWidth))
				{
					eltWidth = typicalWidth;
				}
				totalSize += eltWidth+gap;
			}
			totalSize -= gap;
			return totalSize;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function elementAdded(index:int):void
		{
			if(!useVirtualLayout)
				return;
			super.elementAdded(index);
			var typicalWidth:Number = typicalLayoutRect?typicalLayoutRect.width:71;
			elementSizeTable.splice(index,0,typicalWidth);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function elementRemoved(index:int):void
		{
			if(!useVirtualLayout)
				return;
			super.elementRemoved(index);
			elementSizeTable.splice(index,1);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clearVirtualLayoutCache():void
		{
			if(!useVirtualLayout)
				return;
			super.clearVirtualLayoutCache();
			elementSizeTable = [];
			maxElementHeight = 0;
		}
		
		
		
		/**
		 * 折半查找法寻找指定位置的显示对象索引
		 */		
		private function findIndexAt(x:Number, i0:int, i1:int):int
		{
			var index:int = (i0 + i1) / 2;
			var elementX:Number = getStartPosition(index);
			var elementWidth:Number = getElementSize(index);
			var gap:Number = isNaN(_gap)?0:_gap;
			if ((x >= elementX) && (x < elementX + elementWidth + gap))
				return index;
			else if (i0 == i1)
				return -1;
			else if (x < elementX)
				return findIndexAt(x, i0, Math.max(i0, index-1));
			else 
				return findIndexAt(x, Math.min(index+1, i1), i1);
		} 
		
		/**
		 * 虚拟布局使用的当前视图中的第一个元素索引
		 */		
		private var startIndex:int = -1;
		/**
		 * 虚拟布局使用的当前视图中的最后一个元素的索引
		 */		
		private var endIndex:int = -1;
		/**
		 * 视图的第一个和最后一个元素的索引值已经计算好的标志 
		 */		
		private var indexInViewCalculated:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		override protected function scrollPositionChanged():void
		{
			super.scrollPositionChanged();
			if(useVirtualLayout)
			{
				var changed:Boolean = getIndexInView();
				if(changed)
				{
					indexInViewCalculated = true;
					target.invalidateDisplayList();
				}
			}
			
		}
		
		/**
		 * 获取视图中第一个和最后一个元素的索引,返回是否发生改变
		 */		
		private function getIndexInView():Boolean
		{
			if(!target||target.numElements==0)
			{
				startIndex = endIndex = -1;
				return false;
			}
			
			if(isNaN(target.width)||target.width==0||isNaN(target.height)||target.height==0)
			{
				startIndex = endIndex = -1;
				return false;
			}
			
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
			var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
			
			var numElements:int = target.numElements;
			var contentWidth:Number = getStartPosition(numElements-1)+
				elementSizeTable[numElements-1]+paddingR;			
			var minVisibleX:Number = target.horizontalScrollPosition;
			if(minVisibleX>contentWidth-paddingR)
			{
				startIndex = -1;
				endIndex = -1;
				return false;
			}
			var maxVisibleX:Number = target.horizontalScrollPosition + target.width;
			if(maxVisibleX<paddingL)
			{
				startIndex = -1;
				endIndex = -1;
				return false;
			}
			var oldStartIndex:int = startIndex;
			var oldEndIndex:int = endIndex;
			startIndex = findIndexAt(minVisibleX,0,numElements-1);
			if(startIndex==-1)
				startIndex = 0;
			endIndex = findIndexAt(maxVisibleX,0,numElements-1);
			if(endIndex == -1)
				endIndex = numElements-1;
			return oldStartIndex!=startIndex||oldEndIndex!=endIndex;
		}
		
		/**
		 * 子对象最大宽度 
		 */		
		private var maxElementHeight:Number = 0;
		
		/**
		 * 更新使用虚拟布局的显示列表
		 */		
		private function updateDisplayListVirtual(width:Number,height:Number):void
		{
			if(indexInViewCalculated)
				indexInViewCalculated = false;
			else
				getIndexInView();
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
			var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
			var gap:Number = isNaN(_gap)?0:_gap;
			var contentWidth:Number;
			var numElements:int = target.numElements;
			if(startIndex == -1||endIndex==-1)
			{
				contentWidth = getStartPosition(numElements)-gap+paddingR;
				target.setContentSize(Math.ceil(contentWidth),target.contentHeight);
				return;
			}
			target.setVirtualElementIndicesInView(startIndex,endIndex);
			//获取垂直布局参数
			var justify:Boolean = _verticalAlign==VerticalAlign.JUSTIFY||_verticalAlign==VerticalAlign.CONTENT_JUSTIFY;
			var contentJustify:Boolean = _verticalAlign==VerticalAlign.CONTENT_JUSTIFY;
			var vAlign:Number = 0;
			if(!justify)
			{
				if(_verticalAlign==VerticalAlign.MIDDLE)
				{
					vAlign = 0.5;
				}
				else if(_verticalAlign==VerticalAlign.BOTTOM)
				{
					vAlign = 1;
				}
			}
			
			var targetHeight:Number = Math.max(0, height - paddingT - paddingB);
			var justifyHeight:Number = Math.ceil(targetHeight);
			var layoutElement:ILayoutElement;
			var typicalHeight:Number = typicalLayoutRect?typicalLayoutRect.height:22;
			var typicalWidth:Number = typicalLayoutRect?typicalLayoutRect.width:71;
			var oldMaxH:Number = Math.max(typicalHeight,maxElementHeight);
			if(contentJustify)
			{
				for(var index:int=startIndex;index<=endIndex;index++)
				{
					layoutElement = target.getVirtualElementAt(index) as ILayoutElement;
					if (!layoutElement||!layoutElement.includeInLayout)
						continue;
					maxElementHeight = Math.max(maxElementHeight,layoutElement.preferredHeight);
				}
				justifyHeight = Math.ceil(Math.max(targetHeight,maxElementHeight));
			}
			var x:Number = 0;
			var y:Number = 0;
			var contentHeight:Number = 0;
			var oldElementSize:Number;
			var needInvalidateSize:Boolean = false;
			//对可见区域进行布局
			for(var i:int=startIndex;i<=endIndex;i++)
			{
				var exceesHeight:Number = 0;
				layoutElement = target.getVirtualElementAt(i) as ILayoutElement;
				if (!layoutElement)
				{
					continue;
				}
				else if(!layoutElement.includeInLayout)
				{
					elementSizeTable[i] = 0;
					continue;
				}
				if(justify)
				{
					y = paddingT;
					layoutElement.setLayoutBoundsSize(NaN,justifyHeight);
				}
				else
				{
					exceesHeight = (targetHeight - layoutElement.layoutBoundsHeight)*vAlign;
					exceesHeight = exceesHeight>0?exceesHeight:0;
					y = paddingT+exceesHeight;
				}
				if(!contentJustify)
					maxElementHeight = Math.max(maxElementHeight,layoutElement.preferredHeight);
				contentHeight = Math.max(contentHeight,layoutElement.layoutBoundsHeight);
				if(!needInvalidateSize)
				{
					oldElementSize = isNaN(elementSizeTable[i])?typicalWidth:elementSizeTable[i];
					if(oldElementSize!=layoutElement.layoutBoundsWidth)
						needInvalidateSize = true;
				}
				if(i==0&&elementSizeTable.length>0&&elementSizeTable[i]!=layoutElement.layoutBoundsWidth)
					typicalLayoutRect = null;
				elementSizeTable[i] = layoutElement.layoutBoundsWidth;
				x = getStartPosition(i);
				layoutElement.setLayoutBoundsPosition(Math.round(x),Math.round(y));
			}
			
			contentHeight += paddingT+paddingB;
			contentWidth = getStartPosition(numElements)-gap+paddingR;	
			target.setContentSize(Math.ceil(contentWidth),
				Math.ceil(contentHeight));
			if(needInvalidateSize||oldMaxH<maxElementHeight)
			{
				target.invalidateSize();
			}
		}
		
		
		private static var cacheWidthDic:Dictionary = new Dictionary(true);
		
		/**
		 * 更新使用真实布局的显示列表
		 */		
		private function updateDisplayListReal(width:Number,height:Number):void
		{
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var paddingT:Number = isNaN(_paddingTop)?padding:_paddingTop;
			var paddingB:Number = isNaN(_paddingBottom)?padding:_paddingBottom;
			var gap:Number = isNaN(_gap)?0:_gap;
			var targetWidth:Number = Math.max(0, width - paddingL - paddingR);
			var targetHeight:Number = Math.max(0, height - paddingT - paddingB);
			
			var hJustify:Boolean = _horizontalAlign==HorizontalAlign.JUSTIFY;
			var vJustify:Boolean = _verticalAlign==VerticalAlign.JUSTIFY||_verticalAlign==VerticalAlign.CONTENT_JUSTIFY;
			var vAlign:Number = 0;
			if(!vJustify)
			{
				if(_verticalAlign==VerticalAlign.MIDDLE)
				{
					vAlign = 0.5;
				}
				else if(_verticalAlign==VerticalAlign.BOTTOM)
				{
					vAlign = 1;
				}
			}
			
			var count:int = target.numElements;
			var numElements:int = count;
			var x:Number = paddingL;
			var y:Number = paddingT;
			var i:int;
			var layoutElement:ILayoutElement;
			
			var totalPreferredWidth:Number = 0;
			var totalPercentWidth:Number = 0;
			var childInfoArray:Array = [];
			var childInfo:ChildInfo;
			var widthToDistribute:Number = targetWidth;
			for (i = 0; i < count; i++)
			{
				layoutElement = target.getElementAt(i) as ILayoutElement;
				if (!layoutElement||!layoutElement.includeInLayout)
				{
					numElements--;
					continue;
				}
				maxElementHeight = Math.max(maxElementHeight,layoutElement.preferredHeight);
				if(hJustify)
				{
					totalPreferredWidth += layoutElement.preferredWidth;
				}
				else
				{
					if(!isNaN(layoutElement.percentWidth))
					{
						totalPercentWidth += layoutElement.percentWidth;
						
						childInfo = new ChildInfo();
						childInfo.layoutElement = layoutElement;
						childInfo.percent    = layoutElement.percentWidth;
						if(UIGlobals.getForEgret(this))
						{
							childInfo.min        = layoutElement.minWidth
							childInfo.max        = layoutElement.maxWidth;
						}else
						{
							childInfo.min        = layoutElement.getMinBoundsWidth()
							childInfo.max        = layoutElement.getMaxBoundsWidth();
						}
						childInfoArray.push(childInfo);
						
					}
					else
					{
						widthToDistribute -= layoutElement.preferredWidth;
					}
				}
			}
			widthToDistribute -= gap * (numElements - 1);
			widthToDistribute = widthToDistribute>0?widthToDistribute:0;
			var excessSpace:Number = targetWidth - totalPreferredWidth - gap * (numElements - 1);
			
			var averageWidth:Number;
			var largeChildrenCount:int = numElements;
			var widthDic:Dictionary = cacheWidthDic;
			if(hJustify)
			{
				if(excessSpace<0)
				{
					averageWidth = widthToDistribute / numElements;
					for (i = 0; i < count; i++)
					{
						layoutElement = target.getElementAt(i);
						if (!layoutElement || !layoutElement.includeInLayout)
							continue;
						
						var preferredWidth:Number = layoutElement.preferredWidth;
						if (preferredWidth <= averageWidth)
						{
							widthToDistribute -= preferredWidth;
							largeChildrenCount--;
							continue;
						}
					}
					widthToDistribute = widthToDistribute>0?widthToDistribute:0;
				}
			}
			else
			{
				if(totalPercentWidth>0)
				{
					flexChildrenProportionally(targetWidth,widthToDistribute,
						totalPercentWidth,childInfoArray);
					var roundOff:Number = 0;
					for each (childInfo in childInfoArray)
					{
						var childSize:int = Math.round(childInfo.size + roundOff);
						roundOff += childInfo.size - childSize;
						
						widthDic[childInfo.layoutElement] = childSize;
						widthToDistribute -= childSize;
					}
					widthToDistribute = widthToDistribute>0?widthToDistribute:0;
				}
			}
			
			if(_horizontalAlign==HorizontalAlign.CENTER)
			{
				x = paddingL+widthToDistribute*0.5;
			}
			else if(_horizontalAlign==HorizontalAlign.RIGHT)
			{
				x = paddingL+widthToDistribute;
			}
			
			var maxX:Number = paddingL;
			var maxY:Number = paddingT;
			var dx:Number = 0;
			var dy:Number = 0;
			var justifyHeight:Number = Math.ceil(targetHeight);
			if(_verticalAlign==VerticalAlign.CONTENT_JUSTIFY)
				justifyHeight = Math.ceil(Math.max(targetHeight,maxElementHeight));
			roundOff = 0;
			var layoutElementWidth:Number;
			var childWidth:Number;
			for (i = 0; i < count; i++)
			{
				var exceesHeight:Number = 0;
				layoutElement = target.getElementAt(i) as ILayoutElement;
				if (!layoutElement||!layoutElement.includeInLayout)
					continue;
				layoutElementWidth = NaN;
				if(hJustify)
				{
					childWidth = NaN;
					if(excessSpace>0)
					{
						childWidth = widthToDistribute * layoutElement.preferredWidth / totalPreferredWidth;
					}
					else if(excessSpace<0&&layoutElement.preferredWidth>averageWidth)
					{
						childWidth = widthToDistribute / largeChildrenCount
					}
					if(!isNaN(childWidth))
					{
						layoutElementWidth = Math.round(childWidth + roundOff);
						roundOff += childWidth - layoutElementWidth;
					}
				}
				else
				{
					layoutElementWidth = widthDic[layoutElement];
				}
				if(vJustify)
				{
					y = paddingT;
					layoutElement.setLayoutBoundsSize(layoutElementWidth,justifyHeight);
				}
				else
				{
					var layoutElementHeight:Number = NaN;
					if(!isNaN(layoutElement.percentHeight))
					{
						var percent:Number = Math.min(100,layoutElement.percentHeight);
						layoutElementHeight = Math.round(targetHeight*percent*0.01);
					}
					layoutElement.setLayoutBoundsSize(layoutElementWidth,layoutElementHeight);
					exceesHeight = (targetHeight - layoutElement.layoutBoundsHeight)*vAlign;
					exceesHeight = exceesHeight>0?exceesHeight:0;
					y = paddingT+exceesHeight;
				}
				layoutElement.setLayoutBoundsPosition(Math.round(x),Math.round(y));
				dx = Math.ceil(layoutElement.layoutBoundsWidth);
				dy = Math.ceil(layoutElement.layoutBoundsHeight);
				maxX = Math.max(maxX,x+dx);
				maxY = Math.max(maxY,y+dy);
				x += dx+gap;
			}
			target.setContentSize(Math.ceil(maxX+paddingR),Math.ceil(maxY+paddingB));
		}
		
		/**
		 * 为每个可变尺寸的子项分配空白区域
		 */		
		public static function flexChildrenProportionally(spaceForChildren:Number,spaceToDistribute:Number,
														  totalPercent:Number,childInfoArray:Array):void
		{
			
			var numChildren:int = childInfoArray.length;
			var done:Boolean;
			
			do
			{
				done = true; 
				
				var unused:Number = spaceToDistribute -
					(spaceForChildren * totalPercent / 100);
				if (unused > 0)
					spaceToDistribute -= unused;
				else
					unused = 0;
				
				var spacePerPercent:Number = spaceToDistribute / totalPercent;
				
				for (var i:int = 0; i < numChildren; i++)
				{
					var childInfo:ChildInfo = childInfoArray[i];
					
					var size:Number = childInfo.percent * spacePerPercent;
					
					if (size < childInfo.min)
					{
						var min:Number = childInfo.min;
						childInfo.size = min;
						
						childInfoArray[i] = childInfoArray[--numChildren];
						childInfoArray[numChildren] = childInfo;
						
						totalPercent -= childInfo.percent;
						if (unused >= min)
						{
							unused -= min;
						}
						else
						{
							spaceToDistribute -= min - unused;
							unused = 0;
						}
						done = false;
						break;
					}
					else if (size > childInfo.max)
					{
						var max:Number = childInfo.max;
						childInfo.size = max;
						
						childInfoArray[i] = childInfoArray[--numChildren];
						childInfoArray[numChildren] = childInfo;
						
						totalPercent -= childInfo.percent;
						if (unused >= max)
						{
							unused -= max;
						}
						else
						{
							spaceToDistribute -= max - unused;
							unused = 0;
						}
						done = false;
						break;
					}
					else
					{
						childInfo.size = size;
					}
				}
			} 
			while (!done);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getElementBounds(index:int):Rectangle
		{
			if (!useVirtualLayout)
				return super.getElementBounds(index);
			
			var g:GroupBase = GroupBase(target);
			if (!g || (index < 0) || (index >= g.numElements)) 
				return null;
			
			var bounds:Rectangle = new Rectangle();
			var typicalHeight:Number = typicalLayoutRect?typicalLayoutRect.height:22;
			bounds.y = 0;
			bounds.height = typicalHeight;
			bounds.left = getStartPosition(index);
			bounds.right = getElementSize(index)+bounds.left;
			return bounds;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var rect:Rectangle = new Rectangle;
			if(!target)
				return rect;
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var firstIndex:int = findIndexAt(scrollRect.left,0,target.numElements-1);
			if(firstIndex==-1)
			{
				
				if(scrollRect.left>target.contentWidth - paddingR)
				{
					rect.left = target.contentWidth - paddingR;
					rect.right = target.contentWidth;
				}
				else
				{
					rect.left = 0;
					rect.right = paddingL;
				}
				return rect;
			}
			rect.left = getStartPosition(firstIndex);
			rect.right = getElementSize(firstIndex)+rect.left;
			if(rect.left==scrollRect.left)
			{
				firstIndex--;
				if(firstIndex!=-1)
				{
					rect.left = getStartPosition(firstIndex);
					rect.right = getElementSize(firstIndex)+rect.left;
				}
				else
				{
					rect.left = 0;
					rect.right = paddingL;
				}
			}
			return rect;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var rect:Rectangle = new Rectangle;
			if(!target)
				return rect;
			var numElements:int = target.numElements;
			var padding:Number = isNaN(_padding)?0:_padding;
			var paddingL:Number = isNaN(_paddingLeft)?padding:_paddingLeft;
			var paddingR:Number = isNaN(_paddingRight)?padding:_paddingRight;
			var lastIndex:int = findIndexAt(scrollRect.right,0,numElements-1);
			if(lastIndex==-1)
			{
				if(scrollRect.right<paddingL)
				{
					rect.left = 0;
					rect.right = paddingL;
				}
				else
				{
					rect.left = target.contentWidth - paddingR;
					rect.right = target.contentWidth;
				}
				return rect;
			}
			rect.left = getStartPosition(lastIndex);
			rect.right = getElementSize(lastIndex)+rect.left;
			if(rect.right<=scrollRect.right)
			{
				lastIndex++;
				if(lastIndex<numElements)
				{
					rect.left = getStartPosition(lastIndex);
					rect.right = getElementSize(lastIndex)+rect.left;
				}
				else
				{
					rect.left = target.contentWidth - paddingR;
					rect.right = target.contentWidth;
				}
			}
			return rect;
		}
		
		/**
		 *  @private
		 *  Fills in the result with preferred and min sizes of the element.
		 */
		private function getElementWidth(element:ILayoutElement, fixedColumnWidth:Number, result:SizesAndLimit):void
		{
			// Calculate preferred width first, as it's being used to calculate min width
			var elementPreferredWidth:Number = isNaN(fixedColumnWidth) ? Math.ceil(element.preferredWidth) :
				fixedColumnWidth;
			// Calculate min width
			var flexibleWidth:Boolean = !isNaN(element.percentWidth);
			var elementMinWidth:Number = flexibleWidth ? Math.ceil(element.getMinBoundsWidth()) : 
				elementPreferredWidth;
			result.preferredSize = elementPreferredWidth;
			result.minSize = elementMinWidth;
		}
		
		/**
		 *  @private
		 *  Fills in the result with preferred and min sizes of the element.
		 */
		private function getElementHeight(element:ILayoutElement, justify:Boolean, result:SizesAndLimit):void
		{
			// Calculate preferred height first, as it's being used to calculate min height below
			var elementPreferredHeight:Number = Math.ceil(element.preferredHeight);
			
			// Calculate min height
			var flexibleHeight:Boolean = !isNaN(element.percentHeight) || justify;
			var elementMinHeight:Number = flexibleHeight ? Math.ceil(element.getMinBoundsHeight()) : 
				elementPreferredHeight;
			result.preferredSize = elementPreferredHeight;
			result.minSize = elementMinHeight;
		}
		
	}
}
import egret.core.ILayoutElement;

class ChildInfo
{
	public function ChildInfo()
	{
		super();
	}
	
	public var layoutElement:ILayoutElement;  
	
	public var size:Number = 0;
	
	public var percent:Number;
	
	public var min:Number;
	
	public var max:Number;
}

class SizesAndLimit
{
	public var preferredSize:Number;
	public var minSize:Number;
}