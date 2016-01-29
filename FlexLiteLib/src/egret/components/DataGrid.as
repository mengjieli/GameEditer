package egret.components
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import egret.collections.ICollection;
	import egret.collections.ICollectionView;
	import egret.components.gridClasses.CellPosition;
	import egret.components.gridClasses.CellRegion;
	import egret.components.gridClasses.DataGridEditor;
	import egret.components.gridClasses.GridColumn;
	import egret.components.gridClasses.GridLayout;
	import egret.components.gridClasses.GridSelection;
	import egret.components.gridClasses.GridSelectionMode;
	import egret.components.gridClasses.IDataGridElement;
	import egret.components.gridClasses.IGridItemEditor;
	import egret.core.NavigationUnit;
	import egret.core.UIComponent;
	import egret.core.ns_egret;
	import egret.events.GridCaretEvent;
	import egret.events.GridEvent;
	import egret.events.GridSelectionEvent;
	import egret.events.GridSelectionEventKind;
	import egret.events.GridSortEvent;
	import egret.events.UIEvent;
	
	use namespace ns_egret;
	
	/**
	 * 标识符改变
	 */	
	[Event(name="caretChange", type="egret.events.GridCaretEvent")]
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
	 * 选择要改变
	 */
	[Event(name="selectionChanging", type="egret.events.GridSelectionEvent")]
	/**
	 * 选择改变了 
	 */
	[Event(name="selectionChange", type="egret.events.GridSelectionEvent")]
	/**
	 * 排序要改变 
	 */	
	[Event(name="sortChanging", type="egret.events.GridSortEvent")]
	/**
	 * 排序改变了 
	 */	
	[Event(name="sortChange", type="egret.events.GridSortEvent")]
	/**
	 * 数据单元 要开始编辑
	 */	
	[Event(name="gridItemEditorSessionStarting", type="egret.events.GridItemEditorEvent")]
	/**
	 * 数据单元开始编辑 
	 */	
	[Event(name="gridItemEditorSessionStart", type="egret.events.GridItemEditorEvent")]
	/**
	 * 数据单元编辑保存 
	 */	
	[Event(name="gridItemEditorSessionSave", type="egret.events.GridItemEditorEvent")]
	/**
	 * 数据单元编辑取消 
	 */	
	[Event(name="gridItemEditorSessionCancel", type="egret.events.GridItemEditorEvent")]
	/**
	 * <p>DataGrid 在可滚动网格上方显示一行列标题。支持大量行和列之间的平滑滚动。</p>
	 * 
	 * <p>DataGrid 控件实现为包装 Grid 控件的可更换外观的包装器。
	 * Grid 控件定义数据网格的列，以及 DataGrid 控件自身的大部分功能。</p>
	 * 
	 * <p>DataGrid 外观负责布置网格、列标题和滚动条。
	 * 外观也配置用于显示可视元素（用作指示器、分隔符和背景）的图形元素。
	 * DataGrid 外观也定义默认项渲染器，用于显示每个单元格的内容。</p>
	 * 
	 * <p>不支持 DataGrid 项呈示器中的转换。
	 * GridItemRenderer 类已禁用了其 transitions 属性，因此对此进行设置也无效。</p>
	 */	
	public class DataGrid extends SkinnableComponent 
	{
		public function DataGrid()
		{
			super();
			addEventListener(Event.SELECT_ALL, selectAllHandler);
		}
		/**
		 * true表示悬停时事件ROLL_OVER的侦听器。当鼠标在表格外按下的时候，hover事件将不再生效，
		 * 直到触发了MOUSE_UP 或者ROLL_OUT事件。
		 */		
		private var updateHoverOnRollOver:Boolean = true;
		/**
		 * [SkinPart]这个可视化元素模板类用于渲染交替行颜色alternatingRowColors;
		 */		
		public var alternatingRowColorsBackground:Class;
		/**
		 * [SkinPart]这个可视化元素模板类用于渲染表格的符号标志
		 */		
		public var caretIndicator:Class;
		/**
		 * [SkinPart]GridColumnHeaderGroup表格列的表头部分。用于呈现列的标题
		 */		
		public var columnHeaderGroup:GridColumnHeaderGroup;  
		/**
		 * [SkinPart]用于渲染列和列之间的纵向分割线的可视元素
		 */		
		public var columnSeparator:Class;
		/**
		 * [SkinPart]用于渲染单元格处于编辑状态时候的背景。
		 */		
		public var editorIndicator:Class;
		/**
		 * [SkinPart]用于显示行和列的表格控制器
		 */		
		public var grid:Grid;    
		/**
		 * [SkinPart]用于显示在hover状态时候的背景
		 */		
		public var hoverIndicator:Class;
		/**
		 * [SkinPart]用于渲染每一行的背景 
		 */		
		public var rowBackground:Class;        
		/**
		 * [SkinPart]行和行之间的水平分割线 
		 */		
		public var rowSeparator:Class;
		/**
		 *  [SkinPart]DataGrid的滚动条。
		 */		
		public var scroller:Scroller;    
		/**
		 * [SkinPart]一行或一个数据单元被选中时候呈现的样子
		 */		
		public var selectionIndicator:Class;
		
		private var alternatingRowColorsChanged:Boolean = false;
		
		private var _alternatingRowColors:Array
		
		public function get alternatingRowColors():Array
		{
			return _alternatingRowColors;
		}
		
		public function set alternatingRowColors(value:Array):void
		{
			if(_alternatingRowColors==value)
				return;
			_alternatingRowColors = value;
			alternatingRowColorsChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(alternatingRowColorsChanged)
			{
				alternatingRowColorsChanged = true;
				initializeGridRowBackground();
				if (grid && grid.layout)
					grid.layout.clearVirtualLayoutCache(); 
			}
		}
		
		/**
		 * 如果alternatingRowColors的样式被赋值并且alternatingRowColorsBackground皮肤部件已经被添加并且grid的皮肤部件已经被添加，那么
		 * 设置grid.rowBackground = alternatingRowColorsBackground，否则设置它为rowBackground。
		 * 
		 */		
		private function initializeGridRowBackground():void
		{
			if (!grid)
				return;
			
			if (alternatingRowColors && alternatingRowColorsBackground)
				grid.rowBackground = alternatingRowColorsBackground;
			else
				grid.rowBackground = rowBackground;
		}
		/**
		 * 在partAdded()的时候调用的一组回调方法列表。
		 * 这组回调方法用于延时表格选择项的更新。
		 */		
		private var deferredGridOperations:Vector.<Function> = new Vector.<Function>();
		
		/**
		 * 定义被DataGrid覆盖的每一个皮肤控件的位掩码。
		 */		
		private static var partPropertyBits:Object = {
			columns: uint(1 << 0),
			dataProvider: uint(1 << 1),
			itemRenderer: uint(1 << 2),
			requestedRowCount: uint(1 << 3),
			requestedColumnCount: uint(1 << 4),
			requestedMaxRowCount: uint(1 << 5),
			requestedMinRowCount: uint(1 << 6),
			requestedMinColumnCount: uint(1 << 7),
			rowHeight: uint(1 << 8),
			showDataTips: uint(1 << 9),
			typicalItem: uint(1 << 10),
			variableRowHeight: uint(1 << 11),
			dataTipField: uint(1 << 12),
			dataTipFunction: uint(1 << 13),
			resizableColumns: uint(1 << 14)
		};
		
		/**
		 * 如果grid皮肤控件还没有被添加上，这个对象就用来把所有表格的数据先都缓存下来。
		 * 然后等到grid皮肤控件被添加上的时候，根据位掩码数据把缓存下来的所有表格数据再赋值到表格上。
		 */		
		private var gridProperties:Object = new Object();
		
		/**
		 * grid皮肤部件的默认值。
		 */		
		private static var gridPropertyDefaults:Object = {
			columns: null,
			dataProvider: null,
			itemRenderer: null,
			resizableColumns: true,
			requestedRowCount: int(-1),
			requestedMaxRowCount: int(10),        
			requestedMinRowCount: int(-1),
			requestedColumnCount: int(-1),
			requestedMinColumnCount: int(-1),
			rowHeight: NaN,
			showDataTips: false,
			typicalItem: null,
			variableRowHeight: false,
			dataTipField: null,
			dataTipFunction: null
		};
		/**
		 * 查找皮肤控件属性的工具。
		 * @param part
		 * @param properties
		 * @param propertyName
		 * @param defaults
		 * @return 
		 * 
		 */		
		private static function getPartProperty(part:Object, properties:Object, propertyName:String, defaults:Object):*
		{
			if (part)
				return part[propertyName];
			
			var value:* = properties[propertyName];
			return (value === undefined) ? defaults[propertyName] : value;
		}
		/**
		 * 用来给皮肤部件属性赋值的工具方法， 如果已存在这个属性，就直接覆盖掉。
		 * 
		 * 如果赋值使控件属性值改变了，就返回true。
		 * @param part
		 * @param properties
		 * @param propertyName
		 * @param value
		 * @param defaults
		 * @return 
		 * 
		 */		
		private static function setPartProperty(part:Object, properties:Object, propertyName:String, value:*, defaults:Object):Boolean
		{
			if (getPartProperty(part, properties, propertyName, defaults) === value)
				return false;
			
			var defaultValue:* = defaults[propertyName];
			
			if (part)
			{
				part[propertyName] = value;
				if (value === defaultValue)
					properties.propertyBits &= ~partPropertyBits[propertyName];
				else
					properties.propertyBits |= partPropertyBits[propertyName];
			}
			else
			{
				if (value === defaultValue)
					delete properties[propertyName];
				else
					properties[propertyName] = value;
			}
			
			return true;
		}
		/**
		 * 返回grid的指定属性 
		 * @param propertyName
		 * @return 
		 * 
		 */		
		private function getGridProperty(propertyName:String):*
		{
			return getPartProperty(grid, gridProperties, propertyName, gridPropertyDefaults);
		}
		/**
		 * 设置grid的指定属性，并返回是否改变成功了
		 * @param propertyName
		 * @param value
		 * @return 
		 * 
		 */		
		private function setGridProperty(propertyName:String, value:*):Boolean
		{
			return setPartProperty(grid, gridProperties, propertyName, value, gridPropertyDefaults);
		}    
		/**
		 * 是否第一次鼠标在单元格上弹起时立即进入编辑模式。默认为true。
		 */		
		public var editOnMouseUp:Boolean = true;
		/**
		 *  双击的毫秒级时间范围
		 */		
		ns_egret var doubleClickTime:Number = 620;
		/**
		 *  是否通过快捷键去激活数据单元的可编辑
		 */		
		ns_egret var editKey:uint = Keyboard.F2;
		/**
		 * 是双击编辑还是单击编辑 
		 */		
		ns_egret var editOnDoubleClick:Boolean = false;
		/**
		 * 提供从编辑到结束编辑的所有逻辑。
		 * 通过重写createEditor()创建一个编辑器，
		 */		
		ns_egret var editor:DataGridEditor;
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
		/**
		 *  
		 * @copy egret.components.Grid#columns
		 * 
		 */		
		public function get columns():ICollection
		{
			return getGridProperty("columns");
		}
		public function set columns(value:ICollection):void
		{
			if (setGridProperty("columns", value))
			{
				if (columnHeaderGroup)
				{
					columnHeaderGroup.layout.clearVirtualLayoutCache();
					columnHeaderGroup.invalidateSize();
					columnHeaderGroup.invalidateDisplayList();
				}
				
				dispatchChangeEvent("columnsChanged");
			}
		}
		private function getColumnAt(columnIndex:int):GridColumn
		{
			var grid:Grid = this.grid;
			if (!grid || !grid.columns)
				return null;
			
			var columns:ICollection = grid.columns;
			return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
		}
		/**
		 *  如果列 IList 已指定，将返回 columns.length 值，否则为 0。 
		 */		
		public function get columnsLength():int
		{
			var columns:ICollection = this.columns;
			return (columns) ? columns.length : 0;
		}    
		/**
		 * @copy egret.components.Grid#dataProvider 
		 */		
		public function get dataProvider():ICollection
		{
			return getGridProperty("dataProvider");
		}
		public function set dataProvider(value:ICollection):void
		{
			if (setGridProperty("dataProvider", value))
				dispatchChangeEvent("dataProviderChanged");
		}
		/**
		 * 如果 dataProvider IList 已指定，将返回 dataProvider.length 值，否则为 0。
		 */		
		public function get dataProviderLength():int
		{
			var dataProvider:ICollection = this.dataProvider;
			return (dataProvider) ? dataProvider.length : 0;
		}   
		/**
		 * @copy egret.components.Grid#dataTipField 
		 */		
		public function get dataTipField():String
		{
			return getGridProperty("dataTipField");
		}
		public function set dataTipField(value:String):void
		{
			if (setGridProperty("dataTipField", value))
				dispatchChangeEvent("dataTipFieldChanged");
		} 
		/**
		 * @copy egret.components.Grid#dataTipFunction 
		 */		
		public function get dataTipFunction():Function
		{
			return getGridProperty("dataTipFunction");
		}
		public function set dataTipFunction(value:Function):void
		{
			if (setGridProperty("dataTipFunction", value))
				dispatchChangeEvent("dataTipFunctionChanged");
		}        
		private var _editable:Boolean = false;
		/**
		 * GridColumn editable 属性的默认值，指示是否可以编辑对应单元格的数据提供程序项。
		 * 如果为 true，单击所选单元格将打开项编辑器。您可以通过处理 startItemEditorSession 
		 * 事件来启用或禁用编辑每个单元格（而不是每个列）。在事件处理函数中，
		 * 添加所需逻辑以确定单元格是否可编辑。 
		 * @return 
		 * 
		 */		
		public function get editable():Boolean
		{
			return _editable;
		}
		public function set editable(value:Boolean):void
		{
			_editable = value;
		}
		/**
		 * 正在编辑的单元格的从零开始的列索引。如果没有正在编辑任何单元格，值为 -1。 
		 */		
		public function get editorColumnIndex():int
		{
			if (editor)
				return editor.editorColumnIndex;
			
			return -1;
		}
		/**
		 * 正在编辑的单元格的从零开始的行索引。如果没有正在编辑任何单元格，值为 -1。
		 */		
		public function get editorRowIndex():int
		{
			if (editor)
				return editor.editorRowIndex;
			
			return -1;
		}
		/**
		 * 一个标志，用于指示当组件获得焦点时是否应启用 IME。如果项编辑器已打开，则会相应设置该属性。 
		 */		
		public function get enableIME():Boolean
		{
			return false;
		}
		private var _gridSelection:GridSelection = null;
		/**
		 * 当grid皮肤部件被添加之后，这个对象便变成了grid的gridSelection属性。
		 */		
		protected function get gridSelection():GridSelection
		{
			if (!_gridSelection)
				_gridSelection = createGridSelection();
			return _gridSelection;
		}
		private var _itemEditor:Class = null;
		/**
		 * <p>GridColumn itemEditor 属性的默认值，用于指定创建项编辑器实例所用的 IGridItemEditor 类。</p>
		 * <p>此属性可用作数据绑定的源代码。</p>
		 */		
		public function get itemEditor():Class
		{
			return _itemEditor;
		}
		public function set itemEditor(value:Class):void
		{
			if (_itemEditor == value)
				return;
			
			_itemEditor = value;
			
			dispatchChangeEvent("itemEditorChanged");
		}    
		/**
		 * <p>对项目编辑器的当前活动实例（如果有）的引用。 </p>
		 * 
		 * <p>若要在编辑项目时访问项目编辑器实例和新项目值，则应使用 itemEditorInstance 属性。
		 * 在分派 itemEditorSessionStart 事件之前，itemEditorInstance 属性无效。</p>
		 * 
		 * <p>DataGridColumn.itemEditor 属性定义项目编辑器的类，从而定义项目编辑器实例的数据类型。</p>
		 */		
		public function get itemEditorInstance():IGridItemEditor
		{
			if (editor)
				return editor.itemEditorInstance;
			
			return null; 
		}
		/**
		 * @copy egret.components.Grid#itemRenderer 
		 */		
		public function get itemRenderer():Class
		{
			return getGridProperty("itemRenderer");
		}
		public function set itemRenderer(value:Class):void
		{
			if (setGridProperty("itemRenderer", value))
				dispatchChangeEvent("itemRendererChanged");
		} 
		/**
		 * @copy egret.components.Grid#preserveSelection 
		 */		
		public function get preserveSelection():Boolean
		{
			if (grid)
				return grid.preserveSelection;
			else
				return gridSelection.preserveSelection;
		}
		public function set preserveSelection(value:Boolean):void
		{
			if (grid)
				grid.preserveSelection = value;
			else
				gridSelection.preserveSelection = value;
		}
		/**
		 * @copy egret.components.Grid#requireSelection
		 */		
		public function get requireSelection():Boolean
		{
			if (grid)
				return grid.requireSelection;
			else
				return gridSelection.requireSelection;
		}
		public function set requireSelection(value:Boolean):void
		{
			if (grid)
				grid.requireSelection = value;
			else
				gridSelection.requireSelection = value;
		}
		/**
		 * @copy egret.components.Grid#requestedRowCount 
		 */		
		public function get requestedRowCount():int
		{
			return getGridProperty("requestedRowCount");
		}
		public function set requestedRowCount(value:int):void
		{
			setGridProperty("requestedRowCount", value);
		}
		/**
		 * @copy egret.components.Grid#requestedColumnCount 
		 * @return 
		 * 
		 */		
		public function get requestedColumnCount():int
		{
			return getGridProperty("requestedColumnCount");
		}
		public function set requestedColumnCount(value:int):void
		{
			setGridProperty("requestedColumnCount", value);
		}
		/**
		 * @copy egret.components.Grid#requestedMaxRowCount
		 */		
		public function get requestedMaxRowCount():int
		{
			return getGridProperty("requestedMaxRowCount");
		}
		public function set requestedMaxRowCount(value:int):void
		{
			setGridProperty("requestedMaxRowCount", value);
		}
		/**
		 * @copy egret.components.Grid#requestedMinRowCount
		 */	
		public function get requestedMinRowCount():int
		{
			return getGridProperty("requestedMinRowCount");
		}
		public function set requestedMinRowCount(value:int):void
		{
			setGridProperty("requestedMinRowCount", value);
		}
		/**
		 * @copy egret.components.Grid#requestedMinColumnCount 
		 */		
		public function get requestedMinColumnCount():int
		{
			return getGridProperty("requestedMinColumnCount");
		}
		public function set requestedMinColumnCount(value:int):void
		{
			setGridProperty("requestedMinColumnCount", value);
		}
		/**
		 * @copy egret.components.Grid#resizableColumns
		 */		
		public function get resizableColumns():Boolean
		{
			return getGridProperty("resizableColumns");
		}
		public function set resizableColumns(value:Boolean):void
		{
			if (setGridProperty("resizableColumns", value))
				dispatchChangeEvent("resizableColumnsChanged");
		}  
		/**
		 * @copy egret.components.Grid#rowHeight 
		 */		
		public function get rowHeight():Number
		{
			return getGridProperty("rowHeight");
		}
		public function set rowHeight(value:Number):void
		{
			if (setGridProperty("rowHeight", value))
				dispatchChangeEvent("rowHeightChanged");
		}    
		/**
		 * @copy egret.components.Grid#selectionMode 
		 */		
		public function get selectionMode():String
		{
			if (grid)
				return grid.selectionMode;
			else
				return gridSelection.selectionMode;
		}
		public function  set selectionMode(value:String):void
		{
			if (selectionMode == value)
				return;
			
			if (grid)
				grid.selectionMode = value;
			else
				gridSelection.selectionMode = value;
			if (grid && grid.layout is GridLayout &&
				caretIndicator)
			{
				GridLayout(grid.layout).showCaret = (value != GridSelectionMode.NONE && stage&&
					this == stage.focus);
			}
			
			dispatchChangeEvent("selectionModeChanged");
		}
		ns_egret function isRowSelectionMode():Boolean
		{
			var mode:String = this.selectionMode;
			return mode == GridSelectionMode.SINGLE_ROW || mode == GridSelectionMode.MULTIPLE_ROWS;
		}
		ns_egret function isCellSelectionMode():Boolean
		{
			var mode:String = this.selectionMode;        
			return mode == GridSelectionMode.SINGLE_CELL || mode == GridSelectionMode.MULTIPLE_CELLS;
		}
		/**
		 * @copy egret.components.Grid#showDataTips
		 */		
		public function get showDataTips():Boolean
		{
			return getGridProperty("showDataTips");
		}
		public function set showDataTips(value:Boolean):void
		{
			if (setGridProperty("showDataTips", value))
				dispatchChangeEvent("showDataTipsChanged");
		}    
		private var _sortableColumns:Boolean = true;
		/**
		 * 指定用户是否可以交互对列进行排序。如果为 true，用户可以通过单击列标题，
		 * 按列的数据字段对数据提供程序进行排序。如果为 true，
		 * 则单个列可以将其 sortable 属性设置为 false，以防止用户按该列排序。 
		 * @return 
		 * 
		 */		
		public function get sortableColumns():Boolean
		{
			return _sortableColumns;
		}
		public function set sortableColumns(value:Boolean):void
		{
			if (_sortableColumns == value)
				return;
			
			_sortableColumns = value;
			dispatchChangeEvent("sortableColumnsChanged");
		} 
		/**
		 * @copy egret.components.Grid#typicalItem
		 */		
		public function get typicalItem():Object
		{
			return getGridProperty("typicalItem");
		}
		public function set typicalItem(value:Object):void
		{
			if (setGridProperty("typicalItem", value))
				dispatchChangeEvent("typicalItemChanged");
		}
		/**
		 * @copy egret.components.Grid#invalidateTypicalItemRenderer() 
		 */		
		public function invalidateTypicalItem():void
		{
			if (grid)
				grid.invalidateTypicalItemRenderer();
		}
		/**
		 * @copy egret.components.Grid#variableRowHeight
		 */		
		public function get variableRowHeight():Boolean
		{
			return getGridProperty("variableRowHeight");
		}
		public function set variableRowHeight(value:Boolean):void
		{
			if (setGridProperty("variableRowHeight", value))
				dispatchChangeEvent("variableRowHeightChanged");
		}     
		/**
		 * 这个控件用来保持焦点
		 */		
		ns_egret var focusOwner:UIComponent;
		/**
		 * 基于focusOwner控件的DisplayObject.getBounds()得到的尺寸实现的。
		 */		
		private var focusOwnerWidth:Number = 1;
		private var focusOwnerHeight:Number = 1;
		override protected function createChildren():void
		{
			super.createChildren();
			
			focusOwner = new UIComponent();
			var g:Graphics = focusOwner.graphics;
			g.clear();
			g.lineStyle(0, 0x000000, 0);
			g.drawRect(0, 0, focusOwnerWidth, focusOwnerHeight);
			addToDisplayList(focusOwner);
			focusOwner.tabEnabled = true;
			focusOwner.tabIndex = tabIndex;
			focusOwner.visible = true;
		}
		
		override public function set nestLevel(value:int):void
		{
			super.nestLevel = value;
			
			if (grid)
				initializeDataGridElement(columnHeaderGroup);
		}
		
		override public function set tabIndex(index:int):void
		{
			super.tabIndex = index;
			if (focusOwner)
				focusOwner.tabIndex = index;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (focusOwner && ((focusOwnerWidth != unscaledWidth) || (focusOwnerHeight != unscaledHeight)))
			{
				focusOwnerWidth = unscaledWidth;
				focusOwnerHeight = unscaledHeight;
				var g:Graphics = focusOwner.graphics;
				g.clear();
				g.lineStyle(0, 0x000000, 0);
				g.drawRect(0, 0, focusOwnerWidth, focusOwnerHeight);        
			}
		}
		
		override public function setFocus():void
		{
			if (grid)
				focusOwner.setFocus();
		}
		
		private function isOurFocus(target:DisplayObject):Boolean
		{
			return (target == focusOwner) || target == this;
		}    
		
		/**
		 * 用来放置键盘事件的冒泡事件再次触发
		 */		
		private var scrollerEvent:KeyboardEvent = null;
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (!grid || event.isDefaultPrevented())
				return;
			if (event == scrollerEvent)
			{
				scrollerEvent = null;
				event.preventDefault();
				return;
			}
			if (!isOurFocus(DisplayObject(event.target)))
				return;
			if (event.keyCode == Keyboard.A && event.ctrlKey)
			{ 
				selectAllFromKeyboard();
				event.preventDefault();
				return;
			}
			if (selectionMode == GridSelectionMode.NONE || 
				grid.caretRowIndex < 0 || 
				grid.caretRowIndex >= dataProviderLength ||
				(isCellSelectionMode() && 
					(grid.caretColumnIndex < 0 || grid.caretColumnIndex >= columnsLength)))
			{
				
				if (scroller && (scrollerEvent != event))
				{
					scrollerEvent = event.clone() as KeyboardEvent;
					scroller.dispatchEvent(scrollerEvent);
				}
				return;
			}
			
			var op:String;
			if (event.keyCode == Keyboard.SPACE)
			{
				if (event.ctrlKey)
				{
					if (toggleSelection(grid.caretRowIndex, grid.caretColumnIndex))
					{
						grid.anchorRowIndex = grid.caretRowIndex;
						grid.anchorColumnIndex = grid.caretColumnIndex;
						event.preventDefault();                
					}
				}
				else if (event.shiftKey)
				{
					
					if (extendSelection(grid.caretRowIndex, grid.caretColumnIndex))
						event.preventDefault();                
				}
				else
				{
					if (grid.caretRowIndex != -1)
					{
						if (isRowSelectionMode())
						{
							op = selectionMode == GridSelectionMode.SINGLE_ROW ?
								GridSelectionEventKind.SET_ROW :
								GridSelectionEventKind.ADD_ROW;
							if (!commitInteractiveSelection(
								op, grid.caretRowIndex, grid.caretColumnIndex))
							{
								return;
							}
							event.preventDefault();                
						}
						else if (isCellSelectionMode() && grid.caretColumnIndex != -1)
						{
							op = selectionMode == GridSelectionMode.SINGLE_CELL ?
								GridSelectionEventKind.SET_CELL :
								GridSelectionEventKind.ADD_CELL;
							if (!commitInteractiveSelection(
								op, grid.caretRowIndex, grid.caretColumnIndex))
							{
								return;
							}
							event.preventDefault();                
						}
					}
				}
				return;
			}
			adjustSelectionUponNavigation(event);
		}
		
		/**
		 * 在windows上市ctrl-a，在mac上市cmd-a 
		 * @param event
		 * 
		 */		
		protected function selectAllHandler(event:Event):void
		{
			
			if (!grid || event.isDefaultPrevented() || 
				!isOurFocus(DisplayObject(event.target)))
			{
				return;
			}
			
			selectAllFromKeyboard();
		}
		private function selectAllFromKeyboard():void
		{
			
			if (selectionMode == GridSelectionMode.MULTIPLE_CELLS || 
				selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				if (commitInteractiveSelection(
					GridSelectionEventKind.SELECT_ALL,
					0, 0, dataProvider.length, columns.length))
				{
					grid.anchorRowIndex = 0;
					grid.anchorColumnIndex = 0;
				}
			}
		}
		
		private function initializeDataGridElement(elt:IDataGridElement):void
		{
			if (!elt)
				return;
			
			elt.dataGrid = this;
			if (elt.nestLevel <= grid.nestLevel)
				elt.nestLevel = grid.nestLevel + 1;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == grid)
			{
				gridSelection.grid = grid;
				grid.gridSelection = gridSelection;
				grid.dataGrid = this;
				var modifiedGridProperties:Object = this.gridProperties;  
				this.gridProperties = {propertyBits:0};
				
				for (var propertyName:String in modifiedGridProperties)
				{
					if (propertyName == "propertyBits")
						continue;
					setGridProperty(propertyName, modifiedGridProperties[propertyName]);
				}
				initializeGridRowBackground(); 
				grid.columnSeparator = columnSeparator;
				grid.rowSeparator = rowSeparator;
				grid.hoverIndicator = hoverIndicator;
				grid.caretIndicator = caretIndicator;
				grid.selectionIndicator = selectionIndicator;
				grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, grid_mouseDownHandler, false, -50);
				grid.addEventListener(GridEvent.GRID_MOUSE_UP, grid_mouseUpHandler, false, -50);
				
				grid.addEventListener(GridEvent.GRID_ROLL_OVER, grid_rollOverHandler, false, -50);
				grid.addEventListener(GridEvent.GRID_ROLL_OUT, grid_rollOutHandler, false, -50);
				
				grid.addEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
				grid.addEventListener(UIEvent.VALUE_COMMIT, grid_valueCommitHandler);
				grid.addEventListener("invalidateSize", grid_invalidateSizeHandler);            
				grid.addEventListener("invalidateDisplayList", grid_invalidateDisplayListHandler);
				for each (var deferredGridOperation:Function in deferredGridOperations)
				deferredGridOperation(grid);
				deferredGridOperations.length = 0;
				initializeDataGridElement(columnHeaderGroup);
				editor = createEditor();
				editor.initialize();                               
			}
			
			if (instance == alternatingRowColorsBackground)
				initializeGridRowBackground();
			
			if (grid)
			{
				if (instance == columnSeparator) 
					grid.columnSeparator = columnSeparator;
				
				if (instance == rowSeparator) 
					grid.rowSeparator = rowSeparator;
				
				if (instance == hoverIndicator) 
					grid.hoverIndicator = hoverIndicator;
				
				if (instance == caretIndicator)
				{                
					grid.caretIndicator = caretIndicator;
					addEventListener(FocusEvent.FOCUS_IN, dataGrid_focusHandler);
					addEventListener(FocusEvent.FOCUS_OUT, dataGrid_focusHandler);
					if (grid && grid.layout is GridLayout)
						GridLayout(grid.layout).showCaret = false;
				}
				
				if (instance == rowBackground)
					grid.rowBackground = rowBackground;
				
				if (instance == selectionIndicator) 
					grid.selectionIndicator = selectionIndicator;
				
			}
			
			if (instance == columnHeaderGroup)
			{
				if (grid)
					initializeDataGridElement(columnHeaderGroup);
				
				columnHeaderGroup.addEventListener(GridEvent.GRID_CLICK, columnHeaderGroup_clickHandler);
				columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_ROLL_OVER, separator_rollOverHandler);
				columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_ROLL_OUT, separator_rollOutHandler);
				columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_DOWN, separator_mouseDownHandler);
				columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_DRAG, separator_mouseDragHandler);
				columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_UP, separator_mouseUpHandler);  
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == grid)
			{
				gridSelection.grid = null;
				grid.gridSelection = null;
				grid.dataGrid = null;            
				grid.removeEventListener("invalidateSize", grid_invalidateSizeHandler);            
				grid.removeEventListener("invalidateDisplayList", grid_invalidateDisplayListHandler);
				grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, grid_mouseDownHandler);
				grid.removeEventListener(GridEvent.GRID_MOUSE_UP, grid_mouseUpHandler);
				grid.removeEventListener(GridEvent.GRID_ROLL_OVER, grid_rollOverHandler);
				grid.removeEventListener(GridEvent.GRID_ROLL_OUT, grid_rollOutHandler);            
				grid.removeEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
				grid.removeEventListener(UIEvent.VALUE_COMMIT, grid_valueCommitHandler);
				var gridPropertyBits:uint = gridProperties.propertyBits;
				gridProperties = new Object();
				
				for (var propertyName:String in gridPropertyDefaults)
				{
					var propertyBit:uint = partPropertyBits[propertyName];
					if ((propertyBit & gridPropertyBits) == propertyBit)
						gridProperties[propertyName] = getGridProperty(propertyName);                
				}
				grid.rowBackground = null;
				grid.columnSeparator = null;
				grid.rowSeparator = null;
				grid.hoverIndicator = null;
				grid.caretIndicator = null;
				grid.selectionIndicator = null;
				if (columnHeaderGroup)
					columnHeaderGroup.dataGrid = null; 
				if (editor)
				{
					editor.uninitialize();
					editor = null;
				}
			}
			
			if (grid)
			{
				if (instance == columnSeparator) 
					grid.columnSeparator = null;
				
				if (instance == rowSeparator) 
					grid.rowSeparator = null;
				
				if (instance == hoverIndicator) 
					grid.hoverIndicator = null;
				
				if (instance == caretIndicator)
				{
					grid.caretIndicator = null;
					
					removeEventListener(FocusEvent.FOCUS_IN, dataGrid_focusHandler);
					removeEventListener(FocusEvent.FOCUS_OUT, dataGrid_focusHandler);
				}
				
				if (instance == selectionIndicator) 
					grid.selectionIndicator = null;
				
				if (instance == rowBackground)
					grid.rowBackground = null;
			}
			
			if (instance == columnHeaderGroup)
			{
				columnHeaderGroup.dataGrid = null;
				columnHeaderGroup.removeEventListener(GridEvent.GRID_CLICK, columnHeaderGroup_clickHandler);
				columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_ROLL_OVER, separator_rollOverHandler);
				columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_ROLL_OUT, separator_rollOutHandler);
				columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_DOWN, separator_mouseDownHandler);
				columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_DRAG, separator_mouseDragHandler);
				columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_UP, separator_mouseUpHandler);             
			}
		}
		/**
		 * @copy egret.components.Grid#selectedCell 
		 */		
		public function get selectedCell():CellPosition
		{
			if (grid)
				return grid.selectedCell;
			
			return selectedCells.length ? selectedCells[0] : null;
		}
		public function set selectedCell(value:CellPosition):void
		{
			if (grid)
				grid.selectedCell = value;
			else
			{
				var valueCopy:CellPosition = (value) ? new CellPosition(value.rowIndex, value.columnIndex) : null;
				
				var f:Function = function(g:Grid):void
				{
					g.selectedCell = valueCopy;
				}
				deferredGridOperations.push(f);
			}
		}    
		/**
		 * @copy egret.components.Grid#selectedCells 
		 */		
		public function get selectedCells():Vector.<CellPosition>
		{
			return grid ? grid.selectedCells : gridSelection.allCells();
		}
		public function set selectedCells(value:Vector.<CellPosition>):void
		{
			if (grid)
				grid.selectedCells = value;
			else
			{
				var valueCopy:Vector.<CellPosition> = (value) ? value.concat() : null;
				var f:Function = function(g:Grid):void
				{
					g.selectedCells = valueCopy;
				}
				deferredGridOperations.push(f);
			}
		}       
		
		/**
		 * @copy egret.components.Grid#selectedIndex 
		 */		
		public function get selectedIndex():int
		{
			if (grid)
				return grid.selectedIndex;
			
			return (selectedIndices.length > 0) ? selectedIndices[0] : -1;
		}
		public function set selectedIndex(value:int):void
		{
			if (grid)
				grid.selectedIndex = value;
			else
			{
				var f:Function = function(g:Grid):void
				{
					g.selectedIndex = value;
				}
				deferredGridOperations.push(f);
			}
		}
		/**
		 * @copy egret.components.Grid#selectedIndices 
		 */		
		public function get selectedIndices():Vector.<int>
		{
			return grid ? grid.selectedIndices : gridSelection.allRows();
		}
		public function set selectedIndices(value:Vector.<int>):void
		{
			if (grid)
				grid.selectedIndices = value;
			else
			{
				var valueCopy:Vector.<int> = (value) ? value.concat() : null;
				var f:Function = function(g:Grid):void
				{
					g.selectedIndices = valueCopy;
				}
				deferredGridOperations.push(f);
			}
		}    
		/**
		 * @copy egret.components.Grid#selectedItem 
		 */		
		public function get selectedItem():Object
		{
			if (grid)
				return grid.selectedItem;
			
			return (dataProvider && (selectedIndex > 0)) ? 
				dataProvider.getItemAt(selectedIndex) : undefined;
		}
		public function set selectedItem(value:Object):void
		{
			if (grid)
				grid.selectedItem = value;
			else
			{
				var f:Function = function(g:Grid):void
				{
					g.selectedItem = value;
				}
				deferredGridOperations.push(f);
			}
		}    
		/**
		 * @copy egret.components.Grid#selectedItems
		 */		
		public function get selectedItems():Vector.<Object>
		{
			if (grid)
				return grid.selectedItems;
			
			var items:Vector.<Object> = new Vector.<Object>();
			
			for (var i:int = 0; i < selectedIndices.length; i++)
				items.push(selectedIndices[i]);
			
			return items;
		}
		public function set selectedItems(value:Vector.<Object>):void
		{
			if (grid)
				grid.selectedItems = value;
			else
			{
				var valueCopy:Vector.<Object> = value.concat();
				var f:Function = function(g:Grid):void
				{
					g.selectedItems = valueCopy;
				}
				deferredGridOperations.push(f);
			}
		}      
		/**
		 * @copy egret.components.Grid#selectionLength
		 */		
		public function get selectionLength():int
		{
			return grid ? grid.selectionLength : gridSelection.selectionLength;
		}    
		/**
		 * @copy egret.components.Grid#invalidateCell()
		 */		
		public function invalidateCell(rowIndex:int, columnIndex:int):void
		{
			if (grid)
				grid.invalidateCell(rowIndex, columnIndex);
		}
		/**
		 * @copy egret.components.Grid#selectAll()
		 */		
		public function selectAll():Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.selectAll();
			}
			else
			{
				selectionChanged = gridSelection.selectAll();
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#clearSelection() 
		 */		
		public function clearSelection():Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.clearSelection();
			}
			else
			{
				selectionChanged = gridSelection.removeAll();
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#selectionContainsIndex()
		 */		
		public function selectionContainsIndex(rowIndex:int):Boolean 
		{
			if (grid)
				return grid.selectionContainsIndex(rowIndex);
			else
				return gridSelection.containsRow(rowIndex);         
		}
		/**
		 * @copy egret.components.Grid#selectionContainsIndices()
		 * 
		 */		
		public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
		{
			if (grid)
				return grid.selectionContainsIndices(rowIndices);
			else
				return gridSelection.containsRows(rowIndices);
		}
		
		/**
		 * @copy egret.components.Grid#setSelectedIndex()
		 */		
		public function setSelectedIndex(rowIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.setSelectedIndex(rowIndex);
			}
			else
			{
				selectionChanged = gridSelection.setRow(rowIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#addSelectedIndex()
		 */		
		public function addSelectedIndex(rowIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.addSelectedIndex(rowIndex);
			}
			else
			{
				selectionChanged = gridSelection.addRow(rowIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#removeSelectedIndex()
		 */		
		public function removeSelectedIndex(rowIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.removeSelectedIndex(rowIndex);
			}
			else
			{
				selectionChanged = gridSelection.removeRow(rowIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#selectIndices()
		 * @param rowIndex
		 * @param rowCount
		 * @return 
		 * 
		 */		
		public function selectIndices(rowIndex:int, rowCount:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.selectIndices(rowIndex, rowCount);
			}
			else
			{
				selectionChanged = gridSelection.setRows(rowIndex, rowCount);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		
		/**
		 * @copy egret.components.Grid#selectionContainsCell()
		 */		
		public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (grid)
				return grid.selectionContainsCell(rowIndex, columnIndex);
			else
				return gridSelection.containsCell(rowIndex, columnIndex);
		}
		/**
		 * @copy egret.components.Grid#selectionContainsCellRegion() 
		 */		
		public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
													rowCount:int, columnCount:int):Boolean
		{
			if (grid)
			{
				return grid.selectionContainsCellRegion(
					rowIndex, columnIndex, rowCount, columnCount);
			}
			else
			{
				return gridSelection.containsCellRegion(
					rowIndex, columnIndex, rowCount, columnCount);
			}
		}
		/**
		 * @copy egret.components.Grid#setSelectedCell()
		 */		
		public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.setSelectedCell(rowIndex, columnIndex);
			}
			else
			{
				selectionChanged = gridSelection.setCell(rowIndex, columnIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#addSelectedCell()
		 */		
		public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.addSelectedCell(rowIndex, columnIndex);
			}
			else
			{
				selectionChanged = gridSelection.addCell(rowIndex, columnIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#removeSelectedCell()
		 */		
		public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.removeSelectedCell(rowIndex, columnIndex);
			}
			else
			{
				selectionChanged = gridSelection.removeCell(rowIndex, columnIndex);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}
		/**
		 * @copy egret.components.Grid#selectCellRegion() 
		 */		
		public function selectCellRegion(rowIndex:int, columnIndex:int, 
										 rowCount:uint, columnCount:uint):Boolean
		{
			var selectionChanged:Boolean;
			
			if (grid)
			{
				selectionChanged = grid.selectCellRegion(
					rowIndex, columnIndex, rowCount, columnCount);
			}
			else
			{
				selectionChanged = gridSelection.setCellRegion(
					rowIndex, columnIndex, rowCount, columnCount);
				if (selectionChanged)
					dispatchUIEvent(UIEvent.VALUE_COMMIT);
			}
			
			return selectionChanged;
		}    
		/**
		 * 为响应更改选定内容的用户输入（鼠标或键盘），该方法分派 selectionChanging 事件。
		 * 如果不取消该事件，则会提交选定内容更改，并分派 selectionChange 事件。
		 * 不更新插入标记位置。要检测插入标记是否已更改，请使用 caretChanged 事件。
		 * @param selectionEventKind 由用于指定正在提交的选定内容的 GridSelectionEventKind 
		 * 类定义的常量。如果不为 null，则用于生成 selectionChanging 事件。
		 * @param rowIndex 如果 selectionEventKind 适用于一行或一个单元格，则返回数据提供程序
		 * 中选定内容从零开始的 rowIndex。如果 selectionEventKind 适用于多个单元格，则返回单元
		 * 格区域的原点从零开始的 rowIndex。默认值为 -1，表示此参数未被使用。
		 * @param columnIndex 如果 selectionEventKind 适用于单行或单个单元格，则返回选定内容
		 * 从零开始的 columnIndex。如果 selectionEventKind 适用于多个单元格，则返回单元格区域
		 * 的原点从零开始的 columnIndex。默认值为 -1，表示此参数未被使用。
		 * @param rowCount 如果 selectionEventKind 适用于一个单元格区域，则返回单元格区域中
		 * 的行数。默认值为 -1，表示此参数未被使用。
		 * @param columnCount 如果 selectionEventKind 适用于一个单元格区域，则返回单元格区
		 * 域中的列数。默认值为 -1，表示此参数未被使用。
		 * @return  如果选定内容已提交或未发生更改，则为 true，如果选定内容已取消或由于出错
		 * 无法提交（如索引超出范围或 selectionEventKind 与 selectionMode 不兼容），则为 false。
		 * 
		 */		
		protected function commitInteractiveSelection(
			selectionEventKind:String,                                         
			rowIndex:int,
			columnIndex:int, 
			rowCount:int = 1, 
			columnCount:int = 1):Boolean
			
		{
			if (!grid)
				return false;
			var selectionChange:CellRegion = 
				new CellRegion(rowIndex, columnIndex, rowCount, columnCount);
			if (!doesChangeCurrentSelection(selectionEventKind, selectionChange))
				return true;
			if (hasEventListener(GridSelectionEvent.SELECTION_CHANGING))
			{
				var changingEvent:GridSelectionEvent = 
					new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGING, 
						false, true, 
						selectionEventKind, selectionChange); 
				if (!dispatchEvent(changingEvent))
					return false;
			}
			var changed:Boolean;
			switch (selectionEventKind)
			{
				case GridSelectionEventKind.SET_ROW:
				{
					changed = grid.gridSelection.setRow(rowIndex);
					break;
				}
				case GridSelectionEventKind.ADD_ROW:
				{
					changed = grid.gridSelection.addRow(rowIndex);
					break;
				}
					
				case GridSelectionEventKind.REMOVE_ROW:
				{
					changed = grid.gridSelection.removeRow(rowIndex);
					break;
				}
					
				case GridSelectionEventKind.SET_ROWS:
				{
					changed = grid.gridSelection.setRows(rowIndex, rowCount);
					break;
				}
					
				case GridSelectionEventKind.SET_CELL:
				{
					changed = grid.gridSelection.setCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.ADD_CELL:
				{
					changed = grid.gridSelection.addCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.REMOVE_CELL:
				{
					changed = grid.gridSelection.removeCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.SET_CELL_REGION:
				{
					changed = grid.gridSelection.setCellRegion(
						rowIndex, columnIndex, 
						rowCount, columnCount);
					break;
				}
					
				case GridSelectionEventKind.SELECT_ALL:
				{
					changed = grid.gridSelection.selectAll();
					break;
				}
			}
			if (!changed)
				return false;
			
			grid.invalidateDisplayListFor("selectionIndicator");
			if (hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
			{
				var changeEvent:GridSelectionEvent = 
					new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGE, 
						false, true, 
						selectionEventKind, selectionChange); 
				dispatchEvent(changeEvent);
				
				if (grid.hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
					grid.dispatchEvent(changeEvent);
			}
			dispatchUIEvent(UIEvent.VALUE_COMMIT);
			
			return true;
		}
		/**
		 * 更新网格的尖号位置。如果插入标记位置更改，则 grid 外观部件分派 caretChange 事件。 
		 * @param newCaretRowIndex 新尖号位置从零开始的 rowIndex。
		 * @param newCaretColumnIndex 新尖号位置从零开始的 columnIndex。
		 * 如果 selectionMode 基于行，则为 -1。
		 * 
		 */		
		protected function commitCaretPosition(newCaretRowIndex:int, 
											   newCaretColumnIndex:int):void
		{
			grid.caretRowIndex = newCaretRowIndex;
			grid.caretColumnIndex = newCaretColumnIndex;
		}
		/**
		 * 创建一个可选的网格对象来管理选择.
		 * @return 
		 * 
		 */		
		ns_egret function createGridSelection():GridSelection
		{
			return new GridSelection();    
		}
		protected function selectionContainsOnlyIndex(index:int):Boolean 
		{
			if (grid)
				return grid.selectionContainsIndex(index) && grid.selectionLength == 1;
			else
				return gridSelection.containsRow(index) && gridSelection.selectionLength == 1;
		}
		
		protected function selectionContainsOnlyIndices(selectionChange:CellRegion):Boolean 
		{
			var selectionLength:int = 
				grid ? grid.selectionLength : gridSelection.selectionLength;
			
			if (selectionChange.rowCount != selectionLength)
				return false;
			
			var bottom:int = 
				selectionChange.rowIndex + selectionChange.rowCount;
			
			for (var rowIndex:int = selectionChange.rowIndex; 
				rowIndex < bottom; 
				rowIndex++)
			{
				if (grid)
				{
					if (!grid.selectionContainsIndex(rowIndex)) 
						return false;
				}
				else
				{
					if (!gridSelection.containsRow(rowIndex))
						return false;
				}
			}
			
			return true;        
		}
		private function selectionContainsOnlyCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (grid)
				return grid.selectionContainsCell(rowIndex, columnIndex) && grid.selectionLength == 1;
			else
				return gridSelection.containsCell(rowIndex, columnIndex) && gridSelection.selectionLength == 1;
		}
		private function selectionContainsOnlyCellRegion(rowIndex:int, 
														 columnIndex:int, 
														 rowCount:int, 
														 columnCount:int):Boolean
		{
			if (grid)
			{
				return grid.selectionContainsCellRegion(
					rowIndex, columnIndex, rowCount, columnCount) &&
					grid.selectionLength == rowCount * columnCount;
			}
			else
			{
				return gridSelection.containsCellRegion(
					rowIndex, columnIndex, rowCount, columnCount) &&
					gridSelection.selectionLength == rowCount * columnCount;
			}
		}
		/**
		 * 对网格中的所选单元格启动编辑器会话。此方法不检查 DataGrid 和 GridColumn 的 editable 属性，
		 * 该属性可防止用户界面启动编辑器会话。startItemEditorSession 事件在创建项编辑器之前分派。
		 * 这样会允许侦听器动态更改指定单元格的项编辑器。也可以调用 preventDefault() 方法来取消事件，
		 * 以防止创建编辑器会话。 
		 * @param rowIndex 要编辑的单元格的从零开始的行索引。
		 * @param columnIndex 要编辑的单元格的从零开始的列索引。
		 * @return  如果编辑器会话已启动，则为 true。如果取消编辑器会话或无法启动编辑器会话，则返回 false。
		 * 请注意，无法在不可见的列中启动编辑器会话。
		 * 
		 */		
		public function startItemEditorSession(rowIndex:int, columnIndex:int):Boolean
		{
			if (editor)
				return editor.startItemEditorSession(rowIndex, columnIndex);
			
			return false;
		}
		/**
		 * 关闭当前的活动编辑器，并（可选）通过调用项编辑器的 save() 方法保存编辑器的值。
		 * 如果 cancel 参数为 true，将改为调用编辑器的 cancel() 方法。
		 * @param cancel 如果为 false，则保存编辑器中的数据。否则，将废弃编辑器中的数据。
		 * @return 如果编辑器会话已保存，则为 true；如果保存被取消，则为 false。
		 * 
		 */		
		public function endItemEditorSession(cancel:Boolean = false):Boolean
		{
			if (editor)
				return editor.endItemEditorSession(cancel);
			
			return false;
		}
		/**
		 * 创建一个数据表格编辑器， 重写此方法可以替换表格编辑器
		 * @return 
		 * 
		 */		
		ns_egret function createEditor():DataGridEditor
		{
			return new DataGridEditor(this);    
		}
		/**
		 * 按照一列或多列对 DataGrid 排序，并刷新显示。 
		 * <p>如果 dataProvider 为 ICollectionView，则其 sort 属性会设置为某一个值，具体取决于每个列的 
		 * dataField、sortCompareFunction 和 sortDescending 标志。然后，会调用数据提供程序的 refresh() 方法。</p> 
		 * <p>如果 dataProvider 不为 ICollectionView，则该方法不起作用。</p>
		 * @param column 对 dataProvider 进行排序所依据的列索引。
		 * @param isInteractive 如果为 true，将分派 GridSortEvent.SORT_CHANGING 和 GridSortEvent.SORT_CHANGE 事件，
		 * 且列标题组 visibleSortIndicatorIndices 将更新为 columnIndices（如果 GridSortEvent.SORT_CHANGING 事件尚未取消）。
		 * @return 如果已使用提供的列索引对 dataProvider 进行排序，则为 true。
		 */		
		public function sortByColumns(column:GridColumn, isInteractive:Boolean=false):Boolean
		{
			var dataProvider:ICollectionView = this.dataProvider as ICollectionView;
			if (!dataProvider)
				return false;
			
			var dataField:String = column.dataField;
			var sortFunc:Function = column.sortCompareFunction;
			var descending:Boolean = column.sortDescending;
			
			if (isInteractive)
			{
				if (hasEventListener(GridSortEvent.SORT_CHANGING))
				{
					var changingEvent:GridSortEvent = 
						new GridSortEvent(GridSortEvent.SORT_CHANGING,false, true,column); 
					
					if (!dispatchEvent(changingEvent))
						return false;
				}
			}
			
			dataProvider.sort(function(itemA:Object,itemB:Object):int{
				var result:int = 0;
				if(sortFunc!=null)
				{
					result = sortFunc(itemA,itemB,column);
				}
				else if(dataField)
				{
					if(itemA[dataField] < itemB[dataField])
						result = -1;
					else if(itemA[dataField] > itemB[dataField])
						result = 1;
					else
						result = 0;
				}
				else 
				{
					if(itemA < itemB)
						result = -1;
					else if(itemA > itemB)
						result = 1;
					else
						result = 0;
				}
				if(descending)
					result = -result;
				return result;
			});
			
			if (isInteractive)
			{
				if (hasEventListener(GridSortEvent.SORT_CHANGE))
				{
					var changeEvent:GridSortEvent = 
						new GridSortEvent(GridSortEvent.SORT_CHANGE,false, true, column); 
					dispatchEvent(changeEvent);
				}
				if (columnHeaderGroup)
					columnHeaderGroup.visibleSortIndicatorIndices = new <int>[column.columnIndex];            
			}           
			
			return true;
		}
		
		
		/**
		 * @return 如果设置了锚点位置的话为true
		 * 
		 */		
		private function isAnchorSet():Boolean
		{
			if (!grid)
				return false;
			
			if (isRowSelectionMode())
				return grid.anchorRowIndex != -1;
			else
				return grid.anchorRowIndex != -1 && grid.anchorRowIndex != -1;
		}
		/**
		 * 切换选择项，并设置插入符号到行索引/列索引
		 * @param rowIndex
		 * @param columnIndex
		 * @return 选择项改变的时候返回true
		 * 
		 */		
		private function toggleSelection(rowIndex:int, columnIndex:int):Boolean
		{
			var kind:String;
			
			if (isRowSelectionMode())
			{ 
				if (grid.selectionContainsIndex(rowIndex))
					kind = GridSelectionEventKind.REMOVE_ROW;
				else if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
					kind = GridSelectionEventKind.ADD_ROW;
				else
					kind = GridSelectionEventKind.SET_ROW;
				
			}
			else if (isCellSelectionMode())
			{
				if (grid.selectionContainsCell(rowIndex, columnIndex))
					kind = GridSelectionEventKind.REMOVE_CELL;
				else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
					kind = GridSelectionEventKind.ADD_CELL;
				else
					kind = GridSelectionEventKind.SET_CELL;
			}
			
			var success:Boolean = 
				commitInteractiveSelection(kind, rowIndex, columnIndex);
			if (success)
				commitCaretPosition(rowIndex, columnIndex);
			
			return success;
		}
		/**
		 * @private
		 * 从锚点的位置扩展一个新的位置
		 */		
		private function extendSelection(caretRowIndex:int, 
										 caretColumnIndex:int):Boolean
		{
			if (!isAnchorSet())
				return false;
			
			var startRowIndex:int = Math.min(grid.anchorRowIndex, caretRowIndex);
			var endRowIndex:int = Math.max(grid.anchorRowIndex, caretRowIndex);
			var success:Boolean;
			
			if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_ROWS,
					startRowIndex, -1,
					endRowIndex - startRowIndex + 1, 0);
			}
			else if (selectionMode == GridSelectionMode.SINGLE_ROW)
			{
				
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_ROW, caretRowIndex, -1, 1, 0);                
			}
			else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
			{
				var rowCount:int = endRowIndex - startRowIndex + 1;
				var startColumnIndex:int = 
					Math.min(grid.anchorColumnIndex, caretColumnIndex);
				var endColumnIndex:int = 
					Math.max(grid.anchorColumnIndex, caretColumnIndex); 
				var columnCount:int = endColumnIndex - startColumnIndex + 1;
				
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_CELL_REGION, 
					startRowIndex, startColumnIndex,
					rowCount, columnCount);
			}            
			else if (selectionMode == GridSelectionMode.SINGLE_CELL)
			{
				
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_CELL, 
					caretRowIndex, caretColumnIndex, 1, 1);                
			}
			if (success)
				commitCaretPosition(caretRowIndex, caretColumnIndex);
			
			return success;
		}
		/**
		 * @private
		 * 设置选择项并更新插入符号和锚点位置
		 */		
		private function setSelectionAnchorCaret(rowIndex:int, columnIndex:int):Boolean
		{
			var success:Boolean;
			if (isRowSelectionMode())
			{
				
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_ROW, 
					rowIndex, columnIndex);
			}
			else if (isCellSelectionMode())
			{
				
				success = commitInteractiveSelection(
					GridSelectionEventKind.SET_CELL, 
					rowIndex, columnIndex);
			}
			if (success)
			{
				commitCaretPosition(rowIndex, columnIndex);
				grid.anchorRowIndex = rowIndex;
				grid.anchorColumnIndex = columnIndex; 
			}    
			
			return success;
		}
		/**
		 * 基于现在的插入符号的位置和navigationUnit的位置，返回新的插入符号位置 
		 * @param navigationUnit
		 * @return 
		 * 
		 */		
		private function setCaretToNavigationDestination(navigationUnit:uint):CellPosition
		{
			var caretRowIndex:int = grid.caretRowIndex;
			var caretColumnIndex:int = grid.caretColumnIndex;
			
			var inRows:Boolean = isRowSelectionMode();
			
			var rowCount:int = dataProviderLength;
			var columnCount:int = columnsLength;
			var visibleRows:Vector.<int>;
			var caretRowBounds:Rectangle;
			
			switch (navigationUnit)
			{
				case NavigationUnit.LEFT: 
				{
					if (isCellSelectionMode())
					{
						if (grid.caretColumnIndex > 0)
							caretColumnIndex = grid.getPreviousVisibleColumnIndex(caretColumnIndex);
					}
					break;
				}
					
				case NavigationUnit.RIGHT:
				{
					if (isCellSelectionMode())
					{
						if (grid.caretColumnIndex + 1 < columnCount)
							caretColumnIndex = grid.getNextVisibleColumnIndex(caretColumnIndex);
					}
					break;
				} 
					
				case NavigationUnit.UP:
				{
					if (grid.caretRowIndex > 0)
						caretRowIndex--;
					break; 
				}
					
				case NavigationUnit.DOWN:
				{
					if (grid.caretRowIndex + 1 < rowCount)
						caretRowIndex++;
					break; 
				}
					
				case NavigationUnit.PAGE_UP:
				{
					visibleRows = grid.getVisibleRowIndices();
					if (visibleRows.length == 0)
						break;
					var firstVisibleRowIndex:int = visibleRows[0];                
					var firstVisibleRowBounds:Rectangle =
						grid.getRowBounds(firstVisibleRowIndex);
					if (firstVisibleRowIndex < rowCount - 1 && 
						firstVisibleRowBounds.top < grid.scrollRect.top)
					{
						firstVisibleRowIndex = visibleRows[1];
					}
					
					if (caretRowIndex > firstVisibleRowIndex)
					{
						caretRowIndex = firstVisibleRowIndex;
					}
					else
					{     
						caretRowBounds = grid.getRowBounds(caretRowIndex);
						var delta:Number = 
							grid.scrollRect.bottom - caretRowBounds.bottom;
						grid.verticalScrollPosition -= delta;
						validateNow();
						visibleRows = grid.getVisibleRowIndices();
						firstVisibleRowIndex = visibleRows[0];
						if (visibleRows.length > 0)
						{
							firstVisibleRowBounds = grid.getRowBounds(firstVisibleRowIndex);
							if (firstVisibleRowIndex < rowCount - 1 && 
								grid.scrollRect.top > firstVisibleRowBounds.top)
							{
								firstVisibleRowIndex = visibleRows[1];
							}
							caretRowIndex = firstVisibleRowIndex;
						}
					}
					break; 
				}
				case NavigationUnit.PAGE_DOWN:
				{
					visibleRows = grid.getVisibleRowIndices();
					if (visibleRows.length == 0)
						break;
					var lastVisibleRowIndex:int = Math.min(rowCount - 1, visibleRows[visibleRows.length - 1]);                
					var lastVisibleRowBounds:Rectangle = grid.getRowBounds(lastVisibleRowIndex);
					if (lastVisibleRowIndex > 0 && 
						grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
					{
						lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
					}
					
					if (caretRowIndex < lastVisibleRowIndex)
					{
						caretRowIndex = lastVisibleRowIndex;
					}
					else
					{                        
						caretRowBounds = grid.getRowBounds(caretRowIndex);
						grid.verticalScrollPosition = caretRowBounds.y;
						validateNow();
						visibleRows = grid.getVisibleRowIndices();
						lastVisibleRowIndex = Math.min(rowCount - 1, visibleRows[visibleRows.length - 1])
						if (visibleRows.length >= 0)
						{
							lastVisibleRowBounds = grid.getRowBounds(lastVisibleRowIndex);
							if (lastVisibleRowIndex > 0 && 
								grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
							{
								lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
							}
							caretRowIndex = lastVisibleRowIndex;
						}
					}
					break; 
				}
					
				case NavigationUnit.HOME:
				{
					caretRowIndex = 0;
					caretColumnIndex = isCellSelectionMode() ? grid.getNextVisibleColumnIndex(-1) : -1; 
					break;
				}
					
				case NavigationUnit.END:
				{
					caretRowIndex = rowCount - 1;
					caretColumnIndex = isCellSelectionMode() ? grid.getPreviousVisibleColumnIndex(columnCount) : -1;
					grid.verticalScrollPosition = grid.contentHeight;
					validateNow();
					if (grid.contentHeight != grid.verticalScrollPosition)
					{
						grid.verticalScrollPosition = grid.contentHeight;
						validateNow();
					}
					break;
				}
					
				default: 
				{
					return null;
				}
			}
			
			return new CellPosition(caretRowIndex, caretColumnIndex);
		}
		/**
		 * @copy egret.components.Grid#ensureCellIsVisible() 
		 */		
		public function ensureCellIsVisible(rowIndex:int, columnIndex:int = -1):void
		{
			if (grid)
				grid.ensureCellIsVisible(rowIndex, columnIndex);
		}
		
		protected function adjustSelectionUponNavigation(event:KeyboardEvent):Boolean
		{
			
			if (!NavigationUnit.isNavigationUnit(event.keyCode))
				return false; 
			var navigationUnit:uint = event.keyCode;
			
			var newPosition:CellPosition = setCaretToNavigationDestination(navigationUnit);
			if (!newPosition)
				return false;
			event.preventDefault(); 
			
			var selectionChanged:Boolean = false;
			
			if (event.shiftKey)
			{
				selectionChanged = 
					extendSelection(newPosition.rowIndex, newPosition.columnIndex);
			}
			else if (event.ctrlKey)
			{
				commitCaretPosition(newPosition.rowIndex, newPosition.columnIndex);
			}
			else
			{
				
				setSelectionAnchorCaret(newPosition.rowIndex, newPosition.columnIndex);
			}
			ensureCellIsVisible(newPosition.rowIndex, newPosition.columnIndex);            
			
			return true;
		}
	
		private function doesChangeCurrentSelection(
			selectionEventKind:String, 
			selectionChange:CellRegion):Boolean
		{
			var changesSelection:Boolean;
			
			var rowIndex:int = selectionChange.rowIndex;
			var columnIndex:int = selectionChange.columnIndex;
			var rowCount:int = selectionChange.rowCount;
			var columnCount:int = selectionChange.columnCount;
			
			switch (selectionEventKind)
			{
				case GridSelectionEventKind.SET_ROW:
				{
					changesSelection = 
						!selectionContainsOnlyIndex(rowIndex);
					break;
				}
				case GridSelectionEventKind.ADD_ROW:
					
				{
					changesSelection = 
						!grid.selectionContainsIndex(rowIndex);
					break;
				}
					
				case GridSelectionEventKind.REMOVE_ROW:
				{
					changesSelection = requireSelection ?
						!selectionContainsOnlyIndex(rowIndex) :
						grid.selectionContainsIndex(rowIndex);
					break;
				}
					
				case GridSelectionEventKind.SET_ROWS:
				{
					changesSelection = 
						!selectionContainsOnlyIndices(selectionChange);
					break;
				}
					
				case GridSelectionEventKind.SET_CELL:
				{
					changesSelection = 
						!selectionContainsOnlyCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.ADD_CELL:
				{
					changesSelection = 
						!grid.selectionContainsCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.REMOVE_CELL:
				{
					changesSelection = requireSelection ?
						!selectionContainsOnlyCell(rowIndex, columnIndex) :                  
						grid.selectionContainsCell(rowIndex, columnIndex);
					break;
				}
					
				case GridSelectionEventKind.SET_CELL_REGION:
				{
					changesSelection = 
						!selectionContainsOnlyCellRegion(
							rowIndex, columnIndex, rowCount, columnCount);
					break;
				}
					
				case GridSelectionEventKind.SELECT_ALL:
				{
					changesSelection = true;
					break;
				}
			}
			
			return changesSelection;
		}
		protected function grid_rollOverHandler(event:GridEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			if (event.buttonDown && event.relatedObject != grid)
				updateHoverOnRollOver = false;
			
			grid.hoverRowIndex = updateHoverOnRollOver ? event.rowIndex : -1;
			grid.hoverColumnIndex = updateHoverOnRollOver ? event.columnIndex : -1;
			
			event.updateAfterEvent();        
		}
		protected function grid_rollOutHandler(event:GridEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			grid.hoverRowIndex = -1;
			grid.hoverColumnIndex = -1;
			
			updateHoverOnRollOver = true;
			event.updateAfterEvent();
		}
		protected function grid_mouseUpHandler(event:GridEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			if (!updateHoverOnRollOver)
			{
				grid.hoverRowIndex = event.rowIndex;
				grid.hoverColumnIndex = event.columnIndex;
				updateHoverOnRollOver = true;
			}
		}
		
		protected function grid_mouseDownHandler(event:GridEvent):void
		{
			if (event.isDefaultPrevented())
				return;
			
			var isCellSelection:Boolean = isCellSelectionMode();
			
			var rowIndex:int = event.rowIndex;
			var columnIndex:int = isCellSelection ? event.columnIndex : -1;
			if (rowIndex == -1 || isCellSelection && columnIndex == -1)
				return;
			
			if (event.ctrlKey)
			{
				
				if (!toggleSelection(rowIndex, columnIndex))
					return;
				
				grid.anchorRowIndex = rowIndex;
				grid.anchorColumnIndex = columnIndex;
			}
			else if (event.shiftKey)
			{
				
				if  (grid.selectionMode == GridSelectionMode.MULTIPLE_ROWS || 
					grid.selectionMode == GridSelectionMode.MULTIPLE_CELLS)
				{    
					if (!extendSelection(rowIndex, columnIndex))
						return;
				}
			}
			else
			{
				setSelectionAnchorCaret(rowIndex, columnIndex);
			}
		}
		protected function grid_caretChangeHandler(event:GridCaretEvent):void
		{
			if (hasEventListener(GridCaretEvent.CARET_CHANGE))
				dispatchEvent(event);
		}
		protected function grid_valueCommitHandler(event:UIEvent):void
		{
			if (hasEventListener(UIEvent.VALUE_COMMIT))
				dispatchEvent(event);
		}
		private function grid_invalidateDisplayListHandler(event:Event):void
		{
			
			if (columnHeaderGroup && grid.isInvalidateDisplayListReason("horizontalScrollPosition"))
				columnHeaderGroup.invalidateDisplayList();
		}
		private function grid_invalidateSizeHandler(event:Event):void
		{
			
			if (columnHeaderGroup)
				columnHeaderGroup.invalidateSize();
		}     
		
		private var resizeColumn:GridColumn = null;
		
		private var resizeAnchorX:Number = NaN;
		
		private var resizeColumnWidth:Number = NaN;
		
		private var nextColumn:GridColumn = null;  
		
		private var nextColumnWidth:Number = NaN;  
		
		protected function columnHeaderGroup_clickHandler(event:GridEvent):void
		{
			var column:GridColumn = event.column;
			if (!enabled || !sortableColumns || !column || !column.sortable)
				return;
			
			var columnIndices:Vector.<int> = Vector.<int>([column.columnIndex]);
			column.sortDescending = !column.sortDescending;
			sortByColumns(column, true);
		}
		protected function separator_mouseDownHandler(event:GridEvent):void
		{
			var column:GridColumn = event.column;
			if (!enabled || !grid.resizableColumns || !column || !column.resizable)
				return;
			
			resizeColumn = event.column;
			resizeAnchorX = event.localX;
			resizeColumnWidth = grid.getColumnWidth(resizeColumn.columnIndex);
			nextColumn = null;
			nextColumnWidth = NaN;
			var resizeColumnIndex:int = resizeColumn.columnIndex;
			for (var columnIndex:int = 0; columnIndex < resizeColumnIndex; columnIndex++)
			{
				var gc:GridColumn = getColumnAt(columnIndex);
				if (gc.visible && isNaN(gc.width))
					gc.width = grid.getColumnWidth(columnIndex);
			}
		}    
		protected function separator_mouseDragHandler(event:GridEvent):void
		{
			if (!resizeColumn)
				return;
			
			var widthDelta:Number = event.localX - resizeAnchorX;
			var minWidth:Number = isNaN(resizeColumn.minWidth) ? 0 : resizeColumn.minWidth;
			var maxWidth:Number = resizeColumn.maxWidth;
			var newWidth:Number = Math.ceil(resizeColumnWidth + widthDelta);
			if (nextColumn)
			{
				var nextMinWidth:Number = isNaN(nextColumn.minWidth) ? 0 : nextColumn.minWidth;
				
				if (Math.ceil(nextColumnWidth - widthDelta) <= nextMinWidth)
					return;
				if (Math.ceil(resizeColumnWidth + widthDelta) <= minWidth)
					return;
				
				nextColumn.width = nextColumnWidth - widthDelta;
			}
			
			newWidth = Math.max(newWidth, minWidth);
			if (!isNaN(maxWidth))
				newWidth = Math.min(newWidth, maxWidth);
			
			resizeColumn.width = newWidth;
			event.updateAfterEvent();
		} 
		protected function separator_mouseUpHandler(event:GridEvent):void
		{
			if (!resizeColumn)
				return;
			
			resizeColumn = null;
		}     
		
		/**
		 * 鼠标经过分隔符，切换鼠标样式
		 */		
		protected function separator_rollOverHandler(event:GridEvent):void
		{
			var column:GridColumn = event.column;
			if (!enabled || !grid.resizableColumns || !column || !column.resizable)
				return;
			
		}
		/**
		 * 鼠标移出分隔符，还原鼠标样式
		 */		
		protected function separator_rollOutHandler(event:GridEvent):void
		{
			if (!enabled)
				return;
			
		}     
		
		protected function dataGrid_focusHandler(event:FocusEvent):void
		{
			if (!grid || !(grid.layout is GridLayout))
				return;
			
			if (isOurFocus(DisplayObject(event.target)))
			{
				GridLayout(grid.layout).showCaret = 
					event.type == FocusEvent.FOCUS_IN &&
					selectionMode != GridSelectionMode.NONE;
			}
		}
		
	}
}