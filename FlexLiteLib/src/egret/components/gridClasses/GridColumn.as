package egret.components.gridClasses
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import egret.components.Grid;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.events.PropertyChangeEvent;
	
	use namespace ns_egret;
	
	/**
	 * GridColumn类用于在数据表格中定义一个列。
	 * GridColumn内有个字段对应原始数据表内对象的名字，相同名字的属性将被显示到这一列表格里。
	 * @author dom
	 * 
	 */	
	public class GridColumn extends EventDispatcher
	{
		/**
		 * <code>itemToLabel()</code>方法返回数据的时候如果内部有错误了，就返回这个。
		 */		
		public static var ERROR_TEXT:String = " ";
		
		private static var _defaultItemEditor:Class;
		
		ns_egret static function get defaultItemEditor():Class
		{
			if (!_defaultItemEditor)
				_defaultItemEditor = DefaultGridItemEditor;
			return _defaultItemEditor;
		}
		
		/**
		 * 一个默认的比较函数， 用于排序用
		 * @param obj1
		 * @param obj2
		 * @param column
		 * @return 
		 * 
		 */		
		private static function dataFieldPathSortCompare(obj1:Object, obj2:Object, column:GridColumn):int
		{
			if (!obj1 && !obj2)
				return 0;
			
			if (!obj1)
				return 1;
			
			if (!obj2)
				return -1;
			
			var dataFieldPath:Array = column.dataFieldPath;
			var obj1String:String = column.itemToString(obj1, dataFieldPath, null);
			var obj2String:String = column.itemToString(obj2, dataFieldPath, null);
			
			if ( obj1String < obj2String )
				return -1;
			
			if ( obj1String > obj2String )
				return 1;
			
			return 0;
		}
		
		public function GridColumn(columnName:String = null)
		{
			super();
			
			if (columnName)
				dataField = headerText = columnName;
		}
		
		private var _grid:Grid = null;
		
		/**
		 * 当一个列被添加到 grid.columns的时候由Grid来控制该属性，如果列被移除了，就设置null
		 * @param value
		 * 
		 */		
		ns_egret function setGrid(value:Grid):void
		{
			if (_grid == value)
				return;
			
			_grid = value;
			dispatchChangeEvent("gridChanged");        
		}
		
		/**
		 * 与该列相关联的Grid
		 * @return 
		 * 
		 */		
		public function get grid():Grid
		{
			return _grid;
		}
		
		private var _columnIndex:int = -1;
		
		/**
		 * 当这个列被添加到grid.columns的时候，由Grid来复制。如果是从Grid中移除了这列，则设置为-1。
		 * @param value
		 * 
		 */		
		ns_egret function setColumnIndex(value:int):void
		{
			if (_columnIndex == value)
				return;
			
			_columnIndex = value;
			dispatchChangeEvent("columnIndexChanged");        
		}
		
		/**
		 * 这一列在Grid中的位置，-1表示这一列不在表里 
		 * @return 
		 * 
		 */		
		public function get columnIndex():int
		{
			return _columnIndex;
		}   
		
		private var _dataField:String = null;
		
		private var dataFieldPath:Array = [];
		
		/**
		 * GridColumn内的一个字段对应原始数据表内对象的名字，相同名字的属性将被显示到这一列表格里。
		 * 
		 */		
		public function get dataField():String
		{
			return _dataField;
		}
		
		public function set dataField(value:String):void
		{
			if (_dataField == value)
				return;
			
			_dataField = value;
			
			if (value == null)
			{
				dataFieldPath = [];
			}
			else if (value.indexOf( "." ) != -1) 
			{
				dataFieldPath = value.split(".");
			}
			else
			{
				dataFieldPath = [value];
			}
			
			invalidateGrid();
			if (grid)
				grid.clearGridLayoutCache(true);
			
			dispatchChangeEvent("dataFieldChanged");
		}
		
		private var _dataTipField:String = null;
		
		/**
		 * 用来显示提示的。如果此列或其网格指定了 dataTipFunction 属性的值，则忽略 dataTipField 属性。
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
			
			if (grid)
				grid.invalidateDisplayList();
			
			dispatchChangeEvent("dataTipFieldChanged");
		}
		
		private var _dataTipFunction:Function = null;
		
		/**
		 * 指定在数据提供程序每个项目上运行的回调函数，
		 * 以确定其数据提示。此属性由 itemToDataTip 方法使用。  
		 * @return 
		 * 
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
			
			if (grid)
				grid.invalidateDisplayList();
			
			dispatchChangeEvent("dataTipFunctionChanged");
		}
		
		private var _editable:Boolean = true;
		
		/**
		 * 是否能对列中的数据单元进行编辑。 
		 * @return 
		 * 
		 */		
		public function get editable():Boolean
		{
			return _editable;
		}
		
		public function set editable(value:Boolean):void
		{
			if (_editable == value)
				return;
			
			_editable = value;
			dispatchChangeEvent("editableChanged");
		}
		
		private var _headerRenderer:Class = null;
		
		/**
		 * 表头渲染器的类 
		 * @return 
		 * 
		 */		
		public function get headerRenderer():Class
		{
			return _headerRenderer;
		}
		
		public function set headerRenderer(value:Class):void
		{
			if (_headerRenderer == value)
				return;
			
			_headerRenderer = value;
			
			if (grid)
				grid.invalidateDisplayList();
			
			dispatchChangeEvent("headerRendererChanged");
		}
		
		private var _headerText:String;
		
		/**
		 * 这一列的表头显示的文字 
		 * @return 
		 * 
		 */		
		public function get headerText():String
		{
			return (_headerText != null) ? _headerText : ((dataField) ? dataField : "");
		}
		
		public function set headerText(value:String):void
		{
			_headerText = value;
			
			if (grid)
				grid.invalidateDisplayList();
			
			dispatchChangeEvent("headerTextChanged");
		}
		
		private var _imeMode:String = null;
		
		public function get imeMode():String
		{
			return _imeMode;
		}
		
		public function set imeMode(value:String):void
		{
			_imeMode = value;
		}
		
		private var _itemEditor:Class = null;
		
		/**
		 * 编辑器的模板类 
		 * @return 
		 * 
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
		
		
		private var _itemRenderer:Class = null;
		
		/**
		 * 数据单元的渲染模板类 
		 * @return 
		 * 
		 */		
		public function get itemRenderer():Class
		{
			return (_itemRenderer) ? _itemRenderer : grid.itemRenderer;
		}
		
		public function set itemRenderer(value:Class):void
		{
			if (_itemRenderer == value)
				return;
			
			_itemRenderer = value;
			
			invalidateGrid();
			if (grid)
				grid.clearGridLayoutCache(true);
			
			dispatchChangeEvent("itemRendererChanged");
		}
		
		private var _itemRendererFunction:Function = null;
		
		/**
		 * 这个方法可以实现不同数据单元用不同的渲染模板类
		 * @return 
		 * 
		 */		
		public function get itemRendererFunction():Function
		{
			return _itemRendererFunction;
		}
		
		public function set itemRendererFunction(value:Function):void
		{
			if (_itemRendererFunction == value)
				return;
			
			_itemRendererFunction = value;
			
			invalidateGrid();
			if (grid)
				grid.clearGridLayoutCache(true);
			
			dispatchChangeEvent("itemRendererFunctionChanged");
		}
		
		private var _labelFunction:Function = null;
		
		/**
		 * 从object数据中去获得可以显示的文本 
		 * @return 
		 * 
		 */		
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		public function set labelFunction(value:Function):void
		{
			if (_labelFunction == value)
				return;
			
			_labelFunction = value;
			
			invalidateGrid();
			if (grid)
				grid.clearGridLayoutCache(true);
			
			dispatchChangeEvent("labelFunctionChanged");
		}
		
		private var _width:Number = NaN;
		
		/**
		 * 列的宽度 
		 * @return 
		 * 
		 */		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			if (_width == value)
				return;
			
			_width = value;
			
			invalidateGrid();
			dispatchChangeEvent("widthChanged");
		}
		
		private var _minWidth:Number = 20;
		
		/**
		 * 列的最小宽度 
		 * @return 
		 * 
		 */		
		public function get minWidth():Number
		{
			return _minWidth;
		}
		
		public function set minWidth(value:Number):void
		{
			if (_minWidth == value)
				return;
			
			_minWidth = value;
			
			invalidateGrid();
			if (grid)
				grid.setContentSize(0, 0);
			
			dispatchChangeEvent("minWidthChanged");
		}    
		
		private var _maxWidth:Number = NaN;
		/**
		 * 列的最大宽度 
		 * @return 
		 * 
		 */		
		public function get maxWidth():Number
		{
			return _maxWidth;
		}
		
		public function set maxWidth(value:Number):void
		{
			if (_maxWidth == value)
				return;
			
			_maxWidth = value;
			
			invalidateGrid();
			if (grid)
				grid.setContentSize(0, 0);
			
			dispatchChangeEvent("maxWidthChanged");
		}
		
		
		private var _rendererIsEditable:Boolean = false;
		
		/**
		 * 是否可以编辑 
		 * @return 
		 * 
		 */		
		public function get rendererIsEditable():Boolean
		{
			return _rendererIsEditable;
		}
		
		public function set rendererIsEditable(value:Boolean):void
		{
			if (_rendererIsEditable == value)
				return;
			
			_rendererIsEditable = value;
			dispatchChangeEvent("rendererIsEditableChanged");
		}
		
		private var _resizable:Boolean = true;
		
		/**
		 * 指示是否允许用户调整列宽大小。如果为 true，且关联网格的 resizableColumns 属性也为 true，则用户可以拖动列标题之间的网格线以调整列大小。 
		 * @return 
		 * 
		 */		
		public function get resizable():Boolean
		{
			return _resizable;
		}
		
		public function set resizable(value:Boolean):void
		{
			if (_resizable == value)
				return;
			
			_resizable = value;
			dispatchChangeEvent("resizableChanged");
		}
		
		private var _showDataTips:* = undefined;
		
		/**
		 * 显示过长数据的tip 
		 * @return 
		 * 
		 */		
		public function get showDataTips():*
		{
			return _showDataTips;
		}
		
		public function set showDataTips(value:*):void
		{
			if (_showDataTips === value)
				return;
			
			_showDataTips = value;
			
			if (grid)
				grid.invalidateDisplayList();
			
			dispatchChangeEvent("showDataTipsChanged");        
		}
		
		ns_egret function getShowDataTips():Boolean
		{
			return (showDataTips === undefined) ? grid && grid.showDataTips : showDataTips;    
		}
		
		private var _sortable:Boolean = true;
		
		/**
		 * 是否可排序 
		 * @return 
		 * 
		 */		
		public function get sortable():Boolean
		{
			return _sortable;
		}
		
		public function set sortable(value:Boolean):void
		{
			if (_sortable == value)
				return;
			
			_sortable = value;
			
			dispatchChangeEvent("sortableChanged");        
		}
		
		private var _sortCompareFunction:Function;
		
		/**
		 * 排序比较函数 
		 * @return 
		 * 
		 */		
		public function get sortCompareFunction():Function
		{
			return _sortCompareFunction;
		}
		
		public function set sortCompareFunction(value:Function):void
		{
			if (_sortCompareFunction == value)
				return;
			
			_sortCompareFunction = value;
			
			dispatchChangeEvent("sortCompareFunctionChanged");
		}
		
		private var _sortDescending:Boolean = false;
		
		/**
		 * <p>如果为 true，则按降序顺序对此列排序。例如，如果列的 dataField 包含数字值，则包含此列中最大值的行将为第一行。</p> 
		 * <p>设置此属性不会开始进行排序；这只是在设置排序方向。在调用 dataProvider.refresh() 方法时，执行排序。</p>
		 * @return 
		 * 
		 */		
		public function get sortDescending():Boolean
		{
			return _sortDescending;
		}
		
		public function set sortDescending(value:Boolean):void
		{
			if (_sortDescending == value)
				return;
			
			_sortDescending = value;
			
			dispatchChangeEvent("sortDescendingChanged");
		}
		
		private var _visible:Boolean = true;
		
		/**
		 * 是否可见 
		 * @return 
		 * 
		 */		
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(value:Boolean):void
		{
			if (_visible == value)
				return;
			
			_visible = value;
			if (grid && grid.columns)
			{
				var propertyChangeEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this, "visible", !_visible, _visible);
				var collectionEvent:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				collectionEvent.kind = CollectionEventKind.UPDATE;
				collectionEvent.items.push(propertyChangeEvent);
				
				grid.columns.dispatchEvent(collectionEvent);
			}
			
			dispatchChangeEvent("visibleChanged");
		}
		/**
		 * itemToLabel(), itemToDataTip()这两个函数的逻辑层 
		 * @param item
		 * @param labelPath
		 * @param labelFunction
		 * @return 
		 * 
		 */		
		private function itemToString(item:Object, labelPath:Array, labelFunction:Function):String
		{
			if (!item)
				return ERROR_TEXT;
			
			if (labelFunction != null)
				return labelFunction(item, this);
			
			var itemString:String = null;
			try 
			{
				var itemData:Object = item;
				for each (var pathElement:String in labelPath)
					itemData = itemData[pathElement];
				
				if ((itemData != null) && (labelPath.length > 0))
					itemString = itemData.toString();
			}
			catch(ignored:Error)
			{
			}        
			
			return (itemString != null) ? itemString : ERROR_TEXT;
		}
		
		/**
		 * 把一个Object转化成一个数据单元文本 
		 * @param item
		 * @return 
		 * 
		 */		
		public function itemToLabel(item:Object):String
		{
			return itemToString(item, dataFieldPath, labelFunction);
		}
		
		/**
		 * 把一个Object转化成tip的文本 
		 * @param item
		 * @return 
		 * 
		 */		
		public function itemToDataTip(item:Object):String
		{
			var tipFunction:Function = (dataTipFunction != null) ? dataTipFunction : grid.dataTipFunction;
			var tipField:String = (dataTipField) ? dataTipField : grid.dataTipField;
			var tipPath:Array = (tipField) ? [tipField] : dataFieldPath;
			
			return itemToString(item, tipPath, tipFunction);      
		}
		
		/**
		 * 把一个object转化成一个渲染模板类 
		 * @param item
		 * @return 
		 * 
		 */		
		public function itemToRenderer(item:Object):Class
		{
			var itemRendererFunction:Function = this.itemRendererFunction;
			return (itemRendererFunction != null) ? itemRendererFunction(item, this) : itemRenderer;
		}
		
		private function dispatchChangeEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new Event(type));
		}
		private function invalidateGrid():void
		{
			if (grid)
			{
				grid.invalidateSize();
				grid.invalidateDisplayList();
			}
		}
	}
}