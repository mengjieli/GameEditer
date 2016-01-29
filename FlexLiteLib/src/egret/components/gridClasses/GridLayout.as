package  egret.components.gridClasses
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import egret.collections.ICollection;
	import egret.components.DataGrid;
	import egret.components.Grid;
	import egret.core.IInvalidating;
	import egret.core.IVisualElement;
	import egret.core.IVisualElementContainer;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.layouts.supportClasses.LayoutBase;
	import egret.managers.ILayoutManagerClient;
	
	use namespace ns_egret;
	
	[ExcludeClass]
	
	/**
	 * 一个虚拟的二维布局类，这个不是通用布局，只是给数据网格用的。
	 */	
	public class GridLayout extends LayoutBase
	{
		public var gridDimensions:GridDimensions;
		
		/**
		 *  以下的属性用来定义数据表格的显示部分。每个渲染器显示为
		 * dataProvider[rowIndex][columns[columnIndex]].dataField
		 */		
		private var visibleRowIndices:Vector.<int> = new Vector.<int>(0);
		private var visibleColumnIndices:Vector.<int> = new Vector.<int>(0);
		/**
		 * 上一次的值，在updateDisplayList()的过程中，通过layoutItemRenderers()来赋值。
		 */		
		private var oldVisibleRowIndices:Vector.<int> = new Vector.<int>(0);
		private var oldVisibleColumnIndices:Vector.<int> = new Vector.<int>(0);		
		private var visibleRowBackgrounds:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
		private var visibleRowSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
		private var visibleColumnSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
		private var visibleItemRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>(0);
		private var hoverIndicator:IVisualElement = null;
		private var caretIndicator:IVisualElement = null;
		private var editorIndicator:IVisualElement = null;
		/**
		 * 所有可见元素的尺寸。这个尺寸可能比scrollRect要大，因为有可能第一个可见元素或者最后一个可见元素显示不全。具体参考scrollPositionChanged().
		 */		
		private var visibleItemRenderersBounds:Rectangle = new Rectangle();
		/**
		 * 可见表格的视图部分的尺寸；通常比visibleItemRenderersBounds要小。
		 * 通过updateDisplayList方法用当前的scrollPosition和表格的宽高进行初始化。
		 */		
		private var visibleGridBounds:Rectangle = new Rectangle();
		/**
		 * 可重用元素。字典表中一个IFactory对应一列可以被重用的元素实例Vector.<IVisualElement>。
		 */		
		private var freeElementMap:Dictionary = new Dictionary();
		/**
		 * 记录创建元素的IFactory，一边可重用的元素可以重新找到工厂。
		 * 通过createGridElement()来记录。
		 */		
		private var elementToFactoryMap:Dictionary = new Dictionary();
		/**
		 *  通过scrollPositionChanged()来指明哪个滚动条位置改变了
		 */		
		private var oldVerticalScrollPosition:Number = 0;
		private var oldHorizontalScrollPosition:Number = 0;
		
		private static var  _embeddedFontRegistryExists:Boolean = false;
		private static var embeddedFontRegistryExistsInitialized:Boolean = false;
		
		public function GridLayout()
		{
			super();
			gridDimensions = new GridDimensions();
		}
		
		/**
		 * GridLayout只能提供虚拟布局，所以这个属性无法被更改
		 */		
		override public function get useVirtualLayout():Boolean
		{
			return true;
		}
		override public function set useVirtualLayout(value:Boolean):void
		{
		}   
		private var _showCaret:Boolean = false;
		/**
		 * 插入符号是否可见 
		 */		
		public function get showCaret():Boolean
		{
			return _showCaret;
		}
		public function set showCaret(show:Boolean):void
		{
			if (caretIndicator)
				caretIndicator.visible = show;
			
			_showCaret = show;
		}
		/**
		 * 清空一切 
		 * 
		 */		
		override public function clearVirtualLayoutCache():void
		{
			freeGridElements(visibleRowBackgrounds);
			freeGridElements(visibleRowSeparators);
			visibleRowIndices.length = 0;
			
			freeGridElements(visibleColumnSeparators);        
			visibleColumnIndices.length = 0;
			
			freeItemRenderers(visibleItemRenderers);
			
			clearSelectionIndicators();
			
			freeGridElement(hoverIndicator)
			hoverIndicator = null;
			
			freeGridElement(caretIndicator);
			caretIndicator = null;
			
			freeGridElement(editorIndicator);
			editorIndicator = null;
			
			visibleItemRenderersBounds.setEmpty();
			visibleGridBounds.setEmpty();
		}     
		/**
		 * 这个版本的这个方法将通过 gridDimensions来计算指定数据单元的尺寸。
		 * 这个索引是数据单元的在行布局中位置。
		 * @param index
		 * @return 
		 * 
		 */		
		override public function getElementBounds(index:int):Rectangle
		{
			var columns:ICollection = (grid) ? grid.columns : null;
			if (!columns) 
				return null;
			
			var columnsLength:uint = columns.length;
			var rowIndex:int = index / columnsLength;
			var columnIndex:int = index - (rowIndex * columnsLength);
			return gridDimensions.getCellBounds(rowIndex, columnIndex); 
		}
		override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
		{
			var y:int = Math.max(0, scrollRect.top - 1);
			var rowIndex:int = gridDimensions.getRowIndexAt(scrollRect.x, y);
			return gridDimensions.getRowBounds(rowIndex);
		}
		override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
		{
			var maxY:int = Math.max(0, gridDimensions.getContentHeight() - 1); 
			var y:int = Math.min(maxY, scrollRect.bottom + 1);
			var rowIndex:int = gridDimensions.getRowIndexAt(scrollRect.x, y);
			return gridDimensions.getRowBounds(rowIndex);
		}
		override protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var x:int = Math.max(0, scrollRect.left - 1);
			var columnIndex:int = gridDimensions.getColumnIndexAt(x, scrollRect.y);
			return gridDimensions.getColumnBounds(columnIndex);
		}
		override protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var maxX:int = Math.max(0, gridDimensions.getContentWidth() - 1); 
			var x:int = Math.min(maxX, scrollRect.right + 1);
			var columnIndex:int = gridDimensions.getColumnIndexAt(x, scrollRect.y);
			return gridDimensions.getColumnBounds(columnIndex);
		}
		override protected function scrollPositionChanged():void
		{
			if (!grid)
				return;
			
			grid.hoverRowIndex = -1;
			grid.hoverColumnIndex = -1;
			
			super.scrollPositionChanged(); //设置 grid.scrollRect
			
			var hspChanged:Boolean = oldHorizontalScrollPosition != horizontalScrollPosition;
			var vspChanged:Boolean = oldVerticalScrollPosition != verticalScrollPosition;
			
			oldHorizontalScrollPosition = horizontalScrollPosition;
			oldVerticalScrollPosition = verticalScrollPosition;
			//只有当scrollRect变化的时候并且才见了行或列的时候才初始化。
			//同时，可见行或列的序号将被更新。
			
			var invalidate:Boolean;
			
			if (visibleRowIndices.length == 0 || visibleColumnIndices.length == 0)
				invalidate = true;
			
			if (!invalidate && vspChanged)
			{
				var oldFirstRowIndex:int = visibleRowIndices[0];
				var oldLastRowIndex:int = visibleRowIndices[visibleRowIndices.length - 1];
				
				var newFirstRowIndex:int = 
					gridDimensions.getRowIndexAt(horizontalScrollPosition, verticalScrollPosition);
				var newLastRowIndex:int = 
					gridDimensions.getRowIndexAt(horizontalScrollPosition, verticalScrollPosition + target.height);
				
				if (oldFirstRowIndex != newFirstRowIndex || oldLastRowIndex != newLastRowIndex)
					invalidate = true;
			}
			
			if (!invalidate && hspChanged)
			{
				var oldFirstColIndex:int = visibleColumnIndices[0];			
				var oldLastColIndex:int = visibleColumnIndices[visibleColumnIndices.length - 1];
				
				var newFirstColIndex:int = 
					gridDimensions.getColumnIndexAt(horizontalScrollPosition, verticalScrollPosition);
				var newLastColIndex:int = 
					gridDimensions.getColumnIndexAt(horizontalScrollPosition + target.width, verticalScrollPosition);
				
				if (oldFirstColIndex != newFirstColIndex || oldLastColIndex != newLastColIndex)
					invalidate = true;
			}
			
			if (invalidate)
			{
				var reason:String = "none";
				if (vspChanged && hspChanged)
					reason = "bothScrollPositions";
				else if (vspChanged)
					reason = "verticalScrollPosition"
				else if (hspChanged)
					reason = "horizontalScrollPosition";
				
				grid.invalidateDisplayListFor(reason);
			}
		}
		/**
		 * 计算 表格的measuredWidth,Height和measuredMinWidth,Height 属性
		 * 如果grid.requestedRowCount得到的是0，那measuredHeight得到的多行的内容高，
		 * 否则得到的是全部行的内容高。measuredWidth的计算方式也同理。
		 */		
		override public function measure():void
		{
			if (!grid)
				return;
			
			var startTime:Number;
			if (enablePerformanceStatistics)
				startTime = getTimer();        
			
			updateTypicalCellSizes();
			
			var measuredRowCount:int = grid.requestedRowCount;
			if (measuredRowCount == -1)
			{
				var rowCount:int = gridDimensions.rowCount;
				if (grid.requestedMaxRowCount != -1)
					measuredRowCount = Math.min(grid.requestedMaxRowCount, rowCount);
				if (grid.requestedMinRowCount != -1)
					measuredRowCount = Math.max(grid.requestedMinRowCount, measuredRowCount);                
			}
			
			var measuredWidth:Number = gridDimensions.getTypicalContentWidth(grid.requestedColumnCount);
			var measuredHeight:Number = gridDimensions.getTypicalContentHeight(measuredRowCount);
			var measuredMinWidth:Number = gridDimensions.getTypicalContentWidth(grid.requestedMinColumnCount);
			var measuredMinHeight:Number = gridDimensions.getTypicalContentHeight(grid.requestedMinRowCount);
			
			//通过 Math.ceil()来确保内容部分的最后像素也被算进去了，
			
			grid.measuredWidth = Math.ceil(measuredWidth);    
			grid.measuredHeight = Math.ceil(measuredHeight);
			
			if (enablePerformanceStatistics)
			{
				var elapsedTime:Number = getTimer() - startTime;
				performanceStatistics.measureTimes.push(elapsedTime);            
			}
		}
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (!grid)
				return;
			
			var startTime:Number;
			if (enablePerformanceStatistics)
			{
				startTime = getTimer();
				if (performanceStatistics.updateDisplayListStartTime === undefined)
					performanceStatistics.updateDisplayListStartTime = startTime;
			}
			//得到最后一个GridColumn.visible==true的列的索引
			
			var columns:ICollection = grid.columns;
			var lastVisibleColumnIndex:int = (columns) ? grid.getPreviousVisibleColumnIndex(grid.columns.length) : -1;
			if (!columns || lastVisibleColumnIndex < 0)
				return;
			
			//层
			
			var backgroundLayer:GridLayer = getLayer("backgroundLayer");
			var selectionLayer:GridLayer = getLayer("selectionLayer");    
			var editorIndicatorLayer:GridLayer = getLayer("editorIndicatorLayer");
			var rendererLayer:GridLayer = getLayer("rendererLayer");
			var overlayLayer:GridLayer = getLayer("overlayLayer"); 
			
			
			var completeLayoutNeeded:Boolean = 
				grid.isInvalidateDisplayListReason("verticalScrollPosition") ||
				grid.isInvalidateDisplayListReason("horizontalScrollPosition");
			
			//布局列和项渲染器；计算visibleRowIndices 的新数值。
			
			if (completeLayoutNeeded)
			{
				oldVisibleRowIndices = visibleRowIndices;
				oldVisibleColumnIndices = visibleColumnIndices;
				
				//指明可见内容的xy坐标，实际滚动位置可能是负值
				
				var scrollX:Number = Math.max(0, horizontalScrollPosition);
				var scrollY:Number = Math.max(0, verticalScrollPosition);
				
				visibleGridBounds.x = scrollX;
				visibleGridBounds.y = scrollY;
				visibleGridBounds.width = unscaledWidth;
				visibleGridBounds.height = unscaledHeight;
				
				layoutColumns(scrollX, scrollY, unscaledWidth);
				layoutItemRenderers(rendererLayer, scrollX, scrollY, unscaledWidth, unscaledHeight);
				
				//更新内容的尺寸，确保被占据了一部分的像素也被计算进去。
				
				var contentWidth:Number = Math.ceil(gridDimensions.getContentWidth());
				var contentHeight:Number = Math.ceil(gridDimensions.getContentHeight());
				grid.setContentSize(contentWidth, contentHeight); 
				
				//如果表格的内容高度比可用高度小，那填充可见行。
				
				var paddedRowCount:int = gridDimensions.rowCount;
				if ((scrollY == 0) && (contentHeight < unscaledHeight))
				{
					var unusedHeight:Number = unscaledHeight - gridDimensions.getContentHeight();
					paddedRowCount += Math.ceil(unusedHeight / gridDimensions.defaultRowHeight);
				}
				
				for (var rowIndex:int = gridDimensions.rowCount; rowIndex < paddedRowCount; rowIndex++)
					visibleRowIndices.push(rowIndex);
				
				//布局行的背景
				
				visibleRowBackgrounds = layoutLinearElements(grid.rowBackground, backgroundLayer,
					visibleRowBackgrounds, oldVisibleRowIndices, visibleRowIndices, layoutRowBackground);
				
				//布局行和列的分割线
				
				var lastRowIndex:int = paddedRowCount - 1;
				
				visibleRowSeparators = layoutLinearElements(grid.rowSeparator, overlayLayer, 
					visibleRowSeparators, oldVisibleRowIndices, visibleRowIndices, layoutRowSeparator, lastRowIndex);
				
				visibleColumnSeparators = layoutLinearElements(grid.columnSeparator, overlayLayer, 
					visibleColumnSeparators, oldVisibleColumnIndices, visibleColumnIndices, layoutColumnSeparator, lastVisibleColumnIndex);
				
				//旧的可见行可见列的长度已经可以不要了
				
				oldVisibleRowIndices.length = 0;
				oldVisibleColumnIndices.length = 0;            
			}
			
			//布局hoverIndicator,caretIndicator, 和selectionIndicators
			
			if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("hoverIndicator"))
				layoutHoverIndicator(backgroundLayer);
			
			if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("selectionIndicator"))
				layoutSelectionIndicators(selectionLayer);
			
			if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("caretIndicator"))
				layoutCaretIndicator(overlayLayer);
			
			if (completeLayoutNeeded || grid.isInvalidateDisplayListReason("editorIndicator"))
				layoutEditorIndicator(editorIndicatorLayer);
			
			if (!completeLayoutNeeded)
				updateVisibleItemRenderers();
			
			//避免闪烁，强制理解更新渲染
			grid.validateNow();
			
			if (enablePerformanceStatistics)
			{
				var endTime:Number = getTimer();
				var cellCount:int = visibleRowIndices.length * visibleColumnIndices.length;
				performanceStatistics.updateDisplayListEndTime = endTime;            
				performanceStatistics.updateDisplayListTimes.push(endTime - startTime);
				performanceStatistics.updateDisplayListRectangles.push(visibleGridBounds.clone());
				performanceStatistics.updateDisplayListCellCounts.push(cellCount);
			}
		}
		
		/**
		 * 重置全部可见渲染器的selected, showsCaret, 和 hovered属性，然后调用prepare()方法然后去渲染
		 * 
		 * 这个方法只有在渲染器还没有被更新的时候，通过layoutItemRenderers()来调用
		 */		
		private function updateVisibleItemRenderers():void
		{
			var grid:Grid = this.grid;  
			var rowSelectionMode:Boolean = isRowSelectionMode();
			var cellSelectionMode:Boolean = isCellSelectionMode();
			
			if (!rowSelectionMode && !cellSelectionMode)
				return;
			
			for each (var renderer:IGridItemRenderer in visibleItemRenderers)            
			{
				var rowIndex:int = renderer.rowIndex;
				var columnIndex:int = renderer.columnIndex;
				
				var oldSelected:Boolean  = renderer.selected;
				var oldShowsCaret:Boolean = renderer.showsCaret;
				var oldHovered:Boolean = renderer.hovered;
				if (rowSelectionMode)
				{                
					renderer.selected = grid.selectionContainsIndex(rowIndex);
					renderer.showsCaret = grid.caretRowIndex == rowIndex;
					renderer.hovered = grid.hoverRowIndex == rowIndex;
				}
				else if (cellSelectionMode)
				{
					renderer.selected = grid.selectionContainsCell(rowIndex, columnIndex);
					renderer.showsCaret = (grid.caretRowIndex == rowIndex) && (grid.caretColumnIndex == columnIndex);
					renderer.hovered = (grid.hoverRowIndex == rowIndex) && (grid.hoverColumnIndex == columnIndex);                    
				}
				
				if ((oldSelected != renderer.selected) || 
					(oldShowsCaret != renderer.showsCaret) || 
					(oldHovered != renderer.hovered))
					renderer.prepare(true);
			}
		}
		/**
		 * 数据表格 
		 * 
		 */		
		private function get grid():Grid
		{
			return target as Grid;
		}
		
		private function getLayer(name:String):GridLayer
		{
			var grid:Grid = this.grid;
			if (!grid)
				return null;
			
			return grid.getChildByName(name) as GridLayer;
		}
		private function getGridColumn(columnIndex:int):GridColumn
		{
			var columns:ICollection = grid.columns;
			if ((columns == null) || (columnIndex >= columns.length) || (columnIndex < 0))
				return null;
			
			return columns.getItemAt(columnIndex) as GridColumn;
		}
		private function getDataProviderItem(rowIndex:int):Object
		{
			var dataProvider:ICollection = grid.dataProvider;
			if ((dataProvider == null) || (rowIndex >= dataProvider.length) || (rowIndex < 0))
				return null;
			
			return dataProvider.getItemAt(rowIndex);
		}
		/**
		 * 返回 被最大宽度和最小宽度调整过的宽度值
		 * @param width
		 * @param column
		 * @return 
		 * 
		 */		
		private static function clampColumnWidth(width:Number, column:GridColumn):Number
		{
			var minColumnWidth:Number = column.minWidth;
			var maxColumnWidth:Number = column.maxWidth;
			
			if (!isNaN(minColumnWidth))
				width = Math.max(width, minColumnWidth);
			if (!isNaN(maxColumnWidth))
				width = Math.min(width, maxColumnWidth);
			
			return width;
		}
		
		/**
		 * 通过制定的表格列的渲染器工厂创建一个临时的渲染器。返回的项一定是可以freeGridElement()被回收的。
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		private function createTypicalItemRenderer(columnIndex:int):IGridItemRenderer
		{
			var rendererLayer:GridLayer = getLayer("rendererLayer");
			if (!rendererLayer)
				return null;
			
			var typicalItem:Object = grid.typicalItem;
			if (typicalItem == null)
				typicalItem = getDataProviderItem(0);
			
			var column:GridColumn = getGridColumn(columnIndex);
			var factory:Class = itemToRenderer(column, typicalItem);
			var renderer:IGridItemRenderer = allocateGridElement(factory) as IGridItemRenderer;
			
			rendererLayer.addElement(renderer);
			
			initializeItemRenderer(renderer, 0 /* 行索引 */, columnIndex, grid.typicalItem, false);
			
			//如果列宽没有自动布局，就用显示设置的值，如果这个也诶有，就用4096来避免换行。
			
			var columnWidth:Number = column.width;
			
			if (isNaN(columnWidth))
			{
				//虽然IUIComponent, UITextField, 和 UIFTETextField全都有explicitWidth属性，但是他们都是私有的。
				if ("explicitWidth" in renderer)
					columnWidth = Object(renderer).explicitWidth;
			}
			if (isNaN(columnWidth))
				columnWidth = 4096;
			
			layoutItemRenderer(renderer, 0, 0, columnWidth, NaN);
			
			return renderer;
		}
		
		/**
		 * 更新所有从startX坐标开始的列的typicalCellWidth,Height属性。典型尺寸只有在典型的数据单元尺寸为NaN的时候更新。
		 * @param width
		 * @param scrollX
		 * @param firstVisibleColumnIndex
		 * 
		 */		
		private function updateVisibleTypicalCellSizes(width:Number, scrollX:Number, firstVisibleColumnIndex:int):void
		{
			var rendererLayer:GridLayer = getLayer("rendererLayer");
			if (!rendererLayer)
				return;        
			
			var gridDimensions:GridDimensions = this.gridDimensions;
			var columnCount:int = gridDimensions.columnCount;
			var startCellX:Number = gridDimensions.getCellX(0 , firstVisibleColumnIndex);
			var columnGap:int = gridDimensions.columnGap;
			
			for (var columnIndex:int = firstVisibleColumnIndex;
				(width > 0) && (columnIndex >= 0) && (columnIndex < columnCount);
				columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
			{
				var cellHeight:Number = gridDimensions.getTypicalCellHeight(columnIndex);
				var cellWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
				
				var column:GridColumn = getGridColumn(columnIndex);
				if (!isNaN(column.width))
				{
					cellWidth = column.width;
					gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
				}
				
				if (isNaN(cellWidth) || isNaN(cellHeight))
				{
					var renderer:IGridItemRenderer = createTypicalItemRenderer(columnIndex);
					if (isNaN(cellWidth))
					{
						cellWidth = clampColumnWidth(renderer.preferredWidth, column);
						gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
					}
					if (isNaN(cellHeight))
					{
						cellHeight = renderer.preferredHeight;
						gridDimensions.setTypicalCellHeight(columnIndex, cellHeight);
					}
					
					rendererLayer.removeElement(renderer);                
					freeGridElement(renderer);
				}
				
				if (columnIndex == firstVisibleColumnIndex)
					width -= startCellX + cellWidth - scrollX;
				else
					width -= cellWidth + columnGap;
			}
		}
		
		private function updateTypicalCellSizes():void
		{
			var rendererLayer:GridLayer = getLayer("rendererLayer");
			if (!rendererLayer)
				return;  
			
			var gridDimensions:GridDimensions = this.gridDimensions;
			var columnCount:int = gridDimensions.columnCount;
			var columnGap:int = gridDimensions.columnGap;
			var requestedColumnCount:int = grid.requestedColumnCount;
			var measuredColumnCount:int = 0;
			
			for (var columnIndex:int = 0; (columnIndex < columnCount); columnIndex++)
			{
				var cellHeight:Number = gridDimensions.getTypicalCellHeight(columnIndex);
				var cellWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
				
				var column:GridColumn = getGridColumn(columnIndex);
				if (!column.visible)
				{
					gridDimensions.setTypicalCellWidth(columnIndex, 0);
					gridDimensions.setTypicalCellHeight(columnIndex, 0);
					continue;
				}
				
				if (!isNaN(column.width))
				{
					cellWidth = column.width;
					gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
				}
				
				var needTypicalRenderer:Boolean = (requestedColumnCount == -1) || (measuredColumnCount < requestedColumnCount);
				if (needTypicalRenderer && (isNaN(cellWidth) || isNaN(cellHeight)))
				{
					var renderer:IGridItemRenderer = createTypicalItemRenderer(columnIndex);
					if (isNaN(cellWidth))
					{
						cellWidth = clampColumnWidth(renderer.preferredWidth, column);
						gridDimensions.setTypicalCellWidth(columnIndex, cellWidth);
					}
					if (isNaN(cellHeight))
					{
						cellHeight = renderer.preferredHeight;
						gridDimensions.setTypicalCellHeight(columnIndex, cellHeight);
					}
					
					rendererLayer.removeElement(renderer);
					freeGridElement(renderer);
				}
				measuredColumnCount++;
			}
		}
		/**
		 * 从scrollX开始更新可见列宽，使其填充指定宽度，搜索所有的列的宽度偶将为NaN。
		 * 缺乏一个自动布局宽度的GridColumns的项渲染优先级最高的宽度
		 * 
		 * 如果宽度被指定并且所有列都可见，那我们就可以不需要自动布局宽度来调整列了使其充满整个可用空间。
		 */		
		private function layoutColumns(scrollX:Number, scrollY:Number, width:Number):void
		{
			var gridDimensions:GridDimensions = this.gridDimensions;
			var columnCount:int = gridDimensions.columnCount;
			if (columnCount <= 0)
				return;
			var firstVisibleColumnIndex:int = gridDimensions.getColumnIndexAt(scrollX, scrollY);
			updateVisibleTypicalCellSizes(width, scrollX, firstVisibleColumnIndex);
			var columnGap:int = gridDimensions.columnGap;
			var startCellX:Number = gridDimensions.getCellX(0 , firstVisibleColumnIndex);
			var availableWidth:Number = width;
			var flexibleColumnCount:uint = 0;
			
			for (var columnIndex:int = firstVisibleColumnIndex;
				(availableWidth > 0) && (columnIndex >= 0) && (columnIndex < columnCount);
				columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
			{
				var columnWidth:Number = gridDimensions.getTypicalCellWidth(columnIndex);
				var gridColumn:GridColumn = getGridColumn(columnIndex);
				
				if (isNaN(gridColumn.width)) 
				{
					flexibleColumnCount += 1;
					columnWidth = clampColumnWidth(columnWidth, gridColumn);
				}
				else
					columnWidth = gridColumn.width;
				
				gridDimensions.setColumnWidth(columnIndex, columnWidth);  
				
				if (columnIndex == firstVisibleColumnIndex)
					availableWidth -= startCellX + columnWidth - scrollX;
				else
					availableWidth -= columnWidth + columnGap;
			}
			if ((scrollX != 0) || (availableWidth < 1.0) || (flexibleColumnCount == 0))
				return;
			
			var columnWidthDelta:Number = Math.ceil(availableWidth / flexibleColumnCount);
			
			for (columnIndex = firstVisibleColumnIndex;
				(columnIndex >= 0) && (columnIndex < columnCount) && (availableWidth >= 1.0);
				columnIndex = grid.getNextVisibleColumnIndex(columnIndex))
			{
				gridColumn = getGridColumn(columnIndex);
				
				if (isNaN(gridColumn.width)) 
				{
					var oldColumnWidth:Number = gridDimensions.getColumnWidth(columnIndex);
					columnWidth = oldColumnWidth + Math.min(availableWidth, columnWidthDelta);
					columnWidth = clampColumnWidth(columnWidth, gridColumn);
					gridDimensions.setColumnWidth(columnIndex, columnWidth);  
					availableWidth -= (columnWidth - oldColumnWidth);
				}
			}    
		}
		private var gridItemRendererClassFactories:Dictionary = new Dictionary(true);
		/**
		 * 通过column.itemToRenderer(dataItem)，返回指定列的的指定数据源的项渲染器。
		 * 
		 * @param column
		 * @param dataItem
		 * @return 
		 * 
		 */		
		private function itemToRenderer(column:GridColumn, dataItem:Object):Class
		{
			return column.itemToRenderer(dataItem);
		}
		
		private function layoutItemRenderers(rendererLayer:GridLayer, scrollX:Number, scrollY:Number, width:Number, height:Number):void
		{
			if (!rendererLayer)
				return;
			
			var rowIndex:int;
			var colIndex:int;
			
			var gridDimensions:GridDimensions = this.gridDimensions;
			var rowCount:int = gridDimensions.rowCount; 
			var colCount:int = gridDimensions.columnCount;
			var rowGap:int = gridDimensions.rowGap;
			var colGap:int = gridDimensions.columnGap;
			
			var startColIndex:int = gridDimensions.getColumnIndexAt(scrollX, scrollY);
			var startRowIndex:int = gridDimensions.getRowIndexAt(scrollX, scrollY);
			var startCellX:Number = gridDimensions.getCellX(startRowIndex, startColIndex); 
			var startCellY:Number = gridDimensions.getCellY(startRowIndex, startColIndex); 
			var newVisibleColumnIndices:Vector.<int> = new Vector.<int>();
			var availableWidth:Number = width;
			var column:GridColumn;
			
			for (colIndex = startColIndex; 
				(availableWidth > 0) && (colIndex >= 0) && (colIndex < colCount);
				colIndex = grid.getNextVisibleColumnIndex(colIndex))
			{
				newVisibleColumnIndices.push(colIndex);
				var columnWidth:Number = gridDimensions.getColumnWidth(colIndex);
				if (colIndex == startColIndex)
					availableWidth -= startCellX + columnWidth - scrollX;
				else
					availableWidth -= columnWidth + colGap;
			}
			var newVisibleRowIndices:Vector.<int> = new Vector.<int>();
			var newVisibleItemRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>();
			
			var cellX:Number = startCellX;
			var cellY:Number = startCellY;
			var availableHeight:Number = height;
			
			for (rowIndex = startRowIndex; (availableHeight > 0) && (rowIndex >= 0) && (rowIndex < rowCount); rowIndex++)
			{
				newVisibleRowIndices.push(rowIndex);
				
				var rowHeight:Number = gridDimensions.getRowHeight(rowIndex);
				for each (colIndex in newVisibleColumnIndices)
				{
					var renderer:IGridItemRenderer = takeVisibleItemRenderer(rowIndex, colIndex);
					if (!renderer)
					{       
						var dataItem:Object = getDataProviderItem(rowIndex);
						column = getGridColumn(colIndex);
						var factory:Class = itemToRenderer(column, dataItem);
						renderer = allocateGridElement(factory) as IGridItemRenderer;
					}
					if (renderer.parent != rendererLayer)
						rendererLayer.addElement(renderer);
					newVisibleItemRenderers.push(renderer);
					
					initializeItemRenderer(renderer, rowIndex, colIndex);
					
					var colWidth:Number = gridDimensions.getColumnWidth(colIndex);
					layoutItemRenderer(renderer, cellX, cellY, colWidth, rowHeight);                
					
					var preferredRowHeight:Number = renderer.preferredHeight
					gridDimensions.setCellHeight(rowIndex, colIndex, preferredRowHeight);
					cellX += colWidth + colGap;
				}
				var finalRowHeight:Number = gridDimensions.getRowHeight(rowIndex);
				if (rowHeight != finalRowHeight)
				{
					var visibleColumnsLength:int = newVisibleColumnIndices.length;
					rowHeight = finalRowHeight;
					for each (colIndex in newVisibleColumnIndices)
					{
						var rowOffset:int = newVisibleRowIndices.indexOf(rowIndex);
						var colOffset:int = newVisibleColumnIndices.indexOf(colIndex);                    
						var index:int = (rowOffset * visibleColumnsLength) + colOffset;
						renderer = newVisibleItemRenderers[index];                    
						var rendererX:Number = renderer.layoutBoundsX;
						var rendererY:Number = renderer.layoutBoundsY;
						var rendererWidth:Number = renderer.layoutBoundsWidth;
						
						layoutItemRenderer(renderer, rendererX, rendererY, rendererWidth, rowHeight);
						gridDimensions.setCellHeight(rowIndex, colIndex, renderer.preferredHeight);
					}
				} 
				
				cellX = startCellX;
				cellY += rowHeight + rowGap;
				
				if (rowIndex == startRowIndex)
					availableHeight -= startCellY + rowHeight - scrollY;
				else
					availableHeight -= rowHeight + rowGap;            
			}
			for each (var oldRenderer:IGridItemRenderer in visibleItemRenderers)
			{
				freeItemRenderer(oldRenderer);
				if (oldRenderer)
					oldRenderer.discard(true);  
			}
			if ((newVisibleRowIndices.length > 0) && (newVisibleColumnIndices.length > 0))
			{
				var lastRowIndex:int = newVisibleRowIndices[newVisibleRowIndices.length - 1];
				var lastColIndex:int = newVisibleColumnIndices[newVisibleColumnIndices.length - 1];
				var lastCellR:Rectangle = gridDimensions.getCellBounds(lastRowIndex, lastColIndex);
				
				visibleItemRenderersBounds.x = startCellX;
				visibleItemRenderersBounds.y = startCellY; 
				visibleItemRenderersBounds.width = lastCellR.x + lastCellR.width - startCellX;
				visibleItemRenderersBounds.height = lastCellR.y + lastCellR.height - startCellY;
			}
			else
			{
				visibleItemRenderersBounds.setEmpty();
			}
			visibleItemRenderers = newVisibleItemRenderers;
			visibleRowIndices = newVisibleRowIndices;
			visibleColumnIndices = newVisibleColumnIndices;
		}
		
		/**
		 * 重新初始化，并且布局 指定行索引和列索引位置上的可见部分。如果数据单元的最优高度改变了
		 * 并且数据表格已经variableRowHeight=true了，那整个网格就是无效的。
		 * 
		 * <p>如果行索引或列索引只想的数据单元是不可见的，那什么事儿都不做</p>
		 * 
		 * @param rowIndex 
		 * @param columnIndex
		 * 
		 */		
		public function invalidateCell(rowIndex:int, columnIndex:int):void
		{
			var renderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
			if (!renderer)
				return;
			if (itemRendererFunctionValueChanged(renderer))
			{
				renderer.grid.invalidateDisplayList();
				return;
			}
			
			initializeItemRenderer(renderer, rowIndex, columnIndex);
			var rendererX:Number = renderer.layoutBoundsX;
			var rendererY:Number = renderer.layoutBoundsY;
			var rendererWidth:Number = renderer.layoutBoundsWidth;
			var rendererHeight:Number = renderer.layoutBoundsHeight;
			
			layoutItemRenderer(renderer, rendererX, rendererY, rendererWidth, rendererHeight);
			var preferredRendererHeight:Number = renderer.preferredHeight;
			if (gridDimensions.variableRowHeight && (rendererHeight != preferredRendererHeight))
				grid.invalidateDisplayList();
		}
		
		/**
		 * 如果指定的渲染器已经被itemRendererFunction定义了，就返回真
		 * @param renderer
		 * @return 
		 * 
		 */		
		private function itemRendererFunctionValueChanged(renderer:IGridItemRenderer):Boolean
		{
			var column:GridColumn = renderer.column;
			if (!column || (column.itemRendererFunction === null))
				return false;
			
			var factory:Class = itemToRenderer(column, renderer.data);
			return factory !== elementToFactoryMap[renderer];
		}
			
		private function getVisibleItemRendererIndex(rowIndex:int, columnIndex:int):int
		{
			if ((visibleRowIndices == null) || (visibleColumnIndices == null))
				return -1;
			var rowOffset:int = visibleRowIndices.indexOf(rowIndex);
			var colOffset:int = visibleColumnIndices.indexOf(columnIndex);
			if ((rowOffset == -1) || (colOffset == -1))
				return -1;
			
			var index:int = (rowOffset * visibleColumnIndices.length) + colOffset;
			return index;
		}
		
		public function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
		{
			var index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
			if (index == -1 || index >= visibleItemRenderers.length)
				return null;
			
			var renderer:IGridItemRenderer = visibleItemRenderers[index];
			return renderer;        
		}
		private function takeVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
		{
			var index:int = getVisibleItemRendererIndex(rowIndex, columnIndex);
			if (index == -1 || index >= visibleItemRenderers.length)
				return null;
			
			var renderer:IGridItemRenderer = visibleItemRenderers[index];
			visibleItemRenderers[index] = null;
			if (renderer && itemRendererFunctionValueChanged(renderer))
			{
				freeItemRenderer(renderer);
				return null;
			}
			
			return renderer;
		}
		private function initializeItemRenderer(
			renderer:IGridItemRenderer, 
			rowIndex:int, columnIndex:int,
			dataItem:Object=null,
			visible:Boolean=true):void
		{
			renderer.visible = visible;
			
			var gridColumn:GridColumn = getGridColumn(columnIndex);
			if (gridColumn)
			{
				renderer.rowIndex = rowIndex;
				renderer.column = gridColumn;
				if (dataItem == null)
					dataItem = getDataProviderItem(rowIndex);
				
				renderer.label = gridColumn.itemToLabel(dataItem);
				if (isRowSelectionMode())
				{
					renderer.selected = grid.selectionContainsIndex(rowIndex);
					renderer.showsCaret = grid.caretRowIndex == rowIndex;
					renderer.hovered = grid.hoverRowIndex == rowIndex;
				}
				else if (isCellSelectionMode())
				{
					renderer.selected = grid.selectionContainsCell(rowIndex, columnIndex);
					renderer.showsCaret = (grid.caretRowIndex == rowIndex) && (grid.caretColumnIndex == columnIndex);
					renderer.hovered = (grid.hoverRowIndex == rowIndex) && (grid.hoverColumnIndex == columnIndex);
				}
				
				renderer.data = dataItem;
				
				if (grid.dataGrid)
					renderer.ownerChanged(grid.dataGrid);
				
				renderer.prepare(!createdGridElement);             
			}
		}
		
		private function freeItemRenderer(renderer:IGridItemRenderer):void
		{
			if (!renderer)
				return;
			
			freeGridElement(renderer);
		}
		
		private function freeItemRenderers(renderers:Vector.<IGridItemRenderer>):void
		{
			for each (var renderer:IGridItemRenderer in renderers)
			freeItemRenderer(renderer);
			renderers.length = 0;
		}
		
		/**
		 *  布局rowBackround，rowSeparator, columnSeparator这些可是元素的通用代码。
		 * @param factory
		 * @param layer
		 * @param oldVisibleElements
		 * @param oldVisibleIndices
		 * @param newVisibleIndices
		 * @param layoutFunction
		 * @param lastIndex
		 * @return 
		 * 
		 */		
		private function layoutLinearElements(
			factory:Class,
			layer:GridLayer, 
			oldVisibleElements:Vector.<IVisualElement>,
			oldVisibleIndices:Vector.<int>,
			newVisibleIndices:Vector.<int>,
			layoutFunction:Function,
			lastIndex:int = -1):Vector.<IVisualElement>
		{
			if (!layer)
				return new Vector.<IVisualElement>(0);
			discardGridElementsIfFactoryChanged(factory, layer, oldVisibleElements);
			
			if (factory == null)
				return new Vector.<IVisualElement>(0);
			freeLinearElements(oldVisibleElements, oldVisibleIndices, newVisibleIndices, lastIndex);
			var newVisibleElementCount:uint = newVisibleIndices.length;
			var newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);
			
			for (var index:int = 0; index < newVisibleElementCount; index++) 
			{
				var newEltIndex:int = newVisibleIndices[index];
				if (newEltIndex == lastIndex)
				{
					newVisibleElements.length = index;
					break;
				}
				var eltOffset:int = oldVisibleIndices.indexOf(newEltIndex);
				var elt:IVisualElement = (eltOffset != -1 && eltOffset < oldVisibleElements.length) ? oldVisibleElements[eltOffset] : null;
				if (elt == null)
					elt = allocateGridElement(factory);
				newVisibleElements[index] = elt;
				
				layer.addElement(elt);
				
				elt.visible = true;
				
				layoutFunction(elt, newEltIndex);
			}
			
			return newVisibleElements;
		}
		
		private function layoutCellElements(
			factory:Class,
			layer:GridLayer,
			oldVisibleElements:Vector.<IVisualElement>,
			oldVisibleRowIndices:Vector.<int>, oldVisibleColumnIndices:Vector.<int>,
			newVisibleRowIndices:Vector.<int>, newVisibleColumnIndices:Vector.<int>,
			layoutFunction:Function):Vector.<IVisualElement>
		{
			if (!layer)
				return new Vector.<IVisualElement>(0);
			if (discardGridElementsIfFactoryChanged(factory, layer, oldVisibleElements))
			{
				oldVisibleRowIndices.length = 0;
				oldVisibleColumnIndices.length = 0;
			}
			
			if (factory == null)
				return new Vector.<IVisualElement>(0);
			var newVisibleElementCount:uint = newVisibleRowIndices.length;
			var newVisibleElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newVisibleElementCount);
			freeCellElements(oldVisibleElements, newVisibleElements,
				oldVisibleRowIndices, newVisibleRowIndices,
				oldVisibleColumnIndices, newVisibleColumnIndices);
			
			for (var index:int = 0; index < newVisibleElementCount; index++) 
			{
				var newEltRowIndex:int = newVisibleRowIndices[index];
				var newEltColumnIndex:int = newVisibleColumnIndices[index];
				var elt:IVisualElement = newVisibleElements[index];
				if (elt === null)
				{
					elt = allocateGridElement(factory);
					newVisibleElements[index] = elt;
				}
				
				layer.addElement(elt);
				
				elt.visible = true;
				
				layoutFunction(elt, newEltRowIndex, newEltColumnIndex);
			}
			
			return newVisibleElements;
		}
		
		/**
		 * 如果渲染器工厂变化了，或者为空了， 就移除掉所有可被重用的旧的可视化元素。
		 * @param factory
		 * @param layer
		 * @param oldVisibleElements
		 * @return  只要有一个可是元素被移除了就返回true
		 * 
		 */		
		private function discardGridElementsIfFactoryChanged(
			factory:Class,
			layer:GridLayer,
			oldVisibleElements:Vector.<IVisualElement>):Boolean    
		{
			if ((oldVisibleElements.length) > 0 && (factory != elementToFactoryMap[oldVisibleElements[0]]))
			{
				for each (var oldElt:IVisualElement in oldVisibleElements)
				{
					layer.removeElement(oldElt);
					freeGridElement(oldElt);
				}
				oldVisibleElements.length = 0;
				return true;
			}
			
			return false;
		}
		
		/**
		 * 缓存器每一个，oldindices相应的成员没有出现在newindices中的元素。所有列表将按照升序排列。当一个元素被缓存起来的时候，
		 * 符合的列表中的成员将被置为null
		 * @param elements
		 * @param oldIndices
		 * @param newIndices
		 * @param lastIndex
		 * 
		 */		
		private function freeLinearElements (
			elements:Vector.<IVisualElement>, 
			oldIndices:Vector.<int>, 
			newIndices:Vector.<int>, 
			lastIndex:int):void
		{
			
			for (var i:int = 0; i < elements.length; i++)
			{
				var offset:int = newIndices.indexOf(oldIndices[i]);
				if ((oldIndices[i] == lastIndex) || (offset == -1))
				{
					var elt:IVisualElement = elements[i];
					if (elt)
					{
						freeGridElement(elt);
						elements[i] = null;
					}
				}
			}
		}      
		
		private function freeCellElements (
			elements:Vector.<IVisualElement>, newElements:Vector.<IVisualElement>, 
			oldRowIndices:Vector.<int>, newRowIndices:Vector.<int>,
			oldColumnIndices:Vector.<int>, newColumnIndices:Vector.<int>):void
		{
			var freeElement:Boolean = true;
			var numNewCells:int = newRowIndices.length;
			var newIndex:int = 0;
			
			for (var i:int = 0; i < elements.length; i++)
			{
				var elt:IVisualElement = elements[i];
				if (elt == null)
					continue;
				var oldRowIndex:int = oldRowIndices[i];
				var oldColumnIndex:int = oldColumnIndices[i];
				
				for ( ; newIndex < numNewCells; newIndex++)
				{
					var newRowIndex:int = newRowIndices[newIndex];
					var newColumnIndex:int = newColumnIndices[newIndex];
					
					if (newRowIndex == oldRowIndex)
					{
						if (newColumnIndex == oldColumnIndex)
						{
							newElements[newIndex] = elt;
							freeElement = false;
							break;
						}
						else if (newColumnIndex > oldColumnIndex)
						{
							
							break;
						}
					}
					else if (newRowIndex > oldRowIndex)
					{
						
						break;
					}
				}
				
				if (freeElement)
					freeGridElement(elt);
				
				freeElement = true;
			}
			
			elements.length = 0;
		}      
		
		private function layoutRowBackground(rowBackground:IVisualElement, rowIndex:int):void
		{
			var rowCount:int = gridDimensions.rowCount;
			var bounds:Rectangle = (rowIndex < rowCount) 
				? gridDimensions.getRowBounds(rowIndex)
				: gridDimensions.getPadRowBounds(rowIndex);
			
			if (!bounds)
				return;
			
			if  ((rowIndex < rowCount) && (bounds.width == 0)) 
				bounds.width = visibleGridBounds.width;
			intializeGridVisualElement(rowBackground, rowIndex);
			
			layoutGridElementR(rowBackground, bounds);
		}
		
		private function layoutRowSeparator(separator:IVisualElement, rowIndex:int):void
		{
			
			intializeGridVisualElement(separator, rowIndex);
			
			var height:Number = separator.preferredHeight;
			var rowCount:int = gridDimensions.rowCount;
			var bounds:Rectangle = (rowIndex < rowCount) 
				? gridDimensions.getRowBounds(rowIndex)
				: gridDimensions.getPadRowBounds(rowIndex);
			
			if (!bounds)
				return;
			
			var x:Number = bounds.x;
			var width:Number = Math.max(bounds.width, visibleGridBounds.right);
			var y:Number = bounds.bottom; 
			layoutGridElement(separator, x, y, width, height);
		}
		
		private function layoutColumnSeparator(separator:IVisualElement, columnIndex:int):void
		{
			
			intializeGridVisualElement(separator, -1, columnIndex);
			
			var r:Rectangle = visibleItemRenderersBounds;
			var width:Number = separator.preferredWidth;
			var height:Number = Math.max(r.height, visibleGridBounds.height); 
			var x:Number = gridDimensions.getCellX(0, columnIndex) + gridDimensions.getColumnWidth(columnIndex); 
			var y:Number = r.y;
			layoutGridElement(separator, x, y, width, height);
		}
		private var visibleSelectionIndicators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
		private var visibleRowSelectionIndices:Vector.<int> = new Vector.<int>(0);    
		private var visibleColumnSelectionIndices:Vector.<int> = new Vector.<int>(0);
		
		private function isRowSelectionMode():Boolean
		{
			var mode:String = grid.selectionMode;
			return mode == GridSelectionMode.SINGLE_ROW || 
				mode == GridSelectionMode.MULTIPLE_ROWS;
		}
		
		private function isCellSelectionMode():Boolean
		{
			var mode:String = grid.selectionMode;        
			return mode == GridSelectionMode.SINGLE_CELL || 
				mode == GridSelectionMode.MULTIPLE_CELLS;
		}     
		
		private function layoutSelectionIndicators(layer:GridLayer):void
		{
			var selectionIndicatorFactory:Class = grid.selectionIndicator;
			if (isRowSelectionMode())
			{
				if (visibleColumnSelectionIndices.length > 0)
					clearSelectionIndicators();
				
				var oldVisibleRowSelectionIndices:Vector.<int> = visibleRowSelectionIndices;
				visibleRowSelectionIndices = new Vector.<int>();
				
				for each (var rowIndex:int in visibleRowIndices)
				{
					if (grid.selectionContainsIndex(rowIndex))
					{
						visibleRowSelectionIndices.push(rowIndex);
					}
				}
				visibleSelectionIndicators = layoutLinearElements(
					selectionIndicatorFactory,
					layer,
					visibleSelectionIndicators, 
					oldVisibleRowSelectionIndices, 
					visibleRowSelectionIndices, 
					layoutRowSelectionIndicator);
				
				return;
			}
			if (visibleRowSelectionIndices.length > 0 && 
				visibleColumnSelectionIndices.length == 0)
			{
				clearSelectionIndicators();
			}
			
			if (isCellSelectionMode())
			{
				oldVisibleRowSelectionIndices = visibleRowSelectionIndices;
				var oldVisibleColumnSelectionIndices:Vector.<int> = 
					visibleColumnSelectionIndices;
				visibleRowSelectionIndices = new Vector.<int>();
				visibleColumnSelectionIndices = new Vector.<int>();
				for each (rowIndex in visibleRowIndices)
				{
					for each (var columnIndex:int in visibleColumnIndices)
					{
						if (grid.selectionContainsCell(rowIndex, columnIndex))
						{
							visibleRowSelectionIndices.push(rowIndex);
							visibleColumnSelectionIndices.push(columnIndex);
						}
					}
				} 
				visibleSelectionIndicators = layoutCellElements(
					selectionIndicatorFactory,
					layer,
					visibleSelectionIndicators, 
					oldVisibleRowSelectionIndices, oldVisibleColumnSelectionIndices,
					visibleRowSelectionIndices, visibleColumnSelectionIndices,
					layoutCellSelectionIndicator);
				
				return;
			}
			if (visibleColumnSelectionIndices.length > 0)
				clearSelectionIndicators();
		}
		
		private function layoutRowSelectionIndicator(indicator:IVisualElement, rowIndex:int):void
		{
			
			intializeGridVisualElement(indicator, rowIndex);
			layoutGridElementR(indicator, gridDimensions.getRowBounds(rowIndex));
		}    
		
		private function layoutCellSelectionIndicator(indicator:IVisualElement, 
													  rowIndex:int,
													  columnIndex:int):void
		{
			
			intializeGridVisualElement(indicator, rowIndex, columnIndex);
			layoutGridElementR(indicator, gridDimensions.getCellBounds(rowIndex, columnIndex));
		}    
		
		private function clearSelectionIndicators():void
		{
			freeGridElements(visibleSelectionIndicators);
			visibleRowSelectionIndices.length = 0;
			visibleColumnSelectionIndices.length = 0;
		}
		private function layoutIndicator(
			layer:GridLayer,
			indicatorFactory:Class,
			indicator:IVisualElement, 
			rowIndex:int,
			columnIndex:int):IVisualElement
		{
			if (!layer)
				return null;
			if (indicator && (indicatorFactory != elementToFactoryMap[indicator]))
			{
				removeGridElement(indicator);
				indicator = null;
				if (indicatorFactory == null)
					return null;
			}
			
			if (rowIndex == -1 || grid.selectionMode == GridSelectionMode.NONE ||
				(isCellSelectionMode() && (grid.getNextVisibleColumnIndex(columnIndex - 1) != columnIndex)))
			{
				if (indicator)
					indicator.visible = false;
				return indicator;
			}
			
			if (!indicator && indicatorFactory)
				indicator = createGridElement(indicatorFactory);
			
			if (indicator)
			{
				var bounds:Rectangle = isRowSelectionMode() ? 
					gridDimensions.getRowBounds(rowIndex) :
					gridDimensions.getCellBounds(rowIndex, columnIndex);
				intializeGridVisualElement(indicator, rowIndex, columnIndex);
				if (indicatorFactory == grid.caretIndicator && bounds)
				{
					
					if (isCellSelectionMode() && (columnIndex < grid.columns.length - 1))
						bounds.width += 1;
					
					if ((rowIndex < grid.dataProvider.length - 1) || (visibleRowIndices.length > grid.dataProvider.length))
						bounds.height += 1;
				}
				
				layoutGridElementR(indicator, bounds);
				layer.addElement(indicator);
				indicator.visible = true;
			}
			
			return indicator;
		}
		
		private var mouseXOffset:Number = 0;
		private var mouseYOffset:Number = 0;
		
		private function layoutHoverIndicator(layer:GridLayer):void
		{        
			var rowIndex:int = grid.hoverRowIndex;
			var columnIndex:int = grid.hoverColumnIndex;
			var factory:Class = grid.hoverIndicator;
			hoverIndicator = layoutIndicator(layer, factory, hoverIndicator, rowIndex, columnIndex); 
		}
		
		private function layoutCaretIndicator(layer:GridLayer):void
		{
			var rowIndex:int = grid.caretRowIndex;
			var colIndex:int = grid.caretColumnIndex;
			var factory:Class = grid.caretIndicator; 
			caretIndicator = layoutIndicator(layer, factory, caretIndicator, rowIndex, colIndex);  
			if (caretIndicator && !_showCaret)
				caretIndicator.visible = _showCaret;
		}
		
		private function layoutEditorIndicator(layer:GridLayer):void
		{
			var dataGrid:DataGrid = grid.dataGrid;
			if (!dataGrid)
				return;
			
			var rowIndex:int = dataGrid.editorRowIndex;
			var columnIndex:int = dataGrid.editorColumnIndex;
			var indicatorFactory:Class = dataGrid.editorIndicator;
			if (editorIndicator && (indicatorFactory != elementToFactoryMap[editorIndicator]))
			{
				removeGridElement(editorIndicator);
				editorIndicator = null;
				if (indicatorFactory == null)
					return;
			}
			
			if (rowIndex == -1 || columnIndex == -1)
			{
				if (editorIndicator)
					editorIndicator.visible = false;
				return;
			}
			
			if (!editorIndicator && indicatorFactory)
				editorIndicator = createGridElement(indicatorFactory);
			
			if (editorIndicator)
			{
				var bounds:Rectangle = gridDimensions.getCellBounds(rowIndex, columnIndex);
				intializeGridVisualElement(editorIndicator, rowIndex, columnIndex);
				
				layoutGridElementR(editorIndicator, bounds);
				layer.addElement(editorIndicator);
				editorIndicator.visible = true;
			}
			
		}
		public function dataProviderCollectionChanged(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
				{
					dataProviderCollectionAdd(event);
					break;
				}
					
				case CollectionEventKind.REMOVE: 
				{
					dataProviderCollectionRemove(event);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					
					break;
				}
					
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
				{
					dataProviderCollectionReset(event);
					break;
				}
					
				case CollectionEventKind.UPDATE:
				{
					dataProviderCollectionUpdate(event);
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					break;
				}
			}
		}
		
		/**
		 * 当有一个或多个元素被插入到表格的数据源的时候，触发这个监听器。
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionAdd(event:CollectionEvent):void
		{
			var insertIndex:int = event.location;
			var insertLength:int = event.items.length;
			incrementIndicesGTE(visibleRowIndices, insertIndex, insertLength);
			incrementIndicesGTE(visibleRowSelectionIndices, insertIndex, insertLength);
		}
		
		/**
		 * 当有一个或多个想被移除出数据源的时候触发这个监听器。
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionRemove(event:CollectionEvent):void
		{
			var eventItemsLength:uint = event.items.length;
			var firstRemoveIndex:int = event.location;
			var lastRemoveIndex:int = event.location + event.items.length - 1;
			var firstVisibleOffset:int = -1; 
			var lastVisibleOffset:int = -1;  
			
			for (var offset:int = 0; offset < visibleRowIndices.length; offset++)
			{
				var rowIndex:int = visibleRowIndices[offset];
				if ((rowIndex >= firstRemoveIndex) && (rowIndex <= lastRemoveIndex))
				{
					if (firstVisibleOffset == -1)
						firstVisibleOffset = lastVisibleOffset = offset;
					else
						lastVisibleOffset = offset;
				}
				else if (rowIndex > lastRemoveIndex)
				{
					visibleRowIndices[offset] = rowIndex - eventItemsLength;
				}
			}
			if ((firstVisibleOffset != -1) && (lastVisibleOffset != -1))
			{
				var removeCount:int = (lastVisibleOffset - firstVisibleOffset) + 1; 
				visibleRowIndices.splice(firstVisibleOffset, removeCount);
				
				if (lastVisibleOffset < visibleRowBackgrounds.length)
					freeGridElements(visibleRowBackgrounds.splice(firstVisibleOffset, removeCount));
				
				if (lastVisibleOffset < visibleRowSeparators.length)
					freeGridElements(visibleRowSeparators.splice(firstVisibleOffset, removeCount));
				
				var visibleColCount:int = visibleColumnIndices.length;
				var firstRendererOffset:int = firstVisibleOffset * visibleColCount;
				freeItemRenderers(visibleItemRenderers.splice(firstRendererOffset, removeCount * visibleColCount));
			}
		}    
		
		private function incrementIndicesGTE(indices:Vector.<int>, insertIndex:int, delta:int):void
		{
			var indicesLength:int = indices.length;
			for (var i:int = 0; i < indicesLength; i++)
			{
				var index:int = indices[i];
				if (index >= insertIndex)
				{
					indices[i] = index + delta;
				}
			}
		}
		/**
		 *  CollectionEvent的刷新或重置将触发这个监听器。
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionReset(event:CollectionEvent):void
		{
			clearVirtualLayoutCache();
		}
		/**
		 * 当数据源的项被更新的时候触发这个监听器。
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionUpdate(event:CollectionEvent):void
		{
			var data:Object;
			var itemsLength:int = event.items.length;
			var itemRenderersLength:int = visibleItemRenderers.length;
			
			for (var i:int = 0; i < itemsLength; i++)
			{
				data = event.items[i];
				
				for (var j:int = 0; j < itemRenderersLength; j++)
				{
					var renderer:IGridItemRenderer = visibleItemRenderers[j] as IGridItemRenderer;
					if (renderer && renderer.data == data)
					{
						this.freeItemRenderer(renderer);
						visibleItemRenderers[j] = null;
					}
				}
			}
		}
		/**
		 * GridDimension的对象被更新的时候触发这个
		 * @param event
		 * 
		 */		
		public function columnsCollectionChanged(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case CollectionEventKind.UPDATE:
				{
					clearVirtualLayoutCache();
					break;
				}
					
				default:
				{
					clearVirtualLayoutCache();
					if (grid)
						grid.setContentSize(0, 0);
					break;
				}
			}
		}
		/**
		 * 让allocateGridElement()知道返回的元素是回收利用的还是被创建的
		 */		
		private var createdGridElement:Boolean = false;
		
		private function createGridElement(factory:Class):IVisualElement
		{
			createdGridElement = true;
			var element:IVisualElement = new factory() as IVisualElement;
			elementToFactoryMap[element] = factory;
			return element;
		}
		/**
		 * 返回一个 元素，创建或者回收利用
		 * @param factory
		 * @return 
		 * 
		 */		
		private function allocateGridElement(factory:Class):IVisualElement
		{
			createdGridElement = false;
			var elements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
			if (elements)
			{
				var element:IVisualElement = elements.pop();
				if (elements.length == 0)
					delete freeElementMap[factory];
				if (element)
					return element;
			}
			
			return createGridElement(factory);
		}
		/**
		 * 释放一个元素到回收池 
		 * @param element
		 * @return 
		 * 
		 */		
		private function freeGridElement(element:IVisualElement):Boolean
		{
			if (!element)
				return false;
			
			element.visible = false;
			
			var factory:Class = elementToFactoryMap[element]; 
			if (!factory)
				return false;
			var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
			if (!freeElements)
			{
				freeElements = new Vector.<IVisualElement>();
				freeElementMap[factory] = freeElements;            
			}
			freeElements.push(element);
			
			return true;
		}
		
		private function freeGridElements(elements:Vector.<IVisualElement>):void
		{
			for each (var elt:IVisualElement in elements)
			freeGridElement(elt);
			elements.length = 0;
		}
		/**
		 * 从 elementToFactory表虫移除一个元素，从工厂列表中移除，最终从它的容器中移除。
		 * @param element
		 * 
		 */		
		private function removeGridElement(element:IVisualElement):void
		{
			var factory:Class = elementToFactoryMap[element];
			var freeElements:Vector.<IVisualElement> = (factory) ? freeElementMap[factory] : null;
			if (freeElements)
			{
				var index:int = freeElements.indexOf(element);
				if (index != -1)
					freeElements.splice(index, 1);
				if (freeElements.length == 0)
					delete freeElementMap[factory];      
			}
			
			delete elementToFactoryMap[element];
			
			element.visible = false;
			var parent:IVisualElementContainer = element.parent as IVisualElementContainer;
			if (parent)
				parent.removeElement(element);
		}
		private function layoutItemRenderer(renderer:IGridItemRenderer, x:Number, y:Number, width:Number, height:Number):void
		{
			var startTime:Number;
			if (enablePerformanceStatistics)
				startTime = getTimer();
			
			if (!isNaN(width) || !isNaN(height))
			{
				if (renderer is ILayoutManagerClient) 
				{
					var validateClientRenderer:ILayoutManagerClient = renderer as ILayoutManagerClient;                
					UIGlobals.layoutManager.validateClient(validateClientRenderer, true); 
				}
				
				renderer.setLayoutBoundsSize(width, height);            
			}
			
			if ((renderer is IInvalidating))
			{
				var validateNowRenderer:IInvalidating = renderer as IInvalidating;
				validateNowRenderer.validateNow();            
			}
			
			renderer.setLayoutBoundsPosition(x, y);
			
			if (enablePerformanceStatistics)
			{
				var elapsedTime:Number = getTimer() - startTime;
				performanceStatistics.layoutGridElementTimes.push(elapsedTime);            
			}
		}
		
		private function layoutGridElementR(elt:IVisualElement, bounds:Rectangle):void
		{
			if (bounds)
				layoutGridElement(elt, bounds.x, bounds.y, bounds.width, bounds.height);
		}
		
		private static var MAX_ELEMENT_SIZE:Number = 8192;
		private static var ELEMENT_EDGE_PAD:Number = 512;
		
		/**
		 * 查看虚拟元素的布局尺寸和位置
		 * 
		 * 尝试渲染比最大尺寸还大的元素
		 * @param elt
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * 
		 */		
		private function layoutGridElement(elt:IVisualElement, x:Number, y:Number, width:Number, height:Number):void
		{   
			if (width > MAX_ELEMENT_SIZE)
			{
				var scrollX:Number = Math.max(0, horizontalScrollPosition);
				var gridWidth:Number = grid.layoutBoundsWidth;
				
				var newX:Number = Math.max(x, scrollX - ELEMENT_EDGE_PAD);
				var newRight:Number = Math.min(x + width, scrollX + gridWidth + ELEMENT_EDGE_PAD);
				
				x = newX;
				width = newRight - newX;
			}
			
			if (height > MAX_ELEMENT_SIZE)
			{
				var scrollY:Number = Math.max(0, verticalScrollPosition);
				var gridHeight:Number = grid.layoutBoundsHeight;
				
				var newY:Number = Math.max(y, scrollY - ELEMENT_EDGE_PAD);
				var newBottom:Number = Math.min(y + height, scrollY + gridHeight + ELEMENT_EDGE_PAD);
				
				y = newY;
				height = newBottom - newY;
			}
			
			elt.setLayoutBoundsSize(width, height);
			elt.setLayoutBoundsPosition(x, y);
		}
		/**
		 * 调用 IGridVisualElement元素上的prepareGridVisualElement()
		 * @param elt
		 * @param rowIndex
		 * @param columnIndex
		 * 
		 */		
		private function intializeGridVisualElement(elt:IVisualElement, rowIndex:int = -1, columnIndex:int = -1):void
		{
			var gridVisualElement:IGridVisualElement = elt as IGridVisualElement;
			if (gridVisualElement)
			{
				gridVisualElement.prepareGridVisualElement(grid, rowIndex, columnIndex);
			}
		}
		public function getVisibleRowIndices():Vector.<int>
		{
			return visibleRowIndices.concat();
		}
		public function getVisibleColumnIndices():Vector.<int>
		{
			return visibleColumnIndices.concat();
		}
		public function getCellBounds(rowIndex:int, columnIndex:int):Rectangle
		{
			return gridDimensions.getCellBounds(rowIndex, columnIndex);
		}
		public function getRowBounds(rowIndex:int):Rectangle
		{
			return gridDimensions.getRowBounds(rowIndex);        
		}
		public function getColumnBounds(columnIndex:int):Rectangle
		{
			return gridDimensions.getColumnBounds(columnIndex); 
		}
		public function getRowIndexAt(x:Number, y:Number):int
		{
			return gridDimensions.getRowIndexAt(x, y); 
		}
		public function getColumnIndexAt(x:Number, y:Number):int
		{
			return gridDimensions.getColumnIndexAt(x, y); 
		}
		public function getCellAt(x:Number, y:Number):CellPosition
		{
			var rowIndex:int = gridDimensions.getRowIndexAt(x, y);
			var columnIndex:int = gridDimensions.getColumnIndexAt(x, y);
			if ((rowIndex == -1) || (columnIndex == -1))
				return null;
			return new CellPosition(rowIndex, columnIndex);
		}
		public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
		{ 
			var cells:Vector.<CellPosition> = new Vector.<CellPosition>;
			
			if (w <= 0 || h <= 0)
				return cells;
			var topLeft:CellPosition = getCellAt(x, y);
			var bottomRight:CellPosition = getCellAt(x + w, y + h);
			if (!topLeft || !bottomRight)
				return cells;
			
			for (var rowIndex:int = topLeft.rowIndex; 
				rowIndex <= bottomRight.rowIndex; rowIndex++)
			{
				for (var columnIndex:int = topLeft.columnIndex; 
					columnIndex <= bottomRight.columnIndex; columnIndex++)
				{
					cells.push(new CellPosition(rowIndex, columnIndex));
				}
			}
			
			return cells;
		}
		public function getItemRendererAt(rowIndex:int, columnIndex:int):IGridItemRenderer
		{
			var visibleItemRenderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
			if (visibleItemRenderer)
				return visibleItemRenderer;
			
			var rendererLayer:GridLayer = getLayer("rendererLayer");
			if (!rendererLayer)
				return null;
			var dataItem:Object = getDataProviderItem(rowIndex);
			var column:GridColumn = getGridColumn(columnIndex);
			if (dataItem == null || column == null)
				return null;
			if (!column.visible)
				return null;
			
			var factory:Class = itemToRenderer(column, dataItem);
			var renderer:IGridItemRenderer = new factory() as IGridItemRenderer;
			createdGridElement = true;  
			
			rendererLayer.addElement(renderer);
			
			initializeItemRenderer(renderer, rowIndex, columnIndex, dataItem, false);
			var bounds:Rectangle = gridDimensions.getCellBounds(rowIndex, columnIndex);
			if (bounds == null)
				return null;
			layoutItemRenderer(renderer, bounds.x, bounds.y, bounds.width, bounds.height);
			
			rendererLayer.removeElement(renderer);
			renderer.visible = false;
			
			return renderer;
		}
		public function isCellVisible(rowIndex:int, columnIndex:int):Boolean
		{
			if (rowIndex == -1 && columnIndex == -1)
				return false;
			
			return ((rowIndex == -1) || (visibleRowIndices.indexOf(rowIndex) != -1)) && 
				((columnIndex == -1) || (visibleColumnIndices.indexOf(columnIndex) != -1));
		}
		private var _performanceStatistics:Object = null;
		public function get performanceStatistics():Object
		{
			return _performanceStatistics;
		}
		private var _enablePerformanceStatistics:Boolean = false;
		public function get enablePerformanceStatistics():Boolean
		{
			return _enablePerformanceStatistics;
		}
		public function set enablePerformanceStatistics(value:Boolean):void
		{
			if (value == _enablePerformanceStatistics)
				return;
			
			if (value)
				_performanceStatistics = {
					updateDisplayListTimes: new Vector.<Number>(),
					updateDisplayListRectangles: new Vector.<Rectangle>(),
					updateDisplayListCellCounts: new Vector.<int>(),                
					measureTimes: new Vector.<Number>(),             
					layoutGridElementTimes: new Vector.<Number>()                
				};
			
			_enablePerformanceStatistics = value;
		}
		
	}
}
