package egret.components
{ 
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import egret.collections.ICollection;
	import egret.components.gridClasses.GridColumn;
	import egret.components.gridClasses.GridColumnHeaderGroupLayout;
	import egret.components.gridClasses.IDataGridElement;
	import egret.components.gridClasses.IGridItemRenderer;
	import egret.events.GridEvent;
	import egret.events.PropertyChangeEvent;
	import egret.utils.MouseEventUtil;
	
	/**
	 * 表格鼠标按下 
	 */	
	[Event(name="gridMouseDown", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标拖拽
	 */	
	[Event(name="gridMouseDrag", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标松起
	 */	
	[Event(name="gridMouseUp", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标移入
	 */	
	[Event(name="gridRollOver", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标移出
	 */	
	[Event(name="gridRollOut", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标点击
	 */	
	[Event(name="gridClick", type="egret.events.GridEvent")]
	/**
	 * 表格鼠标双击
	 */	
	[Event(name="gridDoubleClick", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标拖拽
	 */	
	[Event(name="separatorMouseDrag", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标松起
	 */	
	[Event(name="separatorMouseUp", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标移入
	 */	
	[Event(name="separatorRollOver", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标移出
	 */	
	[Event(name="separatorRollOut", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标点击
	 */	
	[Event(name="separatorClick", type="egret.events.GridEvent")]
	/**
	 * 分割线鼠标双击
	 */	
	[Event(name="separatorDoubleClick", type="egret.events.GridEvent")]

	/**
	 * GridColumnHeaderGroup 类显示与网格布局对齐的一行列标题和分隔符。 
	 * <p>标题由类（由 headerRenderer 属性指定）呈示。分隔符由类（由 columnSeparator 属性指定）
	 * 呈示。无法更改的布局是虚拟的，这说明将重用已可视范围内滚动出的呈示器和分隔符。</p>
	 * 
	 */	
	public class GridColumnHeaderGroup extends Group implements IDataGridElement
	{
		/**
		 * 构造函数。 
		 */		
		public function GridColumnHeaderGroup()
		{
			super();
			
			layout = new GridColumnHeaderGroupLayout();
			layout.clipAndEnableScrolling = true;
			MouseEventUtil.addDownDragUpListeners(this, 
				gchg_mouseDownDragUpHandler, 
				gchg_mouseDownDragUpHandler, 
				gchg_mouseDownDragUpHandler);
			
			addEventListener(MouseEvent.MOUSE_MOVE, gchg_mouseMoveHandler);
			addEventListener(MouseEvent.ROLL_OUT, gchg_mouseRollOutHandler);
			addEventListener(MouseEvent.CLICK, gchg_clickHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK, gchg_doubleClickHandler);
		}
		
		
		private var _paddingLeft:Number = 0;
		/**
		 * 容器的左边缘与布局元素的左边缘之间的最少像素数,若为NaN将使用padding的值，默认值：0。
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
			invalidateSize();
			invalidateDisplayList();
		}    
		
		private var _paddingRight:Number = 0;
		/**
		 * 容器的右边缘与布局元素的右边缘之间的最少像素数,若为NaN将使用padding的值，默认值：0。
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
			invalidateSize();
			invalidateDisplayList();
		}    
		
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
		}   
		
		private var _separatorAffordance:Number = 5;

		public function get separatorAffordance():Number
		{
			return _separatorAffordance;
		}

		public function set separatorAffordance(value:Number):void
		{
			_separatorAffordance = value;
		}

		
		private function dispatchChangeEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new Event(type));
		}    
		private var _columnSeparator:Class = null;
		/**
		 *  显示在各列之间的可视元素。
		 */		
		public function get columnSeparator():Class
		{
			return _columnSeparator;
		}
		public function set columnSeparator(value:Class):void
		{
			if (_columnSeparator == value)
				return;
			
			_columnSeparator = value;
			invalidateDisplayList();
			dispatchChangeEvent("columnSeparatorChanged");
		}
		private var _dataGrid:DataGrid = null;
		/**
		 *  定义此组件的列布局和水平滚动位置的 DataGrid 控件。已添加 DataGrid 的 grid 外观部件之后由 DataGrid 控件设置此属性。
		 */		
		public function get dataGrid():DataGrid
		{
			return _dataGrid;
		}
		public function set dataGrid(value:DataGrid):void
		{
			if (_dataGrid == value)
				return;
			
			if (_dataGrid && _dataGrid.grid)
				_dataGrid.grid.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);
			
			_dataGrid = value;
			
			if (_dataGrid && _dataGrid.grid)
				_dataGrid.grid.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, grid_changeEventHandler);
			
			layout.clearVirtualLayoutCache();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("dataGridChanged");
		}
		private function grid_changeEventHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "horizontalScrollPosition")
				horizontalScrollPosition = Number(event.newValue);
		}
		private var _downColumnIndex:int = -1;
		/**
		 * 为当前被用户按下的标题呈示器指定列索引。 
		 * <p>将 downColumnIndex 设置为 -1（默认值）表示未定义列索引，且标题呈示器将其 down 属性设置为 false。</p>
		 */		
		public function get downColumnIndex():int
		{
			return _downColumnIndex;
		}
		public function set downColumnIndex(value:int):void
		{
			if (_downColumnIndex == value)
				return;
			
			_downColumnIndex = value;
			invalidateDisplayList();
			dispatchChangeEvent("downColumnIndexChanged");
		}
		private var _headerRenderer:Class = null;
		/**
		 * 用于呈示每个列标题的 IGridItemRenderer 类。
		 */		
		public function get headerRenderer():Class
		{
			return _headerRenderer;
		}
		public function set headerRenderer(value:Class):void
		{
			if (value == _headerRenderer)
				return;
			
			_headerRenderer = value;
			
			layout.clearVirtualLayoutCache();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("headerRendererChanged");
		}
		private var _hoverColumnIndex:int = -1;
		/**
		 * 为用户当前在其上悬浮鼠标的标题呈示器指定列索引。 
		 * <p>将 hoverColumnIndex 设置为 -1（默认值）表示未定义列索引，且标题呈示器将其 hovered 属性设置为 false。</p>
		 */		
		public function get hoverColumnIndex():int
		{
			return _hoverColumnIndex;
		}
		public function set hoverColumnIndex(value:int):void
		{
			if (_hoverColumnIndex == value)
				return;
			
			_hoverColumnIndex = value;
			invalidateDisplayList();
			dispatchChangeEvent("hoverColumnIndexChanged");
		}
		private var _visibleSortIndicatorIndices:Vector.<int> = new Vector.<int>();
		/**
		 * 与当前使其排序指示符可见的标题呈示器相对应的列索引的矢量。
		 * 
		 * <p>此属性可用作数据绑定的源代码。</p>
		 */	
		public function get visibleSortIndicatorIndices():Vector.<int>
		{
			return _visibleSortIndicatorIndices.concat();
		}
		public function set visibleSortIndicatorIndices(value:Vector.<int>):void
		{
			
			const valueCopy:Vector.<int> = (value) ? value.concat() : new Vector.<int>();
			
			_visibleSortIndicatorIndices = valueCopy;
			
			invalidateDisplayList();
			dispatchChangeEvent("visibleSortIndicatorIndicesChanged");
		}
		/**
		 *  如果指定列的排序指示符可见，则返回 true。这仅仅是如下内容的更有效版本： 
		 * <p>visibleSortIndicatorIndices.indexOf(columnIndex) != -1</p>
		 * @param columnIndex 标题呈示器列的从零开始的列索引。
		 * @return 如果指定列的排序指示符可见，则为 true。
		 * 
		 */		
		public function isSortIndicatorVisible(columnIndex:int):Boolean
		{
			return (_visibleSortIndicatorIndices.indexOf(columnIndex) != -1);
		}
		/**
		 * 返回对应于指定坐标的列索引；如果坐标超出边界，则返回 -1。相对于 GridColumnHeaderGroup 布局目标解析坐标。 
		 * <p>如果网格的所有列或行尚未滚动到视图，则基于所有列的 typicalItem 属性返回的索引可能只是一个近似值。</p>
		 * @param x 相对于 columnHeaderGroup 的像素的 x 坐标。
		 * @param y 相对于 columnHeaderGroup 的像素的 y 坐标。
		 * @return  列索引；如果坐标超出边界，则返回 -1。
		 * 
		 */		
		public function getHeaderIndexAt(x:Number, y:Number):int
		{
			return GridColumnHeaderGroupLayout(layout).getHeaderIndexAt(x, y);
		}
		/**
		 * 返回对应于指定坐标的列分隔符索引；如果坐标不重叠分隔符，则为 -1。相对于 GridColumnHeaderGroup 布局目标解析坐标。 
		 * <p>如果 x 坐标在分隔符水平中点的 separatorMouseWidth 内，则分隔符认为是“重叠”指定位置。</p>
		 * <p>分隔符索引与左侧的列索引相同，假设该组件的 layoutDirection 是 "ltr"。这说明所有列标题
		 * 两侧有两个分隔符，但是第一个可见列（仅在右侧有一个分隔符）和最后一个可见列（仅在左侧有一个分隔符）除外。</p>
		 * <p>如果网格的所有列或行尚未滚动到视图，则基于所有列的 typicalItem 属性返回的索引可能只是一个近似值。</p>
		 * @param x 相对于 columnHeaderGroup 的像素的 x 坐标。
		 * @param y 相对于 columnHeaderGroup 的像素的 y 坐标。
		 * @return 列索引；如果坐标不重叠分隔符，则为 -1。
		 * 
		 */		
		public function getSeparatorIndexAt(x:Number, y:Number):int
		{
			return GridColumnHeaderGroupLayout(layout).getSeparatorIndexAt(x, y);
		}    
		/**
		 * 如果请求的标题呈示器可用，则返回对指定列当前显示的标题呈示器的引用。请注意，一旦返回的标题呈示器不再可见，则会将其回收，并重置其属性。 
		 * <p>如果请求的标题呈示器不可见，则每次调用此方法时创建一个新的标题呈示器。新的项呈示器不可见</p>
		 * <p>返回的呈示器的宽度与 DataGrid/getItemRendererAt() 返回的项呈示器的宽度相同。</p>
		 * @param columnIndex 标题呈示器列的从零开始的列索引。
		 * @return 项呈示器；如果列索引无效，则为 null。
		 * 
		 */		
		public function getHeaderRendererAt(columnIndex:int):IGridItemRenderer
		{
			return GridColumnHeaderGroupLayout(layout).getHeaderRendererAt(columnIndex);
		}
		/**
		 * 返回指定标题（呈示器）的当前像素范围，如果不存在这样的列，则返回 null。报告 GridColumnHeaderGroup 坐标中的标题范围。 
		 * 
		 * <p>如果指定列前的所有可视列尚未滚动到视图，则基于所有 Grid 的 typicalItem 返回的范围可能只是一个近似值。</p>
		 * @param columnIndex 列的从零开始的索引。
		 * @return 表示列标题的像素范围的 Rectangle 或 null。
		 * 
		 */		
		public function getHeaderBounds(columnIndex:int):Rectangle
		{
			return GridColumnHeaderGroupLayout(layout).getHeaderBounds(columnIndex);
		}
		private var rollColumnIndex:int = -1;      
		private var rollSeparatorIndex:int = -1;   
		private var pressColumnIndex:int = -1;      
		private var pressSeparatorIndex:int = -1;   
		/**
		 * 当鼠标在标题栏的组内按下发生MOUSE_DOWN的时候，并且不会再触发MOUSE_MOVE事件，直到鼠标释放的时候。
		 * @param event
		 * 
		 */		
		protected function gchg_mouseDownDragUpHandler(event:MouseEvent):void
		{
			var eventStageXY:Point = new Point(event.stageX, event.stageY);
			var eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
			var eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
			var eventColumnIndex:int = 
				(eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
			
			var gridEventType:String;
			switch(event.type)
			{
				case MouseEvent.MOUSE_MOVE:
				{
					gridEventType = (pressSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_DRAG : GridEvent.GRID_MOUSE_DRAG;
					break;
				}
					
				case MouseEvent.MOUSE_UP:
				{
					gridEventType = (pressSeparatorIndex != -1) ? GridEvent.SEPARATOR_MOUSE_UP : GridEvent.GRID_MOUSE_UP;
					downColumnIndex = -1; 
					break;
				}
					
				case MouseEvent.MOUSE_DOWN:
				{
					if (eventSeparatorIndex != -1)
					{
						gridEventType = GridEvent.SEPARATOR_MOUSE_DOWN;
						pressSeparatorIndex = eventSeparatorIndex;
						pressColumnIndex = -1;
						downColumnIndex = -1; 
					}
					else
					{
						gridEventType = GridEvent.GRID_MOUSE_DOWN;
						pressSeparatorIndex = -1;
						pressColumnIndex = eventColumnIndex;
						downColumnIndex = eventColumnIndex; 
					}
					break;
				}
			}
			
			const columnIndex:int = (eventSeparatorIndex != -1) ? eventSeparatorIndex : eventColumnIndex;
			dispatchGridEvent(event, gridEventType, eventHeaderGroupXY, columnIndex);
		}
		/**
		 * 鼠标移动并且按钮没有被按下的时候触发。
		 * 当鼠标进入到标题栏的时候，这个方法会抛出一个GRID_ROLL_OVER事件。
		 * 当鼠标进入到一个分割线的时候，会抛出一个SEPARATOR_ROLL_OVER方法。
		 * 当鼠标离开他们的时候，会分别抛出GRID_ROLL_OUT和SEPARATOR_ROLL_OUT方法。
		 * 
		 * @param event
		 * 
		 */		
		protected function gchg_mouseMoveHandler(event:MouseEvent):void
		{
			const eventStageXY:Point = new Point(event.stageX, event.stageY);
			const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
			const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
			const eventColumnIndex:int = 
				(eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
			
			if (eventSeparatorIndex != rollSeparatorIndex)
			{
				if (rollSeparatorIndex != -1)
					dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderGroupXY, rollSeparatorIndex);
				if (eventSeparatorIndex != -1)
					dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OVER, eventHeaderGroupXY, eventSeparatorIndex);
			} 
			
			if (eventColumnIndex != rollColumnIndex)
			{
				if (rollColumnIndex != -1)
					dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderGroupXY, rollColumnIndex);
				if (eventColumnIndex != -1)
					dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventHeaderGroupXY, eventColumnIndex);
			} 
			
			rollColumnIndex = eventColumnIndex;
			rollSeparatorIndex = eventSeparatorIndex;
			hoverColumnIndex = eventColumnIndex;
		}
		/**
		 * 当鼠标移动出标题组的时候触发。然后抛出一个GRID_ROLL_OUT和 SEPARATOR_ROLL_OUT事件
		 * @param event
		 * 
		 */		
		protected function gchg_mouseRollOutHandler(event:MouseEvent):void
		{
			const eventStageXY:Point = new Point(event.stageX, event.stageY);
			const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
			
			if (rollSeparatorIndex != -1)
				dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderGroupXY, rollSeparatorIndex);
			else if (rollColumnIndex != -1)
				dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderGroupXY, rollColumnIndex);
			
			rollColumnIndex = -1;
			rollSeparatorIndex = -1;
			hoverColumnIndex = -1;
		}
		/**
		 * 在CLICK鼠标时间时候触发， 然后抛出一个GRID_CLICK事件
		 * @param event
		 * 
		 */		
		protected function gchg_clickHandler(event:MouseEvent):void 
		{
			const eventStageXY:Point = new Point(event.stageX, event.stageY);
			const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
			const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
			const eventColumnIndex:int = 
				(eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
			
			if ((eventSeparatorIndex != -1) && (pressSeparatorIndex == eventSeparatorIndex))
				dispatchGridEvent(event, GridEvent.SEPARATOR_CLICK, eventHeaderGroupXY, eventSeparatorIndex);
			else if ((eventColumnIndex != -1) && (pressColumnIndex == eventColumnIndex))
				dispatchGridEvent(event, GridEvent.GRID_CLICK, eventHeaderGroupXY, eventColumnIndex);
		}
		/**
		 * 这个方法在 DOUBLE_CLICK鼠标事件发生的时候触发。然后抛出一个GRID_DOUBLE_CLICK事件
		 * @param event
		 * 
		 */		
		protected function gchg_doubleClickHandler(event:MouseEvent):void 
		{
			const eventStageXY:Point = new Point(event.stageX, event.stageY);
			const eventHeaderGroupXY:Point = globalToLocal(eventStageXY);
			const eventSeparatorIndex:int = getSeparatorIndexAt(eventHeaderGroupXY.x, 0);
			const eventColumnIndex:int = 
				(eventSeparatorIndex == -1) ? getHeaderIndexAt(eventHeaderGroupXY.x, 0) : -1;
			
			if ((eventSeparatorIndex != -1) && (pressSeparatorIndex == eventSeparatorIndex))
				dispatchGridEvent(event, GridEvent.SEPARATOR_DOUBLE_CLICK, eventHeaderGroupXY, eventSeparatorIndex);
			else if ((eventColumnIndex != -1) && (pressColumnIndex == eventColumnIndex))
				dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventHeaderGroupXY, eventColumnIndex);
		}    
		private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, headerGroupXY:Point, columnIndex:int):void
		{
			const column:GridColumn = getColumnAt(columnIndex);
			const item:Object = null;
			const itemRenderer:IGridItemRenderer = getHeaderRendererAt(columnIndex);
			const bubbles:Boolean = mouseEvent.bubbles;
			const cancelable:Boolean = mouseEvent.cancelable;
			const relatedObject:InteractiveObject = mouseEvent.relatedObject;
			const ctrlKey:Boolean = mouseEvent.ctrlKey;
			const altKey:Boolean = mouseEvent.altKey;
			const shiftKey:Boolean = mouseEvent.shiftKey;
			const buttonDown:Boolean = mouseEvent.buttonDown;
			const delta:int = mouseEvent.delta;        
			
			const event:GridEvent = new GridEvent(
				type, bubbles, cancelable, 
				headerGroupXY.x, headerGroupXY.y, 
				relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
				-1 , columnIndex, column, item, itemRenderer);
			dispatchEvent(event);
		}     
		private function getColumnAt(columnIndex:int):GridColumn
		{
			const grid:Grid = (dataGrid) ? dataGrid.grid : null;
			if (!grid || !grid.columns)
				return null;
			
			const columns:ICollection = grid.columns;
			return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
		}
	}    
}