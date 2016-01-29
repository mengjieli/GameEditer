package egret.components
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import egret.collections.ArrayCollection;
	import egret.collections.ICollection;
	import egret.components.gridClasses.CellPosition;
	import egret.components.gridClasses.GridColumn;
	import egret.components.gridClasses.GridDimensions;
	import egret.components.gridClasses.GridLayout;
	import egret.components.gridClasses.GridSelection;
	import egret.components.gridClasses.GridSelectionMode;
	import egret.components.gridClasses.IDataGridElement;
	import egret.components.gridClasses.IGridItemRenderer;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.events.GridCaretEvent;
	import egret.events.GridEvent;
	import egret.events.PropertyChangeEvent;
	import egret.events.UIEvent;
	import egret.utils.MouseEventUtil;
	
	use namespace ns_egret;
	
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
	 * 表格鼠标移除
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
	 * 标识符改变
	 */	
	[Event(name="caretChange", type="egret.events.GridCaretEvent")]
	
	/**
	 *Grid 控件在可滚动表或“网格”中显示一列称为其数据提供程序的数据项（每行一个项）。
	 * 由 GridColumn 对象定义的每个网格的列基于相应行的项显示值。网格的数据提供程序是可以更改的，
	 * 说明可以添加、删除或更改其项。同样，列的列表也是可以更改的。  
	 */	
	public class Grid extends Group implements IDataGridElement
	{
		/**
		 *  当dataProvider被赋值的时候，这组方法回调将会在commitProperties()的时候触发，
		 */		
		private var deferredOperations:Vector.<Function> = new Vector.<Function>();
		/**
		 * 通过caretRowIndex缓存项数据，以便我们在数据更新之后可以找到插入标识符的行索引。
		 */		
		private var caretSelectedItem:Object = null;
		/**
		 * 当updateDisplayList的时候这个值为true.用于使invalidateSize()和invalidateDisplayList()失效。
		 * 
		 */		
		ns_egret var inUpdateDisplayList:Boolean = false;  
		/**
		 * 当用鼠标拖拽的时候为true
		 */		
		private var dragInProgress:Boolean = false;
		/**
		 * 当一个列被创建的时候为true
		 */		
		private var generatedColumns:Boolean = false;
		
		/**
		 * 构造函数
		 */		
		public function Grid()
		{
			super();
			layout = new GridLayout();
			
			MouseEventUtil.addDownDragUpListeners(this, 
				grid_mouseDownDragUpHandler, 
				grid_mouseDownDragUpHandler, 
				grid_mouseDownDragUpHandler);
			
			addEventListener(MouseEvent.MOUSE_UP, grid_mouseUpHandler);
			addEventListener(MouseEvent.MOUSE_MOVE, grid_mouseMoveHandler);
			addEventListener(MouseEvent.ROLL_OUT, grid_mouseRollOutHandler);      
		}
		
		private function get gridLayout():GridLayout
		{
			return layout as GridLayout;
		}
		
		private function dispatchChangeEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new Event(type));
		}
		
		private function dispatchUIEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new UIEvent(type));
		}
		
		private var _anchorColumnIndex:int = 0;
		
		/**
		 *  anchorColumnIndex和anchorRowIndex变化的时候这个值为true
		 */		
		private var anchorChanged:Boolean = false;
		
		/**
		 * 下一个结合 Shift 键选择的锚点的列索引。锚点是最近选定的项。它在网格中选择多个项时定义锚点项。
		 * 当您选择多个项时，这一组项从锚点扩展至插入标记项。 
		 * 
		 * <p>网格事件处理函数应使用此属性记录最近未结合 Shift 键的鼠标按下或键盘事件的位置，该事件定义下
		 * 一个潜在移动选择的一端。尖号索引定义另一端。</p>
		 */		
		public function get anchorColumnIndex():int
		{
			return _anchorColumnIndex;
		}
		
		public function set anchorColumnIndex(value:int):void
		{
			if (_anchorColumnIndex == value || 
				selectionMode == GridSelectionMode.SINGLE_ROW || 
				selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				return;
			}
			
			_anchorColumnIndex = value;
			
			anchorChanged = true;
			invalidateProperties();
			
			dispatchChangeEvent("anchorColumnIndexChanged");
		}
		
		private var _anchorRowIndex:int = 0; 
		/**
		 * 下一个结合 Shift 键选择的锚点的行索引。锚点是最近选定的项。它在网格中选择多个项时定义锚点项。
		 * 当您选择多个项时，这一组项从锚点扩展至插入标记项。 
		 * 
		 * <p>网格事件处理函数应使用此属性记录最近未结合 Shift 键的鼠标按下或键盘事件的位置，该事件定义下
		 * 一个潜在移动选择的一端。尖号索引定义另一端。</p>
		 */		
		public function get anchorRowIndex():int
		{
			return _anchorRowIndex;
		}
		
		public function set anchorRowIndex(value:int):void
		{
			if (_anchorRowIndex == value)
				return;
			
			_anchorRowIndex = value;
			
			anchorChanged = true;
			invalidateProperties();
			
			dispatchChangeEvent("anchorRowIndexChanged");
		}
		
		private var _caretIndicator:Class = null;
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则为针对插入标记行显示的单个可视元素；如果 selectionMode 是 GridSelectionMode.SINGLE_CELL
		 * 或 GridSelectionMode.MULTIPLE_CELLS，则为针对插入标记单元格显示的可视元素。
		 * @return 
		 * 
		 */		
		public function get caretIndicator():Class
		{
			return _caretIndicator;
		}
		public function set caretIndicator(value:Class):void
		{
			if (_caretIndicator == value)
				return;
			
			_caretIndicator = value;
			invalidateDisplayListFor("caretIndicator");
			dispatchChangeEvent("caretIndicatorChanged");
		}    
		
		private var _caretColumnIndex:int = -1;
		
		private var _oldCaretColumnIndex:int = -1;
		
		private var caretChanged:Boolean = false;
		/**
		 * 如果 showCaretIndicator 为 true，则为 caretIndicator 的列索引。 
		 * 
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则指示符将占用整行，并忽略 caretColumnIndex。如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 
		 * 或 GridSelectionMode.MULTIPLE_CELLS，则 caretIndicator 将占用指定单元格。</p>
		 * <p>将 caretColumnIndex 设置为 -1 表示未定义列索引且不显示单元格插入标记。</p>
		 */		
		public function get caretColumnIndex():int
		{
			return _caretColumnIndex;
		}
		public function set caretColumnIndex(value:int):void
		{
			if (_caretColumnIndex == value || value < -1)
				return;
			
			_caretColumnIndex = value;
			
			caretChanged = true;
			invalidateProperties();
			invalidateDisplayListFor("caretIndicator");         
			dispatchChangeEvent("caretColumnIndexChanged");
		}
		
		private var _caretRowIndex:int = -1;
		
		private var _oldCaretRowIndex:int = -1;
		/**
		 * 如果 showCaretIndicator 为 true，则为 caretIndicator 的行索引。如果 selectionMode 是 GridSelectionMode.SINGLE_ROW
		 * 或 GridSelectionMode.MULTIPLE_ROWS，则指示符将占用整行，并忽略 caretColumnIndex 属性。如果 selectionMode 是
		 * GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，则 caretIndicator 将占用指定单元格。 
		 * 
		 * <p>将 caretRowIndex 设置为 -1 表示未定义行索引且不显示插入标记。</p>
		 */		
		public function get caretRowIndex():int
		{
			return _caretRowIndex;
		}
		
		public function set caretRowIndex(value:int):void
		{
			if (_caretRowIndex == value || value < -1)
				return;
			
			_caretRowIndex = value;
			
			caretChanged = true;
			invalidateProperties();
			invalidateDisplayListFor("caretIndicator");         
			dispatchChangeEvent("caretRowIndexChanged");
		}
		
		private var _hoverIndicator:Class = null;
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS。为鼠标下的行显示的单个可视元素。
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，则为单元格的可视元素。 
		 */		
		public function get hoverIndicator():Class
		{
			return _hoverIndicator;
		}
		
		public function set hoverIndicator(value:Class):void
		{
			if (_hoverIndicator == value)
				return;
			
			_hoverIndicator = value;
			invalidateDisplayListFor("hoverIndicator");
			dispatchChangeEvent("hoverIndicatorChanged");
		}    
		
		private var _hoverColumnIndex:int = -1;
		/**
		 * 如果 showHoverIndicator 为 true，则指定 hoverIndicator 的列索引。如果 selectionMode 为 GridSelectionMode.SINGLE_ROW 
		 * 或 GridSelectionMode.MULTIPLE_ROWS，则指示符将占用整行，并忽略 hoverColumnIndex。如果 selectionMode 为 
		 * GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，则 hoverIndicator 将占用指定单元格。 
		 * <p>将 hoverColumnIndex 设置为 -1（默认值）表示未定义列索引且不显示单元格悬停指示符。</p>
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
			invalidateDisplayListFor("hoverIndicator");
			dispatchChangeEvent("hoverColumnIndexChanged");
		}
		
		private var _hoverRowIndex:int = -1;
		/**
		 *  
		 * 如果 showHoverIndicator 为 true，则指定 hoverIndicator 的列索引。
		 * 如果 selectionMode 为 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则指示符将占用整行，并忽略 hoverColumnIndex。如果 selectionMode 为 GridSelectionMode.SINGLE_CELL 
		 * 或 GridSelectionMode.MULTIPLE_CELLS，则 hoverIndicator 将占用指定单元格。 
		 * <p>将 hoverRowIndex 设置为 -1（默认值）表示未定义行索引且不显示悬停指示符。</p>
		 */		
		public function get hoverRowIndex():int
		{
			return _hoverRowIndex;
		}
		
		public function set hoverRowIndex(value:int):void
		{
			if (_hoverRowIndex == value)
				return;
			
			_hoverRowIndex = value;
			invalidateDisplayListFor("hoverIndicator");           
			dispatchChangeEvent("hoverRowIndexChanged");
		}
		
		private var _columns:ICollection = null;
		
		private var columnsChanged:Boolean = false;
		/**
		 * <p>由该网格显示的 GridColumn 对象列表。每列选择要显示的不同数据提供程序项属性。</p>
		 * 
		 * <p>GridColumn 对象仅可以显示在单个 Grid 控件的 columns 中。</p>
		 * 
		 * <p>此属性可用作数据绑定的源代码。</p>
		 */		
		public function get columns():ICollection
		{
			return _columns;
		}
		
		public function set columns(value:ICollection):void
		{
			if (_columns == value)
				return;
			var oldColumns:ICollection = _columns;
			if (oldColumns)
			{
				oldColumns.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
				for (var index:int = 0; index < oldColumns.length; index++)
				{
					var oldColumn:GridColumn = GridColumn(oldColumns.getItemAt(index));
					oldColumn.setGrid(null);
					oldColumn.setColumnIndex(-1);
				}
			}
			
			_columns = value; 
			var newColumns:ICollection = _columns;
			if (newColumns)
			{
				newColumns.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler, false, 0, true);
				for (index = 0; index < newColumns.length; index++)
				{
					var newColumn:GridColumn = GridColumn(newColumns.getItemAt(index));
					newColumn.setGrid(this);
					newColumn.setColumnIndex(index);
				}
			}
			
			columnsChanged = true;
			generatedColumns = false;        
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("columnsChanged");             
		}
		
		private function getColumnsLength():uint
		{
			var columns:ICollection = this.columns;
			return (columns) ? columns.length : 0;
		}
		
		private function generateColumns():ICollection
		{
			var item:Object = typicalItem;
			if (!item && dataProvider && (dataProvider.length > 0))
				item = dataProvider.getItemAt(0);
			
			var itemColumns:ArrayCollection = null;
			if (item)
			{
				itemColumns = new ArrayCollection;
				for(var property:String in item)
				{
					var column:GridColumn = new GridColumn();
					column.dataField = property;
					itemColumns.addItem(column);          
				}
			}
			
			return itemColumns;
		}
		
		private var _dataProvider:ICollection = null;
		
		private var dataProviderChanged:Boolean;
		/**
		 * <p>与网格中的行对应的数据项的列表。每个网格列与要在网格单元格中显示属性的数据项的属性相关联。</p>
		 * 
		 * <p>此属性可用作数据绑定的源代码。</p>
		 */		
		public function get dataProvider():ICollection
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:ICollection):void
		{
			if (_dataProvider == value)
				return;
			
			var oldDataProvider:ICollection = dataProvider;
			if (oldDataProvider)
				oldDataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
			
			_dataProvider = value;
			var newDataProvider:ICollection = dataProvider;
			if (newDataProvider)
				newDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);        
			
			dataProviderChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("dataProviderChanged");
		}
		
		private var _dataTipField:String = null;
		/**
		 * @copy egret.components.gridClasses.GridColumn#dataTipField 
		 * @return 
		 * 
		 */		
		public function get dataTipField():String
		{
			return _dataTipField;
		}
		
		public function set dataTipField(value:String):void
		{
			if (_dataTipField == value)
				return;
			
			_dataTipField = value;
			invalidateDisplayList();
			dispatchChangeEvent("dataTipFieldChanged");
		}
		
		private var _dataTipFunction:Function = null;
		/**
		 * @copy egret.components.gridClasses.GridColumn#dataTipFunction 
		 */		
		public function get dataTipFunction():Function
		{
			return _dataTipFunction;
		}
		
		public function set dataTipFunction(value:Function):void
		{
			if (_dataTipFunction == value)
				return;
			
			_dataTipFunction = value;
			invalidateDisplayList();        
			dispatchChangeEvent("dataTipFunctionChanged");
		}    
		
		private var _itemRenderer:Class = null;
		
		private var itemRendererChanged:Boolean = false;
		/**
		 * 项呈示器，用于不指定项呈示器的列。 
		 */		
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		public function set itemRenderer(value:Class):void
		{
			if (_itemRenderer == value)
				return;
			
			_itemRenderer = value;
			
			itemRendererChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("itemRendererChanged");
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
		
		private var _gridSelection:GridSelection;
		
		ns_egret function get gridSelection():GridSelection
		{
			if (!_gridSelection)
				_gridSelection = createGridSelection();
			
			return _gridSelection;
		}
		
		ns_egret function set gridSelection(value:GridSelection):void
		{
			_gridSelection = value;
		}
		
		private var _dataGrid:DataGrid = null;
		/**
		 * 如果该 Grid 用作网格外观部件，则为 DataGrid 控件。
		 * @return 
		 * 
		 */		
		public function get dataGrid():DataGrid
		{
			return _dataGrid;
		}
		
		public function set dataGrid(value:DataGrid):void
		{
			if (_dataGrid == value)
				return;
			
			_dataGrid = value;
			dispatchChangeEvent("dataGridChanged");
		}
		/**
		 * 如果为 true，数据提供程序刷新其集合时会保留选定内容。因为此刷新需要保存选定内容中的每一项，所以如果选定内容的大小很大，则不希望执行此操作。 
		 */		
		public function get preserveSelection():Boolean
		{
			return gridSelection.preserveSelection;
		}
		
		public function set preserveSelection(value:Boolean):void
		{
			gridSelection.preserveSelection = value;
		}
		
		private var _requestedMaxRowCount:int = 10;
		
		/**
		 * 此网格的测量高度足以显示至多 requestedMaxRowCount 个行。 
		 * 
		 * <p>如果以下任一项为 true，则此属性无效： 
		 * <ul>
		 * <li>已设置 requestedRowCount。 </li>
		 * <li>已显式设置网格的实际大小。 </li>
		 * </ul></p>
		 */		
		public function get requestedMaxRowCount():int
		{
			return _requestedMaxRowCount;
		}
		
		public function set requestedMaxRowCount(value:int):void
		{
			if (_requestedMaxRowCount == value)
				return;
			
			_requestedMaxRowCount = value;
			invalidateSize();
		} 
		
		private var _requestedMinRowCount:int = -1;
		/**
		 * 此网格的测量高度足以至少显示 requestedMinRowCount 个行。 
		 * 
		 * <p>如果以下任一项为 true，则此属性无效：
		 * <ul> 
		 * <li>已设置 requestedRowCount。 </li>
		 * <li>已显式设置网格的实际大小。 </li>
		 * </ul></p>
		 */		
		public function get requestedMinRowCount():int
		{
			return _requestedMinRowCount;
		}
		
		public function set requestedMinRowCount(value:int):void
		{
			if (_requestedMinRowCount == value)
				return;
			
			_requestedMinRowCount = value;
			invalidateSize();
		}    
		
		private var _requestedRowCount:int = -1;
		/**
		 * <p>此网格的测量高度足以显示前面的 requestedRowCount 个行。 </p>
		 * <p>如果 requestedRowCount 为 -1，则测量大小足以显示所有布局元素。</p>
		 * <p>如果已显式设置网格的实际大小，则此属性不起作用。</p>
		 */		
		public function get requestedRowCount():int
		{
			return _requestedRowCount;
		}
		
		public function set requestedRowCount(value:int):void
		{
			if (_requestedRowCount == value)
				return;
			
			_requestedRowCount = value;
			invalidateSize();
		}
		
		private var _requestedMinColumnCount:int = -1;
		/**
		 * 此网格的测量宽度足以显示至少 requestedMinColumnCount 个列。 
		 * 
		 * <p>如果以下任一项为 true，则此属性无效： 
		 * <ul>
		 * <li>已设置 requestedColumnCount。 </li> 
		 * <li>已显式设置网格的实际大小。</li>  
		 * <li>网格位于 Scroller 组件内。</li> 
		 * </ul></p>
		 */		
		public function get requestedMinColumnCount():int
		{
			return _requestedMinColumnCount;
		}
		
		public function set requestedMinColumnCount(value:int):void
		{
			if (_requestedMinColumnCount == value)
				return;
			
			_requestedMinColumnCount = value;
			invalidateSize();
		}  
		
		private var _requestedColumnCount:int = -1;
		/**
		 * <p>此网格的测量宽度足以显示前面的 requestedColumnCount 个列。
		 * 如果 requestedColumnCount 为 -1，则测量宽度足以显示所有列。 </p>
		 * 
		 * <p>如果已显式设置网格的实际大小，则此属性不起作用。</p>
		 */		
		public function get requestedColumnCount():int
		{
			return _requestedColumnCount;
		}
		
		public function set requestedColumnCount(value:int):void
		{
			if (_requestedColumnCount == value)
				return;
			
			_requestedColumnCount = value;
			invalidateSize();
		}    
		/**
		 * 如果为 true 且 selectionMode 属性不是 GridSelectionMode.NONE，则必须始终在网格中选中某一项。 
		 */		
		public function get requireSelection():Boolean
		{
			return gridSelection.requireSelection;
		}
		
		public function set requireSelection(value:Boolean):void
		{
			gridSelection.requireSelection = value;
			
			if (value)
				invalidateDisplayListFor("selectionIndicator");
		}
		
		private var _resizableColumns:Boolean = true;
		/**
		 * 指示用户能否更改列的尺寸。 如果为 true，则用户可以通过在标题单元格之间拖动网格线来伸
		 * 展或缩短 DataGrid 控件的列。如果为 true，则还必须将单个列的 resizable 设置为
		 *  false 以防止用户调整特定列的大小。
		 */		
		public function get resizableColumns():Boolean
		{
			return _resizableColumns;
		}
		
		public function set resizableColumns(value:Boolean):void
		{
			if (value == resizableColumns)
				return;
			
			_resizableColumns = value;        
			dispatchChangeEvent("resizableColumnsChanged");            
		}
		
		private var _rowBackground:Class = null;
		/**
		 * 为每行显示背景的可视元素。 
		 */		
		public function get rowBackground():Class
		{
			return _rowBackground;
		}
		
		public function set rowBackground(value:Class):void
		{
			if (_rowBackground == value)
				return;
			
			_rowBackground = value;
			invalidateDisplayList();
			dispatchChangeEvent("rowBackgroundChanged");
		}
		
		private var _rowHeight:Number = NaN;
		
		private var rowHeightChanged:Boolean;
		/**
		 * <p>如果 variableRowHeight 为 false，则此属性指定每行的实际高度（以像素为单位）。</p>
		 * <p>如果 variableRowHeight 为 true，将此属性的值用作尚未滚动到可视范围内的行的估计高度，
		 * 而不是使用 typicalItem 配置的呈示器的首选高度。同样，当 Grid 使用空行填充其显示时，此属性指定空行的高度。</p>
		 * <p>如果 variableRowHeight 为 false，则此属性的默认值是为 typicalItem 创建的每列呈示器的最大首选高度。</p>
		 * @return 
		 * 
		 */		
		public function get rowHeight():Number
		{
			return _rowHeight;
		}
		
		public function set rowHeight(value:Number):void
		{
			if (_rowHeight == value)
				return;
			
			_rowHeight = value;
			rowHeightChanged = true;        
			invalidateProperties();
			
			dispatchChangeEvent("rowHeightChanged");            
		}
		
		private function setFixedRowHeight(value:Number):void
		{
			if (_rowHeight == value)
				return;
			
			_rowHeight = value;
			dispatchChangeEvent("rowHeightChanged");		
		}
		
		private var _rowSeparator:Class = null;
		
		public function get rowSeparator():Class
		{
			return _rowSeparator;
		}
		
		public function set rowSeparator(value:Class):void
		{
			if (_rowSeparator == value)
				return;
			
			_rowSeparator = value;
			invalidateDisplayList();
			dispatchChangeEvent("rowSeparatorChanged");
		}    
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，
		 * 则返回第一个选定单元格（起点为 0 行 0 列），并在移动到下一行之前处理行中的每列。 </p>
		 * 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。
		 * 当用户以编程方式更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * 
		 * <p>此属性可用于初始化或绑定到 MXML 标记中的选择。setSelectedCell() 方法应用于程序选择更新，
		 * 例如编写 keyboard 或 mouse 事件处理函数时。 </p>
		 * 
		 */		
		public function get selectedCell():CellPosition
		{
			var selectedCells:Vector.<CellPosition> = gridSelection.allCells();
			return selectedCells.length ? selectedCells[0] : null;
		}
		
		public function set selectedCell(value:CellPosition):void
		{
			var rowIndex:int = (value) ? value.rowIndex : -1;
			var columnIndex:int = (value) ? value.columnIndex : -1;
			if (!initialized)
			{
				var f:Function = function():void
				{
					if ((rowIndex != -1) && (columnIndex != -1))
						setSelectedCell(rowIndex, columnIndex);
					else
						clearSelection();
				}
				
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				if ((rowIndex != -1) && (columnIndex != -1))
					setSelectedCell(rowIndex, columnIndex);
				else
					clearSelection();            
			}
		}  
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，则返回表示网格中选定单元格位置
		 * 的 CellPosition 对象的 Vector。 </p>
		 * 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。当用户以编程方式更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * 
		 * <p>此属性可用于初始化或绑定到 MXML 标记中的选择。setSelectedCell() 方法应用于程序选择更新，例如编写 keyboard 或 mouse 事件处理函数时。</p> 
		 * 
		 * <p>默认值为空 Vector.<CellPosition></p>
		 */		
		public function get selectedCells():Vector.<CellPosition>
		{
			return gridSelection.allCells();
		}
		
		public function set selectedCells(value:Vector.<CellPosition>):void
		{
			var valueCopy:Vector.<CellPosition> = new Vector.<CellPosition>(0);
			if (value)
			{
				for each (var cell:CellPosition in value)
				valueCopy.push(new CellPosition(cell.rowIndex, cell.columnIndex));
			}
			if (!initialized)
			{        
				var f:Function = function():void
				{
					clearSelection();
					for each (cell in valueCopy)
					addSelectedCell(cell.rowIndex, cell.columnIndex);
				}
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				clearSelection();
				for each (cell in valueCopy)
				addSelectedCell(cell.rowIndex, cell.columnIndex);            
			}
		}  
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，则返回第一个选定行的 rowIndex。</p>
		 * 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。当用户以编程方式更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * 
		 * <p>此属性可用于初始化中的选择。setSelectedCell() 方法应用于程序选择更新，例如编写 keyboard 或 mouse 事件处理函数时。</p>
		 */		
		public function get selectedIndex():int
		{
			var selectedRows:Vector.<int> = gridSelection.allRows();
			return (selectedRows.length > 0) ? selectedRows[0] : -1;
		}
		
		public function set selectedIndex(value:int):void
		{
			if (!initialized)
			{        
				var f:Function = function():void
				{
					if (value != -1)
						setSelectedIndex(value);
					else
						clearSelection();
				}
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				if (value != -1)
					setSelectedIndex(value);
				else
					clearSelection();
			}
		}
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则返回选定行索引的 Vector。对于所有其它选择模式，此方法不起作用。 </p>
		 * 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。当用户以编程方式
		 * 更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * 
		 * <p>此属性可用于初始化或绑定到 MXML 标记中的选择。setSelectedCell() 方法应用于程序选择更新
		 * ，例如编写 keyboard 或 mouse 事件处理函数时。 </p>
		 * 
		 * <p>默认值为空<code>Vector.&lt;Object&gt;</code></p>
		 */
		public function get selectedIndices():Vector.<int>
		{
			return gridSelection.allRows();
		}
		
		public function set selectedIndices(value:Vector.<int>):void
		{
			var valueCopy:Vector.<int> = (value) ? value.concat() : new Vector.<int>(0);
			if (!initialized)
			{        
				var f:Function = function():void
				{
					clearSelection();
					for each (var index:int in valueCopy)
					addSelectedIndex(index);
				}
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				clearSelection();
				for each (var index:int in valueCopy)
				addSelectedIndex(index);            
			}
		}  
		
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则返回当前选定或 undefined（如果未选定任何行）的数据提供程序中的项。 </p>
		 * 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。
		 * 当用户以编程方式更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * 
		 * <p>此属性可用于初始化或绑定到 MXML 标记中的选择。setSelectedCell() 方法应用于程序选择更新，
		 * 例如编写 keyboard 或 mouse 事件处理函数时。 </p>
		 */		
		public function get selectedItem():Object
		{
			var rowIndex:int = selectedIndex;
			if (rowIndex == -1)
				return undefined;
			
			return getDataProviderItem(rowIndex);           
		}
		
		public function set selectedItem(value:Object):void
		{
			if (!initialized)
			{        
				var f:Function = function():void
				{
					if (!dataProvider)
						return;
					
					var rowIndex:int = dataProvider.getItemIndex(value);
					if (rowIndex == -1)
						clearSelection();
					else
						setSelectedIndex(rowIndex);
				}
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				if (!dataProvider)
					return;
				
				var rowIndex:int = dataProvider.getItemIndex(value);
				if (rowIndex == -1)
					clearSelection();
				else
					setSelectedIndex(rowIndex);            
			}
		}
		/**
		 * <p>如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，则返回当前选择的 dataProvider 项目的 Vector。</p> 
		 * <p>当用户通过与控件进行交互更改选定内容时，控件将分派 selectionChange 事件。当用户以编程方式更改选定内容时，控件将分派 valueCommit 事件。</p>
		 * <p>此属性可用于初始化或绑定到 MXML 标记中的选择。setSelectedCell() 方法应用于程序选择更新，例如编写 keyboard 或 mouse 事件处理函数时。 </p>
		 * <p>默认值为空 <code>Vector.&lt;Object&gt;</code></p>
		 */		
		public function get selectedItems():Vector.<Object>
		{
			var rowIndices:Vector.<int> = selectedIndices;
			if (rowIndices.length == 0)
				return undefined;
			
			var items:Vector.<Object> = new Vector.<Object>();
			
			for each (var rowIndex:int in rowIndices)        
			items.push(dataProvider.getItemAt(rowIndex));
			
			return items;
		}
		
		public function set selectedItems(value:Vector.<Object>):void
		{
			var valueCopy:Vector.<Object> = (value) ? value.concat() : new Vector.<Object>(0);
			if (!initialized)
			{        
				var f:Function = function():void
				{
					if (!dataProvider)
						return;
					
					clearSelection();
					for each (var item:Object in valueCopy)
					addSelectedIndex(dataProvider.getItemIndex(item));
				}
				deferredOperations.push(f);  
				invalidateProperties();
			}
			else
			{
				if (!dataProvider)
					return;
				
				clearSelection();
				for each (var item:Object in valueCopy)
				addSelectedIndex(dataProvider.getItemIndex(item))            
			}
		}  
		
		private var _selectionIndicator:Class = null;
		
		public function get selectionIndicator():Class
		{
			return _selectionIndicator;
		}
		
		public function set selectionIndicator(value:Class):void
		{
			if (_selectionIndicator == value)
				return;
			
			_selectionIndicator = value;
			invalidateDisplayListFor("selectionIndicator");
			dispatchChangeEvent("selectionIndicatorChanged");
		}  
		/**
		 * 如果 selectionMode 为 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，则返回所选行的数量；
		 * 如果 selectionMode 为 GridSelectionMode.SINGLE_CELLS 或 GridSelectionMode.MULTIPLE_CELLS，
		 * 则返回所选单元格的数量。
		 * @return 
		 * 
		 */		
		public function get selectionLength():int
		{
			return gridSelection.selectionLength;   
		}
		/**
		 * 控件的选择模式。可能的值是：
		 * <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
		 * <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
		 * <code>GridSelectionMode.NONE</code>, 
		 * <code>GridSelectionMode.SINGLE_CELL</code>, 
		 * <code>GridSelectionMode.SINGLE_ROW</code>
		 * <p>更改 selectionMode 会导致清除当前选定内容，并将 caretRowIndex 和 caretColumnIndex 设置为 -1。</p>
		 */		
		public function get selectionMode():String
		{
			return gridSelection.selectionMode;
		}
		
		public function set selectionMode(value:String):void
		{
			if (selectionMode == value)
				return;
			
			gridSelection.selectionMode = value;
			if (selectionMode != value) 
				return;
			
			initializeAnchorPosition();
			if (!requireSelection)
				initializeCaretPosition();
			
			invalidateDisplayListFor("selectionIndicator");
			
			dispatchChangeEvent("selectionModeChanged");
		}
		
		private var _showDataTips:Boolean = false;
		/**
		 * 如果为 true，则显示所有可见单元格的 dataTip。如果为 false（默认值），
		 * 则仅当列的 showDataTips 属性为 true 时才显示 dataTip。 
		 */		
		public function get showDataTips():Boolean
		{
			return _showDataTips;
		}
		
		public function set showDataTips(value:Boolean):void
		{
			if (_showDataTips == value)
				return;
			
			_showDataTips = value;
			invalidateDisplayList();
			dispatchEvent(new Event("showDataTipsChanged"));
		}
		
		private var _typicalItem:Object = null;
		
		private var typicalItemChanged:Boolean = false;
		/**
		 * 网格的布局确保未指定宽度的列足以显示此默认数据提供程序项的项呈示器。如果未指定典型项，则使用第一个数据提供程序项。 
		 * 
		 * <p>限制：如果 typicalItem 是 IVisualItem，则它不能同时是数据提供程序的成员。</p>
		 */		
		public function get typicalItem():Object
		{
			return _typicalItem;
		}
		
		public function set typicalItem(value:Object):void
		{
			if (_typicalItem == value)
				return;
			
			_typicalItem = value;
			
			invalidateTypicalItemRenderer();
			
			dispatchChangeEvent("typicalItemChanged");
		}
		/**
		 *清除基于 typicalItem 属性的缓存列宽数据，并请求新的布局传递。如果应该由 Grid 的布局所反映的 typicalItem 的某些方面发生了更改，则调用该方法。 
		 *<p>如果直接对 typicalItem 进行更改，则会自动调用该方法。这说明如果属性设置为某一新值，则该新值与当前值不具有“==”的关系。</p>
		 */		
		public function invalidateTypicalItemRenderer():void
		{
			typicalItemChanged = true;       
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var _variableRowHeight:Boolean = false;
		
		private var variableRowHeightChanged:Boolean = false;
		/**
		 * 如果为 true，则每行的高度是到目前为止显示的单元格首选高度的最大值。 
		 * <p>如果为 false，则每行的高度恰好是 rowHeight 属性的值。如果未指定 rowHeight，则每行的高度由 typicalItem 属性定义。</p>
		 */		
		public function get variableRowHeight():Boolean
		{
			return _variableRowHeight;
		}
		
		public function set variableRowHeight(value:Boolean):void
		{
			if (value == variableRowHeight)
				return;
			
			_variableRowHeight = value;        
			variableRowHeightChanged = true;        
			invalidateProperties();
			
			dispatchChangeEvent("variableRowHeightChanged");            
		}
		/**
		 *<p>如果 selectionMode 是 GridSelectionMode.MULTIPLE_ROWS，选择所有行并删除插入标记；如果 selectionMode 
		 * 是 GridSelectionMode.MULTIPLE_CELLS，选择所有单元格并删除插入标记。对于所有其它选择模式，此方法不起作用。</p>
		 * 
		 * <p>如果调用此方法后向 dataProvider 添加项目或添加了 columns，将选择新的行或新列中的单元格。</p>
		 * 
		 * <p>发生以下任一情况时该隐式“全选”模式将结束： 
		 * <ul>
		 * <li>使用 clearSelection 清除选定内容 </li>
		 * <li>使用 setSelectedCell、setSelectedCells、setSelectedIndex 或 selectIndices 之一重置选定内容 </li>
		 * <li>dataProvider 已刷新且 preserveSelection 为 false </li>
		 * <li>dataProvider 已重置 </li>
		 * <li>columns 已刷新，preserveSelection 为 false 且 selectionMode 为 GridSelectionMode.MULTIPLE_CELLS </li>
		 * <li>columns 已重置且 selectionMode 为 GridSelectionMode.MULTIPLE_CELLS  </li>
		 * </ul></p>
		 *  @return 如果选定内容发生更改，则为 true。
		 * 
		 */		
		public function selectAll():Boolean
		{           
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.selectAll();
			if (selectionChanged)
			{               
				initializeCaretPosition();               
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}

		/**
		 * 如果 selectionMode 不是 GridSelectionMode.NONE，则删除所有所选行和单元格。
		 * 删除尖号并设置初始项目的锚点。 
		 * @return  如果选定内容更改，则为 true；如果之前没进行任何选择，则为 false。
		 * 
		 */	
		public function clearSelection():Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.removeAll();
			if (selectionChanged)
			{
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			initializeCaretPosition();
			initializeAnchorPosition();
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS 且 index 处的行位于当前选定内容中，则返回 true。 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。</p>
		 * @param rowIndex 行的从零开始的行索引。
		 * @return 如果选定内容包含此行，则返回 true。
		 * 
		 */		
		public function selectionContainsIndex(rowIndex:int):Boolean 
		{
			return gridSelection.containsRow(rowIndex);
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.MULTIPLE_ROWS 且 indices 中的行位于当前选定内容中，则返回 true。
		 * @param rowIndices 要包含在选定内容中的从零开始的行索引的矢量。
		 * @return  如果当前选定内容包含这些行，则返回 true。
		 * 
		 */		
		public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
		{
			return gridSelection.containsRows(rowIndices);
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，则将选定内容和尖号位置设置为此行。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @return 如果未引发任何错误，则为 true。如果 index 无效，或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function setSelectedIndex(rowIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.setRow(rowIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = -1;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.MULTIPLE_ROWS，将此行添加到选定内容并将尖号位置设置为此行。对于所有其它选择模式，此方法不起作用。 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @return  如果未引发任何错误，则为 true。如果 index 无效或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function addSelectedIndex(rowIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.addRow(rowIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = -1;                
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，删除选定内容中的此行并将尖号位置设置为此行。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @return 如果未引发任何错误，则为 true。如果 index 无效或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function removeSelectedIndex(rowIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.removeRow(rowIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = -1;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.MULTIPLE_ROWS，则将选定内容设置为指定行并将尖号位置设置为 endRowIndex。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>每个索引表示要包含在选定内容中的数据提供程序中的一项。</p>
		 * @param rowIndex 选定内容中第一行的从零开始的行索引。
		 * @param rowCount 选定内容中的行数。
		 * @return 如果未引发任何错误，则为 true。如果所有索引都无效或 startRowIndex 大于 endRowIndex 或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function selectIndices(rowIndex:int, rowCount:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.setRows(rowIndex, rowCount);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex + rowCount - 1;
				caretColumnIndex = -1;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS 且单元格位于当前选定内容中，则返回 true。 
		 * <p>rowIndex 必须介于 0 和数据提供程序的长度之间。columnIndex 必须介于 0 和 columns 的长度之间。</p> 
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @param columnIndex 单元格的从零开始的列索引。
		 * @return  如果当前选定内容包含单元格，则返回 true。
		 * 
		 */		
		public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
		{
			return gridSelection.containsCell(rowIndex, columnIndex);
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.MULTIPLE_CELLS 且单元格区域中的单元格位于当前选定内容中，则返回 true。 
		 * 
		 * <p>rowIndex 必须介于 0 和数据提供程序的长度之间。columnIndex 必须介于 0 和 columns 的长度之间。</p> 
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @param columnIndex 单元格的从零开始的列索引。
		 * @param rowCount 要包含在单元格区域中的行数，从 rowIndex 开始。
		 * @param columnCount 要包含在单元格区域中的列数，从 columnIndex 开始。
		 * @return 如果当前选定内容包含单元格区域中的所有单元格，则返回 true。
		 * 
		 */		
		public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
													rowCount:int, columnCount:int):Boolean
		{
			return gridSelection.containsCellRegion(rowIndex, columnIndex, 
				rowCount, columnCount);
		}
		
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，则将选定内容和尖号位置设置为此单元格。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。columnIndex 是包含所选单元格的列的 columns 中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @param columnIndex 单元格的从零开始的列索引。
		 * @return 如果未引发任何错误，则为 true。如果 rowIndex 或 columnIndex 无效，或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.setCell(rowIndex, columnIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = columnIndex;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 *如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，将单元格添加到选定内容并将尖号位置设置为该单元格。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。columnIndex 是包含所选单元格的列的 columns 中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @param columnIndex 单元格的从零开始的列索引。
		 * @return 如果未引发任何错误，则为 true。如果 rowIndex 或 columnIndex 无效，或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.addCell(rowIndex, columnIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = columnIndex;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，删除选定内容中的单元格并将尖号位置设置为该单元格。对于所有其它选择模式，此方法不起作用。 
		 * 
		 * <p>rowIndex 是包含所选单元格的项的数据提供程序中的索引。columnIndex 是包含所选单元格的列的 columns 中的索引。</p>
		 * @param rowIndex 单元格的从零开始的行索引。
		 * @param columnIndex 单元格的从零开始的列索引。
		 * @return 如果未引发任何错误，则为 true。如果 rowIndex 或 columnIndex 无效，或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.removeCell(rowIndex, columnIndex);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex;
				caretColumnIndex = columnIndex;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * 如果 selectionMode 是 GridSelectionMode.MULTIPLE_CELLS，则将选定内容设置为单元格区域中的所有单元格并将尖号位置设置为单元格区域中的最后一个单元格。对于所有其它选择模式，此方法不起作用。 
		 * <p>rowIndex 是包含单元格区域的原点的项的数据提供程序中的索引。columnIndex 是包含单元格区域的原点的列的 columns 中的索引。</p>
		 * <p>如果单元格区域没有完全包含在网格中，此方法不起作用。</p>
		 * @param rowIndex 单元格区域原点的从零开始的行索引。
		 * @param columnIndex 单元格区域原点的从零开始的列索引。
		 * @param rowCount 要包含在单元格区域中的行数，从 rowIndex 开始。
		 * @param columnCount 要包含在单元格区域中的列数，从 columnIndex 开始。
		 * @return  如果未引发任何错误，则为 true。如果单元格区域无效或 selectionMode 无效，则为 false。
		 * 
		 */		
		public function selectCellRegion(rowIndex:int, columnIndex:int, 
										 rowCount:uint, columnCount:uint):Boolean
		{
			if (invalidatePropertiesFlag)
				UIGlobals.layoutManager.validateClient(this, false);
			
			var selectionChanged:Boolean = gridSelection.setCellRegion(
				rowIndex, columnIndex, 
				rowCount, columnCount);
			if (selectionChanged)
			{
				caretRowIndex = rowIndex + rowCount - 1;
				caretColumnIndex = columnIndex + columnCount - 1;
				
				invalidateDisplayListFor("selectionIndicator");
				dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		private function get gridDimensions():GridDimensions
		{
			return gridLayout.gridDimensions;
		}
		private function scrollToIndex(elementIndex:int, scrollHorizontally:Boolean, scrollVertically:Boolean):Boolean
		{
			var spDelta:Point;// = gridLayout.getScrollPositionDeltaToElement(elementIndex);
			if (!spDelta)
				return false;  
			
			var scrollChanged:Boolean = false;
			
			if (scrollHorizontally)
			{
				horizontalScrollPosition += spDelta.x;
				scrollChanged = spDelta.x != 0;
			}
			
			if (scrollVertically)
			{
				verticalScrollPosition += spDelta.y;
				scrollChanged = scrollChanged || spDelta.y != 0;
			}
			
			return scrollChanged;
		}
		/**
		 * 如果需要，设置 verticalScrollPosition 和 horizontalScrollPosition 属性以使指定的单元格完全可见。如果 rowIndex 为 -1，
		 * 且指定了 columnIndex，则只需调整 horizontalScrollPosition 以使指定的列可见。如果 columnIndex 为 -1，且指定了 rowIndex，
		 * 则只需调整 verticalScrollPosition 以使指定的行可见。
		 * @param rowIndex 项呈示器的单元格的从零开始的行索引，或 -1 以指定一列。
		 * @param columnIndex 项呈示器的单元格的从零开始的列索引，或 -1 以指定一行。
		 * 
		 */		
		public function ensureCellIsVisible(rowIndex:int = -1, columnIndex:int = -1):void
		{
			var columns:ICollection = this.columns;
			if (!columns || columnIndex < -1 || columnIndex >= columns.length || 
				!dataProvider || rowIndex < -1 || rowIndex >= dataProvider.length || 
				(columnIndex == -1 && rowIndex == -1))
				return;
			if ((columnIndex == -1 && getNextVisibleColumnIndex(-1) == -1) || 
				(columnIndex != -1 && !(GridColumn(columns.getItemAt(columnIndex)).visible)))
				return;
			
			var columnsLength:int = columns.length;
			var scrollHorizontally:Boolean = columnIndex != -1;
			var scrollVertically:Boolean = rowIndex != -1;
			if (getVisibleRowIndices().length == 0 || getVisibleColumnIndices().length == 0)
				validateNow();
			if (!scrollHorizontally)
				columnIndex = 0;
			if (!scrollVertically)
			{
				var visibleRowIndices:Vector.<int> = this.getVisibleRowIndices();
				rowIndex = (visibleRowIndices.length > 0) ?  visibleRowIndices[0] : 0;
			}
			var elementIndex:int = (rowIndex * columnsLength) + columnIndex;
			
			var scrollChanged:Boolean = false;
			var firstScroll:Boolean = true;
			do
			{
				scrollChanged = scrollToIndex(elementIndex, scrollHorizontally, scrollVertically);
				if (!variableRowHeight && !scrollHorizontally)
					return;
				if (!firstScroll && !scrollChanged)
					return;
				
				validateNow();
				
				firstScroll = false;
			}
			while (!isCellVisible(scrollVertically ? rowIndex : -1, scrollHorizontally ? columnIndex : -1));
			scrollToIndex(elementIndex, scrollHorizontally, scrollVertically);
		}        
		public function getVisibleRowIndices():Vector.<int>
		{
			return gridLayout.getVisibleRowIndices();
		}
		public function getVisibleColumnIndices():Vector.<int>
		{
			return gridLayout.getVisibleColumnIndices();
		}
		public function getCellBounds(rowIndex:int, columnIndex:int):Rectangle
		{
			return gridLayout.getCellBounds(rowIndex, columnIndex);
		}
		public function getRowBounds(rowIndex:int):Rectangle
		{
			return gridLayout.getRowBounds(rowIndex);      
		}
		public function getColumnBounds(columnIndex:int):Rectangle
		{
			return gridLayout.getColumnBounds(columnIndex);
		}
		public function getRowIndexAt(x:Number, y:Number):int
		{
			return gridLayout.getRowIndexAt(x, y);
		}
		public function getColumnIndexAt(x:Number, y:Number):int
		{
			return gridLayout.getColumnIndexAt(x, y); 
		}
		public function getColumnWidth(columnIndex:int):Number
		{
			var column:GridColumn = getGridColumn(columnIndex);
			return (column && !isNaN(column.width)) ? column.width : gridDimensions.getColumnWidth(columnIndex);
		}
		public function getCellAt(x:Number, y:Number):CellPosition
		{
			return gridLayout.getCellAt(x, y);
		}
		public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
		{ 
			return gridLayout.getCellsAt(x, y, w, h);
		}
		public function getCellX(rowIndex:int, columnIndex:int):Number
		{ 
			return gridDimensions.getCellX(rowIndex, columnIndex);
		}
		public function getCellY(rowIndex:int, columnIndex:int):Number
		{ 
			return gridDimensions.getCellY(rowIndex, columnIndex);
		}      
		public function getItemRendererAt(rowIndex:int, columnIndex:int):IGridItemRenderer
		{
			return gridLayout.getItemRendererAt(rowIndex, columnIndex);
		}
		public function isCellVisible(rowIndex:int = -1, columnIndex:int = -1):Boolean
		{
			return gridLayout.isCellVisible(rowIndex, columnIndex);
		}
		private var invalidateDisplayListReasonsMask:uint = 0;
		private static var invalidateDisplayListReasonBits:Object = {
			verticalScrollPosition: uint(1 << 0),
			horizontalScrollPosition: uint(1 << 1),
			bothScrollPositions: (uint(1 << 0) | uint(1 << 1)),
			hoverIndicator: uint(1 << 2),
			caretIndicator: uint(1 << 3),
			selectionIndicator: uint(1 << 4),
			editorIndicator:  uint(1 << 5),
			none: uint(~0)
		};
		private function setInvalidateDisplayListReason(reason:String):void
		{
			invalidateDisplayListReasonsMask |= invalidateDisplayListReasonBits[reason];
		}
		ns_egret function isInvalidateDisplayListReason(reason:String):Boolean
		{
			var bit:uint = invalidateDisplayListReasonBits[reason];
			return (invalidateDisplayListReasonsMask & bit) == bit;
		}
		ns_egret function clearInvalidateDisplayListReasons():void
		{
			invalidateDisplayListReasonsMask = 0;
		}
		override public function invalidateSize():void
		{
			if (!inUpdateDisplayList)
			{
				super.invalidateSize();
				dispatchChangeEvent("invalidateSize");            
			}
		}
		override public function invalidateDisplayList():void
		{
			if (!inUpdateDisplayList)
			{
				setInvalidateDisplayListReason("none");            
				super.invalidateDisplayList();
				dispatchChangeEvent("invalidateDisplayList");
			}
		}
		override protected function commitProperties():void
		{
			
			if (variableRowHeightChanged || rowHeightChanged)
			{
				if (rowHeightChanged)
					gridDimensions.defaultRowHeight = _rowHeight;
				gridDimensions.variableRowHeight = variableRowHeight;
				
				if ((!variableRowHeight && rowHeightChanged) || variableRowHeightChanged)
				{
					clearGridLayoutCache(false);
					invalidateSize();
					invalidateDisplayList();
				}
				
				rowHeightChanged = false;
				variableRowHeightChanged = false;
			}
			if (itemRendererChanged || typicalItemChanged)
			{
				clearGridLayoutCache(true);
				itemRendererChanged = false;
			}
			if (!columns || (generatedColumns && 
				(typicalItemChanged || (!typicalItem && dataProviderChanged))))
			{
				var oldColumns:ICollection = columns;
				columns = generateColumns();
				generatedColumns = (columns != null);
				columnsChanged = columns != oldColumns;
			}
			typicalItemChanged = false;
			if (dataProviderChanged || columnsChanged)
			{
				if (gridSelection)
				{
					var savedRequireSelection:Boolean = gridSelection.requireSelection;
					gridSelection.requireSelection = false;
					gridSelection.removeAll();
					gridSelection.requireSelection = savedRequireSelection;
				}
				if (columnsChanged)
					gridDimensions.columnCount = _columns ? _columns.length : 0;
				if (typicalItem != null && !columnsChanged)
					clearGridLayoutCache(false);
				else
					clearGridLayoutCache(true);
				
				if (!caretChanged)
					initializeCaretPosition();
				
				if (!anchorChanged)
					initializeAnchorPosition();
				
				dataProviderChanged = false;
				columnsChanged = false;
			}
			anchorChanged = false;
			if (dataProvider)
			{
				for each (var deferredOperation:Function in deferredOperations)
				deferredOperation();
				deferredOperations.length = 0;                
			}
			if (caretChanged)
			{
				if (_dataProvider && caretRowIndex >= _dataProvider.length)
					_caretRowIndex = _dataProvider.length - 1;
				if (_columns && caretColumnIndex >= _columns.length)
					_caretColumnIndex = getPreviousVisibleColumnIndex(_columns.length - 1);
				
				caretSelectedItem = 
					_dataProvider && _caretRowIndex >= 0 ?
					_dataProvider.getItemAt(_caretRowIndex) : null;
				
				dispatchCaretChangeEvent();
				_oldCaretRowIndex = _caretRowIndex;
				_oldCaretColumnIndex = _caretColumnIndex;
				
				caretChanged = false;        
			}
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			inUpdateDisplayList = true;
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			inUpdateDisplayList = false;
			
			clearInvalidateDisplayListReasons();
			
			if (!variableRowHeight)
				setFixedRowHeight(gridDimensions.getRowHeight(0));    
		}
		ns_egret function invalidateDisplayListFor(reason:String):void
		{
			if (!inUpdateDisplayList)
			{
				setInvalidateDisplayListReason(reason);            
				super.invalidateDisplayList();
				dispatchChangeEvent("invalidateDisplayList");
			}
		}
		/**
		 * <p>如果指定的单元格可见，则它会重新显示。如果 variableRowHeight=true，则执行此操作可能会导致对应行的高度发生更改。</p>
		 * 
		 * <p>如果 columnIndex 为 -1，则整个行无效。同样，如果 rowIndex 为 -1，则整个列无效。</p>
		 * 
		 * <p>当对位于 rowIndex 处的数据提供程序项的任何方面所做的更改可能会影响指定单元格
		 * 的显示方式时，应调用该方法。调用该方法与调用 dataProvider.itemUpdated() 方法类似，
		 * 后者建议 Grid 显示指定项的所有行应重新显示。使用此方法可以相对提高效率，因为它将更
		 * 改的范围缩小到单个单元格。</p>
		 * @param rowIndex 发生更改的单元格的从零开始的行索引，或为 -1。
		 * @param columnIndex 发生更改的单元格的从零开始的列索引，或为 -1。
		 * 
		 */		
		public function invalidateCell(rowIndex:int, columnIndex:int):void
		{
			if (!dataProvider)
				return;
			
			var dataProviderLength:int = dataProvider.length;
			if (rowIndex >= dataProvider.length)
				return;
			
			if (!isCellVisible(rowIndex, columnIndex))
				return;
			
			if (invalidateDisplayListFlag || invalidateSizeFlag)
				return;        
			
			if ((rowIndex >= 0) && (columnIndex >= 0))
			{
				gridLayout.invalidateCell(rowIndex, columnIndex);
			}
			else if (rowIndex >= 0)  
			{
				var visibleColumnIndices:Vector.<int> = getVisibleColumnIndices();
				for each (var visibleColumnIndex:int in visibleColumnIndices)
				{
					gridLayout.invalidateCell(rowIndex, visibleColumnIndex);
					if (invalidateDisplayListFlag || invalidateSizeFlag)
						break;                
				}
			}
			else if (columnIndex >= 0)  
			{
				var visibleRowIndices:Vector.<int> = getVisibleRowIndices();
				for each (var visibleRowIndex:int in visibleRowIndices)
				{
					
					if (visibleRowIndex >= dataProviderLength)
						break;
					
					gridLayout.invalidateCell(visibleRowIndex, columnIndex);
					if (invalidateDisplayListFlag || invalidateSizeFlag)
						break;
				}
			}
		}
		ns_egret function createGridSelection():GridSelection
		{
			return new GridSelection();    
		}
		private function getGridColumn(columnIndex:int):GridColumn
		{
			var columns:ICollection = this.columns;
			if ((columns == null) || (columnIndex < 0) || (columnIndex >= columns.length))
				return null;
			
			return columns.getItemAt(columnIndex) as GridColumn;
		}
		ns_egret function getDataProviderItem(rowIndex:int):Object
		{
			var dataProvider:ICollection = this.dataProvider;
			if ((dataProvider == null) || (rowIndex >= dataProvider.length))
				return null;
			
			return dataProvider.getItemAt(rowIndex);
		}
		private function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IGridItemRenderer
		{
			var layout:GridLayout = this.layout as GridLayout;
			if (!layout)
				return null;
			
			return layout.getVisibleItemRenderer(rowIndex, columnIndex);
		}
		private var rollRowIndex:int = -1;
		private var rollColumnIndex:int = -1;
		private var mouseDownRowIndex:int = -1;
		private var mouseDownColumnIndex:int = -1;
		private var lastClickTime:Number;
		
		ns_egret var DOUBLE_CLICK_TIME:Number = 480;
		protected function grid_mouseDownDragUpHandler(event:MouseEvent):void
		{
			var eventStageXY:Point = new Point(event.stageX, event.stageY);
			var eventGridXY:Point = globalToLocal(eventStageXY);
			var gridDimensions:GridDimensions = this.gridDimensions;
			var eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
			var eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
			
			var gridEventType:String;
			switch(event.type)
			{
				case MouseEvent.MOUSE_MOVE: 
				{
					gridEventType = GridEvent.GRID_MOUSE_DRAG; 
					break;
				}
				case MouseEvent.MOUSE_UP: 
				{
					gridEventType = GridEvent.GRID_MOUSE_UP;
					break;
				}
				case MouseEvent.MOUSE_DOWN:
				{
					gridEventType = GridEvent.GRID_MOUSE_DOWN;
					mouseDownRowIndex = eventRowIndex;
					mouseDownColumnIndex = eventColumnIndex;
					dragInProgress = true;
					break;
				}
			}
			
			dispatchGridEvent(event, gridEventType, eventGridXY, eventRowIndex, eventColumnIndex);
			if (gridEventType == GridEvent.GRID_MOUSE_UP)
				dispatchGridClickEvents(event, eventGridXY, eventRowIndex, eventColumnIndex);
		}
		protected function grid_mouseMoveHandler(event:MouseEvent):void
		{
			var eventStageXY:Point = new Point(event.stageX, event.stageY);
			var eventGridXY:Point = globalToLocal(eventStageXY);
			var gridDimensions:GridDimensions = this.gridDimensions;
			var eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
			var eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
			
			if ((eventRowIndex != rollRowIndex) || (eventColumnIndex != rollColumnIndex))
			{
				if ((rollRowIndex != -1) || (rollColumnIndex != -1))
					dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
				if ((eventRowIndex != -1) && (eventColumnIndex != -1))
					dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventGridXY, eventRowIndex, eventColumnIndex);
				rollRowIndex = eventRowIndex;
				rollColumnIndex = eventColumnIndex;
			}
		}
		protected function grid_mouseRollOutHandler(event:MouseEvent):void
		{
			if ((rollRowIndex != -1) || (rollColumnIndex != -1))
			{
				var eventStageXY:Point = new Point(event.stageX, event.stageY);
				var eventGridXY:Point = globalToLocal(eventStageXY);            
				dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
				rollRowIndex = -1;
				rollColumnIndex = -1;
			}
		}
		protected function grid_mouseUpHandler(event:MouseEvent):void 
		{
			if (dragInProgress)
			{
				dragInProgress = false;
				return;
			}
			
			var eventStageXY:Point = new Point(event.stageX, event.stageY);
			var eventGridXY:Point = globalToLocal(eventStageXY);
			var gridDimensions:GridDimensions = this.gridDimensions;
			var eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
			var eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
			
			dispatchGridEvent(event, GridEvent.GRID_MOUSE_UP, eventGridXY, eventRowIndex, eventColumnIndex);
			dispatchGridClickEvents(event, eventGridXY, eventRowIndex, eventColumnIndex);
		}
		private function dispatchGridClickEvents(mouseEvent:MouseEvent, gridXY:Point, rowIndex:int, columnIndex:int):void
		{
			var dispatchGridClick:Boolean = (rowIndex == mouseDownRowIndex &&
				columnIndex == mouseDownColumnIndex);
			var newClickTime:Number = getTimer();
			if (doubleClickEnabled && dispatchGridClick && !isNaN(lastClickTime) &&
				(newClickTime - lastClickTime <= DOUBLE_CLICK_TIME))
			{
				dispatchGridEvent(mouseEvent, GridEvent.GRID_DOUBLE_CLICK, gridXY, rowIndex, columnIndex);
				lastClickTime = NaN;
				return;
			}
			if (dispatchGridClick)
			{
				dispatchGridEvent(mouseEvent, GridEvent.GRID_CLICK, gridXY, rowIndex, columnIndex);
				lastClickTime = newClickTime;
			}
		}
		private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, rowIndex:int, columnIndex:int):void
		{
			var column:GridColumn = columnIndex >= 0 ? getGridColumn(columnIndex) : null;
			var item:Object = rowIndex >= 0 ? getDataProviderItem(rowIndex) : null;
			var itemRenderer:IGridItemRenderer = getVisibleItemRenderer(rowIndex, columnIndex);
			var bubbles:Boolean = mouseEvent.bubbles;
			var cancelable:Boolean = mouseEvent.cancelable;
			var relatedObject:InteractiveObject = mouseEvent.relatedObject;
			var ctrlKey:Boolean = mouseEvent.ctrlKey;
			var altKey:Boolean = mouseEvent.altKey;
			var shiftKey:Boolean = mouseEvent.shiftKey;
			var buttonDown:Boolean = mouseEvent.buttonDown;
			var delta:int = mouseEvent.delta;        
			
			var event:GridEvent = new GridEvent(
				type, bubbles, cancelable, 
				gridXY.x, gridXY.y, 
				relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
				rowIndex, columnIndex, column, item, itemRenderer);
			dispatchEvent(event);
		}
		private function updateCaretForDataProviderChange(event:CollectionEvent):void
		{
			var oldCaretRowIndex:int = caretRowIndex;
			var location:int = event.location;
			var itemsLength:int = event.items ? event.items.length : 0;                
			var newCaretRowIndex:int; 
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
					if (oldCaretRowIndex >= location)
						caretRowIndex += event.items.length;
					break;
				
				case CollectionEventKind.REMOVE:
					if (oldCaretRowIndex >= location)
					{
						if (oldCaretRowIndex < (location + itemsLength))
							caretRowIndex = -1; 
						else
							caretRowIndex -= itemsLength;    
					}
					
					break;
				
				case CollectionEventKind.MOVE:
				{
					var oldLocation:int = event.oldLocation;
					if ((oldCaretRowIndex >= oldLocation) && (oldCaretRowIndex < (oldLocation + itemsLength)))
						caretRowIndex += location - oldLocation;
				}
					break;                        
				
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
					break;
				
				case CollectionEventKind.REFRESH:
				{
					newCaretRowIndex = 
						caretSelectedItem ?
						_dataProvider.getItemIndex(caretSelectedItem) : -1; 
					if (newCaretRowIndex != -1)
					{
						caretRowIndex = newCaretRowIndex;
						ensureCellIsVisible(caretRowIndex, -1);
					}
					else
					{
						var oldVsp:int = verticalScrollPosition;
						
						validateNow();
						var cHeight:Number = Math.ceil(gridDimensions.getContentHeight());
						var maximum:int = Math.max(cHeight - height, 0);
						verticalScrollPosition = (oldVsp > maximum) ? maximum : oldVsp;                        
					}
					break;
				}
					
				case CollectionEventKind.RESET:
				{
					newCaretRowIndex = 
						caretSelectedItem ?
						_dataProvider.getItemIndex(caretSelectedItem) : -1; 
					if (newCaretRowIndex != -1)
					{
						caretRowIndex = newCaretRowIndex;
						ensureCellIsVisible(caretRowIndex, -1);
					}
					else 
					{
						caretRowIndex = _dataProvider.length > 0 ? 0 : -1; 
						verticalScrollPosition = 0;
					}
					
					break;
				}
			}   
			
		}
		private function updateCaretForColumnsChange(event:CollectionEvent):void
		{
			var oldCaretColumnIndex:int = caretColumnIndex;
			var location:int = event.location;
			var itemsLength:int = event.items ? event.items.length : 0;
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
					if (oldCaretColumnIndex >= location)
						caretColumnIndex += itemsLength;
					break;
				
				case CollectionEventKind.REMOVE:
					if (oldCaretColumnIndex >= location)
					{
						if (oldCaretColumnIndex < (location + itemsLength))
							caretColumnIndex = _columns.length > 0 ? 0 : -1; 
						else
							caretColumnIndex -= itemsLength;    
					}                   
					break;
				
				case CollectionEventKind.MOVE:
					var oldLocation:int = event.oldLocation;
					if ((oldCaretColumnIndex >= oldLocation) && (oldCaretColumnIndex < (oldLocation + itemsLength)))
						caretColumnIndex += location - oldLocation;
					break;                        
				
				case CollectionEventKind.REPLACE:
					break;
				
				case CollectionEventKind.UPDATE:
					var pe:PropertyChangeEvent;
					
					if (selectionMode == GridSelectionMode.SINGLE_CELL || 
						selectionMode == GridSelectionMode.MULTIPLE_CELLS)
					{
						for (var i:int = 0; i < itemsLength; i++)
						{
							pe = event.items[i] as PropertyChangeEvent;
							if (pe && pe.property == "visible")
							{
								var column:GridColumn = pe.source as GridColumn;
								if (!column || column.visible)
									continue;
								
								if (column.columnIndex == caretColumnIndex)
									initializeCaretPosition(true);  
								if (column.columnIndex == anchorColumnIndex)
									initializeAnchorPosition(true);  
							}
						}
					}
					break;
				
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
					initializeCaretPosition(true);  
					horizontalScrollPosition = 0;
					break;
			}            
		}
		private function updateHoverForDataProviderChange(event:CollectionEvent):void
		{
			var oldHoverRowIndex:int = hoverRowIndex;
			var location:int = event.location;
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
				case CollectionEventKind.MOVE:
					if (oldHoverRowIndex >= location)
						hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
					break;
				
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
					hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
					break;
			}                        
		}
		private function updateHoverForColumnsChange(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
				case CollectionEventKind.MOVE:
					if (hoverColumnIndex >= event.location)
						hoverColumnIndex = gridDimensions.getColumnIndexAt(mouseX, mouseY);
					break;
				
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
					hoverColumnIndex = gridDimensions.getColumnIndexAt(mouseX, mouseY);
					break;
			}
		}
		private function dataProvider_collectionChangeHandler(event:CollectionEvent):void
		{
			
			if (!columns && dataProvider.length > 0)
			{
				columns = generateColumns();
				generatedColumns = (columns != null);
				gridDimensions.columnCount = generatedColumns ? columns.length : 0;
			}
			
			var gridDimenions:GridDimensions = this.gridDimensions;
			if (gridDimensions)
			{
				gridDimensions.dataProviderCollectionChanged(event);
				gridDimensions.rowCount = dataProvider.length;
			}
			
			if (gridLayout)
				gridLayout.dataProviderCollectionChanged(event);
			
			if (gridSelection)
				gridSelection.dataProviderCollectionChanged(event);            
			
			if (gridDimensions && hoverRowIndex != -1)
				updateHoverForDataProviderChange(event);
			invalidateSize();
			invalidateDisplayList();
			
			if (caretRowIndex != -1)
				updateCaretForDataProviderChange(event);
			
		}
		private function columns_collectionChangeHandler(event:CollectionEvent):void
		{
			var column:GridColumn;
			var columnIndex:int = event.location;
			var i:int;
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					
					while (columnIndex < columns.length)
					{
						column = GridColumn(columns.getItemAt(columnIndex));
						column.setGrid(this);
						column.setColumnIndex(columnIndex);
						columnIndex++;
					}                  
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					columnIndex = Math.min(event.oldLocation, event.location);
					var maxIndex:int = Math.max(event.oldLocation, event.location);
					while (columnIndex <= maxIndex)
					{
						column = GridColumn(columns.getItemAt(columnIndex));
						column.setColumnIndex(columnIndex);
						columnIndex++;
					}                
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					var items:Array = event.items;                   
					var length:int = items.length;
					for (i = 0; i < length; i++)
					{
						if (items[i].oldValue is GridColumn)
						{
							column = GridColumn(items[i].oldValue);
							column.setGrid(null);
							column.setColumnIndex(-1);
						}
						if (items[i].newValue is GridColumn)
						{
							column = GridColumn(items[i].newValue);
							column.setGrid(this);
							column.setColumnIndex(columnIndex);
						}
					}
					break;
				}
					
				case CollectionEventKind.UPDATE:
				{
					break;
				}
					
				case CollectionEventKind.REFRESH:
				{
					for (columnIndex = 0; columnIndex < columns.length; columnIndex++)
					{
						column = GridColumn(columns.getItemAt(columnIndex));
						column.setColumnIndex(columnIndex);
					}                
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					
					var count:int = event.items.length;
					
					for (i = 0; i < count; i++)
					{
						column = GridColumn(event.items[i]);
						column.setGrid(null);
						column.setColumnIndex(-1);
					}
					while (columnIndex < columns.length)
					{
						column = GridColumn(columns.getItemAt(columnIndex));
						column.setColumnIndex(columnIndex);
						columnIndex++;
					}                  
					
					break;
				}
					
				case CollectionEventKind.RESET:
				{
					for (columnIndex = 0; columnIndex < columns.length; columnIndex++)
					{
						column = GridColumn(columns.getItemAt(columnIndex));
						column.setGrid(this);
						column.setColumnIndex(columnIndex);
					}                     
					break;
				}                                
			}
			
			if (gridDimensions)
				gridDimensions.columnsCollectionChanged(event);
			
			if (gridLayout)
				gridLayout.columnsCollectionChanged(event);
			
			if (gridSelection)
				gridSelection.columnsCollectionChanged(event);
			
			if (caretColumnIndex != -1)
				updateCaretForColumnsChange(event);                
			
			if (gridDimensions && hoverColumnIndex != -1)
				updateHoverForColumnsChange(event); 
			
			invalidateSize();
			invalidateDisplayList();        
		} 
		ns_egret function clearGridLayoutCache(clearTypicalSizes:Boolean):void
		{
			gridLayout.clearVirtualLayoutCache();
			
			var gridDimensions:GridDimensions = this.gridDimensions;
			if (gridDimensions)
			{
				if (clearTypicalSizes)
					gridDimensions.clearTypicalCellWidthsAndHeights();
				
				gridDimensions.clearHeights();
				gridDimensions.rowCount = _dataProvider ? _dataProvider.length : 0;
			}
			setContentSize(0, 0);
		}
		ns_egret function getNextVisibleColumnIndex(index:int=-1):int
		{
			if (index < -1)
				return -1;
			
			var columns:ICollection = this.columns;
			var columnsLength:int = (columns) ? columns.length : 0;
			
			for (var i:int = index + 1; i < columnsLength; i++)
			{
				var column:GridColumn = columns.getItemAt(i) as GridColumn;
				if (column && column.visible)
					return i;
			}
			
			return -1;
		}
		
		ns_egret function getPreviousVisibleColumnIndex(index:int):int
		{
			var columns:ICollection = this.columns;
			if (!columns || index > columns.length)
				return -1;
			
			for (var i:int = index - 1; i >= 0; i--)
			{
				var column:GridColumn = columns.getItemAt(i) as GridColumn;
				if (column && column.visible)
					return i;
			}
			
			return -1;
		}
		private function initializeAnchorPosition(columnOnly:Boolean=false):void
		{
			if (!columnOnly)
				anchorRowIndex = _dataProvider && _dataProvider.length > 0 ? 0 : -1; 
			anchorColumnIndex = getNextVisibleColumnIndex(); 
		}
		private function initializeCaretPosition(columnOnly:Boolean=false):void
		{
			if (!columnOnly)
				caretRowIndex = _dataProvider && _dataProvider.length > 0 ? 0 : -1;
			caretColumnIndex = getNextVisibleColumnIndex();
		}
		private function dispatchCaretChangeEvent():void
		{
			if (hasEventListener(GridCaretEvent.CARET_CHANGE))
			{
				var caretChangeEvent:GridCaretEvent = 
					new GridCaretEvent(GridCaretEvent.CARET_CHANGE);
				caretChangeEvent.oldRowIndex = _oldCaretRowIndex;
				caretChangeEvent.oldColumnIndex = _oldCaretColumnIndex;
				caretChangeEvent.newRowIndex = _caretRowIndex;
				caretChangeEvent.newColumnIndex = _caretColumnIndex;
				dispatchEvent(caretChangeEvent);
			}
		}
	}
}
