package egret.components.gridClasses
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import egret.collections.ICollection;
	import egret.components.DataGrid;
	import egret.components.Grid;
	import egret.components.GridColumnHeaderGroup;
	import egret.components.Group;
	import egret.components.supportClasses.GroupBase;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.layouts.supportClasses.LayoutBase;
	
	use namespace ns_egret;
	
	[ExcludeClass]
	
	/**
	 * <p>给GridColumnHeaderGroup用的水平虚拟布局， 这个不是一般的布局，这个布局只给GridColumnHeaderGroup用。</p>
	 * <p>这个布局得到的测量宽度永远为0，columnHeaderGroup只能得到测量高度</p>
	 */	
	public class GridColumnHeaderGroupLayout extends LayoutBase
	{
		public function GridColumnHeaderGroupLayout()
		{
			super();
		}
		
		/**
		 * 给表头和 分割线渲染用的层
		 */		
		private var rendererLayer:Group;
		
		private var overlayLayer:Group;
		
		/**
		 * 缓存表头的测量高度和内容高度 
		 */		
		private var rendererHeights:Array = new Array();
		
		private var maxRendererHeight:Number = 0;
		
		/**
		 * 当前表头的可见范围 
		 */		
		private var visibleRenderersBounds:Rectangle = new Rectangle();
		
		/**
		 * 当前可见的表头渲染器
		 */		
		private var visibleHeaderRenderers:Vector.<IGridItemRenderer> = new Vector.<IGridItemRenderer>();
		
		/**
		 * 当前可见的表头的分割线
		 */		
		private var visibleHeaderSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>();
		
		/**
		 * 可重用元素字典表
		 */		
		private var freeElementMap:Dictionary = new Dictionary();
		
		/**
		 * 记录渲染器工厂，以便freeElementMap()可以再次找到它
		 */		
		private var elementToFactoryMap:Dictionary = new Dictionary();
		
		override public function set target(value:GroupBase):void
		{
			super.target = value;
			
			var chg:GridColumnHeaderGroup = value as GridColumnHeaderGroup;
			
			if (chg)
			{
				
				rendererLayer = new Group();
				rendererLayer.layout = new LayoutBase();
				chg.addElement(rendererLayer);
				
				overlayLayer = new Group();
				overlayLayer.layout = new LayoutBase();
				chg.addElement(overlayLayer);
			}
		}
		override public function get useVirtualLayout():Boolean
		{
			return true;
		}
		override public function set useVirtualLayout(value:Boolean):void
		{
		}
		/**
		 * 清空所有 
		 * 
		 */		
		override public function clearVirtualLayoutCache():void
		{
			rendererHeights.length = 0;
			visibleHeaderRenderers.length = 0;
			visibleHeaderSeparators.length = 0;
			visibleRenderersBounds.setEmpty();
			elementToFactoryMap = new Dictionary();
			freeElementMap = new Dictionary();
			if (rendererLayer)
				rendererLayer.removeAllElements();
			if (overlayLayer)
				overlayLayer.removeAllElements();
		}     
		override protected function scrollPositionChanged():void
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			if (!columnHeaderGroup)
				return;
			
			super.scrollPositionChanged();  
			var scrollR:Rectangle = columnHeaderGroup.scrollRect;
			if (scrollR && !visibleRenderersBounds.containsRect(scrollR))
				columnHeaderGroup.invalidateDisplayList();
		}    
		override public function measure():void
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			
			if (!columnHeaderGroup || !grid)
				return;
			
			updateRendererHeights();
			
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var paddingRight:Number = columnHeaderGroup.paddingRight;
			var paddingTop:Number = columnHeaderGroup.paddingTop;
			var paddingBottom:Number = columnHeaderGroup.paddingBottom;
			
			var measuredWidth:Number = Math.ceil(paddingLeft + paddingRight);
			var measuredHeight:Number = Math.ceil(maxRendererHeight + paddingTop + paddingBottom);
			
			columnHeaderGroup.measuredWidth = Math.max(measuredWidth, columnHeaderGroup.minWidth);
			columnHeaderGroup.measuredHeight = Math.max(measuredHeight, columnHeaderGroup.minHeight);
		}
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			
			if (!columnHeaderGroup || !grid)
				return;
			
			var visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
			var oldRenderers:Array = [];
			var rendererLayer:Group = this.rendererLayer;
			var overlayLayer:Group = this.overlayLayer;
			var columnSeparatorFactory:Class = columnHeaderGroup.columnSeparator;
			
			var renderer:IGridItemRenderer;
			var separator:IVisualElement;
			var column:GridColumn;
			var columnIndex:int = -1;
			for each (renderer in visibleHeaderRenderers)
			{
				column = renderer.column;
				columnIndex = (column) ? column.columnIndex : -1;
				
				if ((columnIndex != -1) && (visibleColumnIndices.indexOf(columnIndex) != -1) &&
					(oldRenderers[columnIndex] == null))
				{
					oldRenderers[columnIndex] = renderer;
				}
				else
				{
					freeVisualElement(renderer);
					renderer.discard(true);
				}
			}
			visibleHeaderRenderers.length = 0;
			for each (separator in visibleHeaderSeparators)
			{
				freeVisualElement(separator);
			}
			visibleHeaderSeparators.length = 0;
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var paddingRight:Number = columnHeaderGroup.paddingRight;
			var paddingTop:Number = columnHeaderGroup.paddingTop;
			var paddingBottom:Number = columnHeaderGroup.paddingBottom;
			
			var columns:ICollection = this.columns;
			var columnsLength:int = (columns) ? columns.length : 0;
			var lastVisibleColumnIndex:int = grid.getPreviousVisibleColumnIndex(columnsLength);
			var rendererY:Number = paddingTop;
			var rendererHeight:Number = unscaledHeight - paddingTop - paddingBottom;
			var maxRendererX:Number = columnHeaderGroup.horizontalScrollPosition + unscaledWidth;
			
			var visibleLeft:Number = 0;
			var visibleRight:Number = 0;
			for (var index:int = 0; ; index++)
			{
				if (index < visibleColumnIndices.length)
					columnIndex = visibleColumnIndices[index];
				else
					columnIndex = grid.getNextVisibleColumnIndex(columnIndex);
				
				if (columnIndex < 0 || columnIndex >= columnsLength)
					break;
				
				column = columns.getItemAt(columnIndex) as GridColumn;
				renderer = oldRenderers[columnIndex];
				oldRenderers[columnIndex] = null;
				if (!renderer)
				{
					var factory:Class = column.headerRenderer;
					if (!factory)
						factory = columnHeaderGroup.headerRenderer;
					renderer = allocateVisualElement(factory) as IGridItemRenderer;
				}
				visibleHeaderRenderers.push(renderer);
				initializeItemRenderer(renderer, columnIndex, column, true);
				if (renderer.parent != rendererLayer)
					rendererLayer.addElement(renderer);
				var isLastColumn:Boolean = columnIndex == lastVisibleColumnIndex;
				var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
				var rendererWidth:Number = grid.getColumnWidth(columnIndex);
				
				if (isLastColumn)
					rendererWidth = horizontalScrollPosition + unscaledWidth - rendererX - paddingRight;
				
				renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
				renderer.setLayoutBoundsPosition(rendererX, rendererY);
				
				if (index == 0)
					visibleLeft = rendererX;
				visibleRight = rendererX + rendererWidth;
				
				renderer.prepare(!createdVisualElement);
				
				if ((rendererX + rendererWidth) > maxRendererX)
					break;
				if (columnSeparatorFactory && !isLastColumn)
				{
					separator = allocateVisualElement(columnSeparatorFactory);
					visibleHeaderSeparators.push(separator);
					separator.visible = true;
					if (separator.parent != overlayLayer)
						overlayLayer.addElement(separator);
					
					var separatorWidth:Number = separator.preferredWidth;
					var separatorX:Number = rendererX + rendererWidth;
					separator.setLayoutBoundsSize(separatorWidth, rendererHeight);
					separator.setLayoutBoundsPosition(separatorX, rendererY);
				}
			}
			
			columnHeaderGroup.setContentSize(grid.contentWidth, rendererHeight);
			
			visibleRenderersBounds.left = visibleLeft - paddingLeft;
			visibleRenderersBounds.right = visibleRight = paddingRight;
			visibleRenderersBounds.top = rendererY - paddingTop;
			visibleRenderersBounds.height = rendererHeight + paddingTop + paddingBottom;
			columnHeaderGroup.validateNow();
			updateRendererHeights(true);
		}
		/**
		 * 通过位置得到列索引
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		public function getHeaderIndexAt(x:Number, y:Number):int
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			var columns:ICollection = this.columns;
			
			if (!columnHeaderGroup || !grid || !columns)
				return -1; 
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var paddingRight:Number = columnHeaderGroup.paddingRight;
			var paddedX:Number = x + paddingLeft;
			var columnIndex:int = grid.getColumnIndexAt(paddedX, 0);
			if (columnIndex < 0)
			{
				var contentWidth:Number = columnHeaderGroup.contentWidth;
				var totalWidth:Number = horizontalScrollPosition + columnHeaderGroup.width - paddingRight;
				if (paddedX >= contentWidth && paddedX < totalWidth)
					columnIndex = grid.getPreviousVisibleColumnIndex(columns.length)
			}
			
			return columnIndex;
		}
		/**
		 * 通过位置得到分割线索引
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		public function getSeparatorIndexAt(x:Number, y:Number):int
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			var columns:ICollection = this.columns;
			
			if (!columnHeaderGroup || !grid || !columns)
				return -1; 
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var columnIndex:int = grid.getColumnIndexAt(x + paddingLeft, 0);
			
			if (columnIndex == -1)
				return -1;
			
			var isFirstColumn:Boolean = columnIndex == grid.getNextVisibleColumnIndex(-1);
			var isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columns.length);
			
			var columnLeft:Number = grid.getCellX(0, columnIndex);
			var columnRight:Number = columnLeft + grid.getColumnWidth(columnIndex);
			var smw:Number = columnHeaderGroup.separatorAffordance;
			
			if (!isFirstColumn && (x > (columnLeft - smw)) && (x < (columnLeft + smw)))
				return grid.getPreviousVisibleColumnIndex(columnIndex);
			
			if (!isLastColumn && (x > (columnRight - smw)) && (x < columnRight + smw))
				return columnIndex;
			
			return -1;
		}
		
		/**
		 * 得到表头的可见范围，单位像素。
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function getHeaderBounds(columnIndex:int):Rectangle
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			
			if (!columnHeaderGroup || !grid)
				return null;
			
			var columns:ICollection = this.columns;
			var columnsLength:int = (columns) ? columns.length : 0;
			
			if (columnIndex >= columnsLength)
				return null;
			
			var column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
			if (!column.visible)
				return null;
			
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var paddingRight:Number = columnHeaderGroup.paddingRight;
			var paddingTop:Number = columnHeaderGroup.paddingTop;
			var paddingBottom:Number = columnHeaderGroup.paddingBottom;
			
			var isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columnsLength);
			var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
			var rendererY:Number = paddingTop;
			var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
			var rendererHeight:Number = columnHeaderGroup.height - paddingTop - paddingBottom;        
			
			if (isLastColumn)
				rendererWidth = horizontalScrollPosition + columnHeaderGroup.width - rendererX - paddingRight;
			
			return new Rectangle(rendererX, rendererY, rendererWidth, rendererHeight);
		}
		
		/**
		 * 如果指定的头渲染器可见，则返回当前的渲染器
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
		{
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			var grid:Grid = this.grid;
			
			if (!columnHeaderGroup || !grid || (columnIndex < 0))
				return null;
			var rendererLayer:Group = this.rendererLayer;
			var visibleColumnIndices:Vector.<int> = grid.getVisibleColumnIndices();
			var eltIndex:int = visibleColumnIndices.indexOf(columnIndex);
			if (eltIndex != -1)
			{
				var rendererLayerNumElements:int = rendererLayer.numElements;
				for (var index:int = 0; index < rendererLayerNumElements; index++)
				{
					var elt:IGridItemRenderer = rendererLayer.getElementAt(index) as IGridItemRenderer;
					if (elt && elt.visible && elt.column && (elt.column.columnIndex == columnIndex))
						return elt;
				}
				return null;
			}
			var columns:ICollection = this.columns;
			if (!columns || (columns.length <= columnIndex))
				return null;
			var column:GridColumn = columns.getItemAt(columnIndex) as GridColumn;
			if (!column.visible)
				return null;
			
			var factory:Class = column.headerRenderer;
			if (!factory)
				factory = columnHeaderGroup.headerRenderer;
			var renderer:IGridItemRenderer = allocateVisualElement(factory) as IGridItemRenderer;
			
			rendererLayer.addElement(renderer);
			initializeItemRenderer(renderer, columnIndex, column, renderer.visible);
			var paddingLeft:Number = columnHeaderGroup.paddingLeft;
			var paddingRight:Number = columnHeaderGroup.paddingRight;
			var paddingTop:Number = columnHeaderGroup.paddingTop;
			var paddingBottom:Number = columnHeaderGroup.paddingBottom;
			
			var isLastColumn:Boolean = columnIndex == grid.getPreviousVisibleColumnIndex(columns.length);
			var rendererX:Number = grid.getCellX(0, columnIndex) + paddingLeft;
			var rendererY:Number = paddingTop;
			var rendererHeight:Number = columnHeaderGroup.height - paddingTop - paddingBottom;
			var rendererWidth:Number = grid.getColumnWidth(columnIndex); 
			
			if (isLastColumn)
				rendererWidth = horizontalScrollPosition + columnHeaderGroup.width - rendererX - paddingRight;
			
			renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
			renderer.setLayoutBoundsPosition(rendererX, rendererY);
			
			rendererLayer.removeElement(renderer);
			renderer.visible = false;
			
			return renderer;
		}
		private function initializeItemRenderer(renderer:IGridItemRenderer,
												columnIndex:int,
												column:GridColumn,
												visible:Boolean=true):void
		{
			renderer.visible = visible;
			renderer.column = column;
			renderer.label = column.headerText;
			
			var columnHeaderGroup:GridColumnHeaderGroup = this.columnHeaderGroup;
			
			var dataGrid:DataGrid = columnHeaderGroup.dataGrid;
			if (dataGrid)
				renderer.ownerChanged(dataGrid);
			
			renderer.hovered = columnIndex == columnHeaderGroup.hoverColumnIndex;
			renderer.down = columnIndex == columnHeaderGroup.downColumnIndex;
		}
		/**
		 *  让allocateGridElement()得知返回的元素是被创建的还是回收重用的。
		 */		
		private var createdVisualElement:Boolean = false;
		private function createVisualElement(factory:Class):IVisualElement
		{
			createdVisualElement = true;
			var newElement:IVisualElement = new factory() as IVisualElement;
			elementToFactoryMap[newElement] = factory;
			return newElement;
		}
		/**
		 *  从回收池里得到某个元素否则创建一个新的
		 * @param factory
		 * @return 
		 * 
		 */		
		private function allocateVisualElement(factory:Class):IVisualElement
		{
			createdVisualElement = false;
			var freeElements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
			if (freeElements)
			{
				var freeElement:IVisualElement = freeElements.pop();
				if (freeElements.length == 0)
					delete freeElementMap[factory];
				if (freeElement)
					return freeElement;
			}
			
			return createVisualElement(factory);
		}
		
		/**
		 * 把一个元素扔进回收池 
		 * @param element
		 * 
		 */		
		private function freeVisualElement(element:IVisualElement):void
		{
			var factory:Class = elementToFactoryMap[element];
			
			var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
			if (!freeElements)
			{
				freeElements = new Vector.<IVisualElement>();
				freeElementMap[factory] = freeElements;
			}
			freeElements.push(element);
			
			element.visible = false;
		}
		/**
		 * 更新渲染器的高度缓存和当前最大的渲染器高度。
		 * 如果最大高度改变了，则初始化目标的尺寸。
		 * @param inUpdateDisplayList
		 * 
		 */		
		private function updateRendererHeights(inUpdateDisplayList:Boolean = false):void
		{
			var columns:ICollection = this.columns;
			rendererHeights.length = (columns) ? columns.length : 0;
			
			var newHeight:Number = 0;
			for each (var renderer:IGridItemRenderer in visibleHeaderRenderers)
			{
				var preferredHeight:Number = renderer.preferredHeight;
				rendererHeights[renderer.column.columnIndex] = preferredHeight;
				if (preferredHeight > newHeight)
					newHeight = preferredHeight;
			}
			if (newHeight == maxRendererHeight)
				return;
			
			if (newHeight < maxRendererHeight)
			{
				for (var i:int = 0; i < rendererHeights.length; i++)
				{
					var rendererHeight:Number = rendererHeights[i];
					if (!isNaN(rendererHeight) && rendererHeight > newHeight)
						newHeight = rendererHeight;
				}
			}
			
			maxRendererHeight = newHeight;
			
			if (inUpdateDisplayList)
				columnHeaderGroup.invalidateSize();
		}
		private function get columnHeaderGroup():GridColumnHeaderGroup
		{
			return target as GridColumnHeaderGroup;
		}
		private function get grid():Grid
		{
			var chg:GridColumnHeaderGroup = this.columnHeaderGroup;
			if (chg.dataGrid)
				return chg.dataGrid.grid;
			
			return null;
		}
		private var _columns:ICollection;
		
		/**
		 * 当前数据包的columns的列表，一个本地的参数，用于确保当列变化了，的时候移除掉他们的事件监听器
		 * @return 
		 * 
		 */		
		private function get columns():ICollection
		{
			var grid:Grid = this.grid;
			var newColumns:ICollection = (grid) ? grid.columns : null;
			
			if (newColumns != _columns)
			{
				if (_columns)
					_columns.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
				
				_columns = newColumns;
				
				if (_columns)
					_columns.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
			}
			
			return _columns;
		}
		
		/**
		 * columns改变的时候触发这个监听器，用于改变排序显示等
		 * @param event
		 * 
		 */			
		private function columns_collectionChangeHandler(event:CollectionEvent):void
		{
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					columns_collectionChangeAdd(event);
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					columns_collectionChangeRemove(event);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					columns_collectionChangeMove(event);
					break;
				}
					
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
				{
					
					break;
				}
					
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
				{
					columnHeaderGroup.visibleSortIndicatorIndices = null;
					break;
				}                
			}
		}
		/**
		 * 当列被添加的时候，根据正确的列调整GridColumnHeaderGroup的visibleSortIndicatorIndices属性
		 * @param event
		 * 
		 */		
		private function columns_collectionChangeAdd(event:CollectionEvent):void
		{   
			var itemsLength:int = event.items.length;
			if (itemsLength <= 0)
				return;
			
			var chg:GridColumnHeaderGroup = columnHeaderGroup;
			var indices:Vector.<int> = chg.visibleSortIndicatorIndices;
			var indicesLength:int = indices.length;
			var startIndex:int = event.location;
			
			for (var i:int = 0; i < indicesLength; i++)
			{
				if (indices[i] >= startIndex)
					indices[i] += itemsLength;
			}
			chg.visibleSortIndicatorIndices = indices;
		}
		
		/**
		 * 当列被移除的时候，根据正确的列调整GridColumnHeaderGroup的visibleSortIndicatorIndices属性
		 * @param event
		 * 
		 */	
		private function columns_collectionChangeRemove(event:CollectionEvent):void
		{
			var itemsLength:int = event.items.length;
			if (itemsLength <= 0)
				return;
			
			var chg:GridColumnHeaderGroup = columnHeaderGroup;
			var indices:Vector.<int> = chg.visibleSortIndicatorIndices;
			var indicesLength:int = indices.length;
			var startIndex:int = event.location;
			var lastIndex:int = startIndex + itemsLength;
			var newIndices:Vector.<int> = new Vector.<int>();
			var index:int;
			
			for each (index in indices)
			{
				if (index < startIndex)
					newIndices.push(index);
				else if (index >= lastIndex)
					newIndices.push(index - lastIndex);
			}
			chg.visibleSortIndicatorIndices = newIndices;
		}
		
		/**
		 * 当列被改变的时候，根据正确的列调整GridColumnHeaderGroup的visibleSortIndicatorIndices属性
		 * @param event
		 * 
		 */	
		private function columns_collectionChangeMove(event:CollectionEvent):void
		{
			var itemsLength:int = event.items.length;
			if (itemsLength <= 0)
				return;
			
			var chg:GridColumnHeaderGroup = columnHeaderGroup;
			var indices:Vector.<int> = chg.visibleSortIndicatorIndices;
			var indicesLength:int = indices.length;
			var oldStart:int = event.oldLocation;
			var oldEnd:int = event.oldLocation + itemsLength;
			var newStart:int = event.location;
			var newEnd:int = event.location + itemsLength;
			var index:int;
			
			for (var i:int = 0; i < indicesLength; i++)
			{
				index = indices[i];
				
				if (index >= oldStart && index < oldEnd)
				{
					
					indices[i] = newStart + (index - oldStart);
					continue;
				}
				if (newStart > oldStart)
				{
					if (index >= oldEnd && index < newEnd)
						indices[i] -= itemsLength;
				}
				else if (newStart < oldStart)
				{
					if (index >= newStart && index < oldStart)
						indices[i] += itemsLength;
				}
			}
			chg.visibleSortIndicatorIndices = indices;
		}
	}
}