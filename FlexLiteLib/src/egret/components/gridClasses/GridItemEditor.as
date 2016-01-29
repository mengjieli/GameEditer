package egret.components.gridClasses
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	import egret.components.DataGrid;
	import egret.components.SkinnableComponent;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	/**
	 * GridItemEditor类定义了修改数据表格控件的基类。
	 * 这个类的让你可以编辑一个数据单元的内容，并将内容保存。
	 * @author dom
	 */	
	public class GridItemEditor extends SkinnableComponent implements IGridItemEditor
	{
		public function GridItemEditor()
		{
			super();
		}
		
		private var _column:GridColumn;
		
		/**
		 * 默认为null 
		 * @return 
		 * 
		 */		
		public function get column():GridColumn
		{
			return _column;    
		}
		
		public function set column(value:GridColumn):void
		{
			_column = value;   
		}
		
		/**
		 * 列的列索引 
		 * @return 
		 * 
		 */		
		public function get columnIndex():int
		{
			return column.columnIndex;;
		}
		
		private var _data:Object = null;
		
		/**
		 * 显示数据的object 
		 * @return 
		 * 
		 */		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			
			if (_data && column.dataField)
			{
				this.value = _data[column.dataField];            
			}
		}
		
		/**
		 * 拥有此项编辑器的数据表格控件 
		 * @return 
		 * 
		 */		
		public function get dataGrid():DataGrid
		{
			return DataGrid(owner);
		}
		
		/**
		 * 一个标志，用于指示当组件获得焦点时是否应启用 IME 
		 * @return 
		 * 
		 */		
		public function get enableIME():Boolean
		{
			return true;
		}

		private var _itemRenderer:IGridItemRenderer;
		
		/**
		 * 与当前正在编辑的单元格相关联的渲染器。 
		 * @return 
		 * 
		 */		
		public function get itemRenderer():IGridItemRenderer
		{
			return _itemRenderer;
		}
		
		public function set itemRenderer(value:IGridItemRenderer):void
		{
			_itemRenderer = value;
		}
		
		private var _rowIndex:int;
		
		/**
		 * 正在编辑的单元格的行索引。 
		 * @return 
		 * 
		 */		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		
		public function set rowIndex(value:int):void
		{
			_rowIndex = value;
		}
		
		private var _value:Object;
		/**
		 * 默认情况下，由 data 属性的 setter 方法初始化此属性。
		 * 此属性的默认值为数据表格控件提供。
		 * 
		 * 项编辑器可以使用此属性初始化项编辑器中的值。
		 * 
		 * 默认情况下，当执行保存操作后关闭编辑器时，save() 方法将此属性的值写入回数据表格控件中。
 
		 * @return 
		 * 
		 */		
		public function get value():Object
		{
			return _value;
		}
		
		public function set value(newValue:Object):void
		{
			if(newValue==_value)
				return;
			_value = newValue
		}
		
		/**
		 * <p>编辑器关闭之前调用</p>
		 * <p>子类重写字方法，实现具体操作</p>
		 *  
		 * 
		 */		
		public function discard():void
		{
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpDownMoveHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownMoveHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		
		/**
		 * <p>编辑器可见之前调用。在编辑器可见之前，使用此方法调整编辑器的外观、添加事件侦听器或执行任何其它初始化。</p> 
		 * <p>子类重写此方法，实现具体操作</p>
		 * 
		 */		
		public function prepare():void
		{
			
			addEventListener(MouseEvent.MOUSE_UP, mouseUpDownMoveHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseUpDownMoveHandler);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/**
		 * <p>将编辑器中的数据保存，同时更新数据源。</p>
		 * <p>此方法不要调用不要复写。 如果要执行保存调用渲染器的 endItemEditorSession() 这个方法。</p>
		 * @return 
		 * 
		 */		
		public function save():Boolean
		{
			if (!validate())
				return false;
			
			var newData:Object = value;
			var property:String = column.dataField;
			var data:Object = _data;
			var typeInfo:String = "";
			for each(var variable:XML in describeType(data).variable)
			{
				if (property == variable.@name.toString())
				{
					typeInfo = variable.@type.toString();
					break;
				}
			}
			
			if (typeInfo == "String")
			{
				if (!(newData is String))
					newData = newData.toString();
			}
			else if (typeInfo == "uint")
			{
				if (!(newData is uint))
					newData = uint(newData);
			}
			else if (typeInfo == "int")
			{
				if (!(newData is int))
					newData = int(newData);
			}
			else if (typeInfo == "Number")
			{
				if (!(newData is Number))
					newData = Number(newData);
			}
			else if (typeInfo == "Boolean")
			{
				if (!(newData is Boolean))
				{
					var strNewData:String = newData.toString();
					if (strNewData)
					{
						newData = (strNewData.toLowerCase() == "true") ? true : false;
					}
				}
			}
			
			if (property && data[property] !== newData)
			{
				data[property] = newData;
				dataGrid.dataProvider.itemUpdated(data);
				//这里要触发下重新排序
			}
			
			return true;
		}
		/**
		 * 测试编辑器中的数据是否有效并可以保存。 
		 * @return 
		 * 
		 */		
		protected function validate():Boolean
		{
			return true;
		}
		
		/**
		 * 点击之后停止渲染 
		 * @param event
		 * 
		 */		
		private function mouseUpDownMoveHandler(event:MouseEvent):void
		{
			if (event.cancelable)
				event.preventDefault();
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			var pt:Point = dataGrid.parent.globalToLocal(new Point(event.stageX, event.stageY));
			event.localX = pt.x;
			event.localY = pt.y;
			dataGrid.parent.dispatchEvent(event);
			event.stopPropagation();
		}
	}
}