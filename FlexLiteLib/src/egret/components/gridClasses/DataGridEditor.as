package egret.components.gridClasses
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import egret.components.DataGrid;
	import egret.components.Grid;
	import egret.core.IInvalidating;
	import egret.core.ISkin;
	import egret.core.IUIComponent;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.GridEvent;
	import egret.events.GridItemEditorEvent;
	import egret.events.UIEvent;
	
	use namespace ns_egret;
	
	[ExcludeClass]
	
	/**
	 * 数据表格编辑管理器。
	 * <p>DataGridEditor内包含用来管理一个表格编辑器的全部生命周期的逻辑和事件回调。</p>
	 * <p>一个DataGrid拥有一个DataGridEditor，DataGrid通过调用initialize()方法来进行编辑，然后通过uninitialize()来结束编辑</p>
	 * @author dom
	 */	
	public class DataGridEditor
	{
		/**
		 * 构造函数
		 * @param dataGrid 目标数据表格
		 */			
		public function DataGridEditor(dataGrid:DataGrid)
		{
			_dataGrid = dataGrid;
			
		}
		/**
		 * 双击计时器
		 */		
		private var doubleClickTimer:Timer;
		/**
		 * 收到一个双击事件的时候 ，最后一次的click之后为true
		 */		
		private var gotDoubleClickEvent:Boolean;
		/**
		 * 当收到一个UIEvent.ENTER事件的时候变为true
		 */		
		private var gotFlexEnterEvent:Boolean;
		
		private var lastEvent:Event;
		/**
		 * 最后一个被点击的渲染项的位置 
		 */		
		private var lastItemClickedPosition:Object;
		/**
		 * 用来确定mouse up和mouse down是否在同一个渲染项上 
		 */		
		private var lastItemDown:IVisualElement;
		/**
		 * 最后一个被编辑的或尝试编辑的项的位置 
		 */		
		private var lastEditedItemPosition:*;
		
		private var _dataGrid:DataGrid;
		/**
		 * 目标数据表格
		 */		
		public function get dataGrid():DataGrid
		{
			return _dataGrid;    
		}
		/**
		 * 得到数据表格内的grid 
		 * @return 
		 * 
		 */		
		public function get grid():Grid
		{
			return _dataGrid.grid;        
		}
		
		private var _editedItemPosition:Object;
		/**
		 * 当前正在编辑的单元格位置
		 * 对象内第一个属性rowIndex为行位置，第二个属性columnIndex为列位置
		 */		
		public function get editedItemPosition():Object
		{
			if (_editedItemPosition)
				return {rowIndex: _editedItemPosition.rowIndex,
					columnIndex: _editedItemPosition.columnIndex};
			else
				return _editedItemPosition;
		}
		public function set editedItemPosition(value:Object):void
		{
			if (!value)
			{
				setEditedItemPosition(null);
				return;
			}
			
			var newValue:Object = {rowIndex: value.rowIndex,
				columnIndex: value.columnIndex};
			setEditedItemPosition(newValue);
		}
		/**
		 * 设置当前类
		 */		
		private function setEditedItemPosition(coord:Object):void
		{
			if (!grid.enabled || !dataGrid.editable)
				return;
			
			if (!grid.dataProvider || grid.dataProvider.length == 0)
				return;
			if (itemEditorInstance && coord &&
				itemEditorInstance is IUIComponent &&
				_editedItemPosition.rowIndex == coord.rowIndex &&
				_editedItemPosition.columnIndex == coord.columnIndex)
			{
				IUIComponent(itemEditorInstance).setFocus();
				return;
			}
			if (itemEditorInstance)
			{
				if (!dataGrid.endItemEditorSession())
					return;
			}
			_editedItemPosition = coord;
			if (!coord)
				return;
			
			var rowIndex:int = coord.rowIndex;
			var columnIndex:int = coord.columnIndex;
			
			dataGrid.ensureCellIsVisible(rowIndex, columnIndex);
			
			createItemEditor(rowIndex, columnIndex);
			
			if (itemEditorInstance is IInvalidating)
				IInvalidating(itemEditorInstance).validateNow();
			
			var column:GridColumn = dataGrid.columns.getItemAt(columnIndex) as GridColumn;
			
			lastEditedItemPosition = _editedItemPosition;
			var dataGridEvent:GridItemEditorEvent = null;
			
			if (column.rendererIsEditable == false)
				dataGridEvent = new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START);
			
			if (dataGridEvent)
			{
				dataGridEvent.columnIndex = editedItemPosition.columnIndex;
				dataGridEvent.column = column;
				dataGridEvent.rowIndex = editedItemPosition.rowIndex;
				dataGrid.dispatchEvent(dataGridEvent);
			}
		}
		/**
		 * 当结束编辑的时候用来做一些时间错误的修正 
		 */		
		private var inEndEdit:Boolean = false;
		/**
		 * 当前处于激活状态的编辑框的实例。
		 */		
		public var itemEditorInstance:IGridItemEditor;
		
		private var _editedItemRenderer:IVisualElement;
		/**
		 * 编辑框的可视控件
		 * @return 
		 * 
		 */		
		public function get editedItemRenderer():IVisualElement
		{
			return _editedItemRenderer;
		}
		
		/**
		 * 被编辑的列位置，-1代表没有项被编辑
		 * @return 
		 * 
		 */		
		public function get editorColumnIndex():int
		{
			if (editedItemPosition)
				return editedItemPosition.columnIndex;
			
			return -1;
		}
		/**
		 * 被编辑的行位置，-1代表没有项被编辑 
		 * @return 
		 * 
		 */		
		public function get editorRowIndex():int
		{
			if (editedItemPosition)
				return editedItemPosition.rowIndex;
			
			return -1;
		}
		
		/**
		 * 被datagrid调用的方法，初始化编辑器。
		 * 
		 */		
		public function initialize():void
		{
			
			var grid:Grid = dataGrid.grid;
			
			dataGrid.addEventListener(KeyboardEvent.KEY_DOWN, dataGrid_keyboardDownHandler);
			grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, grid_gridMouseDownHandler, false, 1000);
			grid.addEventListener(GridEvent.GRID_MOUSE_UP, grid_gridMouseUpHandler, false, 1000);
			grid.addEventListener(GridEvent.GRID_DOUBLE_CLICK, grid_gridDoubleClickHandler);
		}
		
		/**
		 * 使编辑状态失效
		 * 
		 */		
		public function uninitialize():void
		{
			grid.removeEventListener(KeyboardEvent.KEY_DOWN, dataGrid_keyboardDownHandler);
			grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, grid_gridMouseDownHandler);
			grid.removeEventListener(GridEvent.GRID_MOUSE_UP, grid_gridMouseUpHandler);
			grid.removeEventListener(GridEvent.GRID_DOUBLE_CLICK, grid_gridDoubleClickHandler);
		}
		
		/**
		 * 关闭当前正在被打开的编辑框
		 * 
		 */		
		ns_egret function destroyItemEditor():void
		{
			
			if (grid.root)
				grid.systemManager.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
			
			var stage:Stage = grid.systemManager.stage;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler, true);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler);
			stage.removeEventListener(Event.RESIZE, editorAncestorResizeHandler);
			dataGrid.removeEventListener(Event.RESIZE, editorAncestorResizeHandler);
			
			if (itemEditorInstance || editedItemRenderer)
			{
				if (itemEditorInstance)
					itemEditorInstance.discard();
				
				var o:IVisualElement;
				if(itemEditorInstance)
					o = itemEditorInstance;
				else
					o = editedItemRenderer;
				
				o.removeEventListener(KeyboardEvent.KEY_DOWN, editor_keyDownHandler);
				o.removeEventListener(FocusEvent.FOCUS_OUT, editor_focusOutHandler);
				addRemoveUIEventEnterListener(DisplayObject(o), false);
				
				dataGrid.setFocus();
				if (itemEditorInstance)
					grid.removeElement(itemEditorInstance);
				else
					grid.invalidateDisplayList();   
				
				itemEditorInstance = null;
				_editedItemRenderer = null;
				_editedItemPosition = null;
			}
		}
		
		public var defaultDataGridItemEditor:Class;
		
		/**
		 * 在某行某列创建一个编辑器 
		 * @param rowIndex
		 * @param columnIndex
		 * 
		 */		
		ns_egret function createItemEditor(rowIndex:int, columnIndex:int):void
		{
			
			if (columnIndex >= grid.columns.length)
				return;
			
			var col:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn;
			var item:IGridItemRenderer = grid.getItemRendererAt(rowIndex, columnIndex);
			var cellBounds:Rectangle = grid.getCellBounds(rowIndex,columnIndex);
			var localCellOrigin:Point = cellBounds.topLeft;
			
			_editedItemRenderer = item;
			
			
			if (!col.rendererIsEditable)
			{
				var itemEditor:Class = col.itemEditor;
				if (!itemEditor)
					itemEditor = dataGrid.itemEditor;
				if (!itemEditor)
					itemEditor = GridColumn.defaultItemEditor;
				
				if (itemEditor == GridColumn.defaultItemEditor)
				{
					if (defaultDataGridItemEditor)
					{
						itemEditor = col.itemEditor = defaultDataGridItemEditor;
					}
				}
				
				itemEditorInstance = new itemEditor() as IGridItemEditor;
				itemEditorInstance.ownerChanged(dataGrid);
				itemEditorInstance.rowIndex = rowIndex;
				itemEditorInstance.column = col;
				
				grid.addElement(itemEditorInstance);
				
				itemEditorInstance.data = item.data;
				itemEditorInstance.width = cellBounds.width + 1;
				itemEditorInstance.height = cellBounds.height + 1;
				itemEditorInstance.setLayoutBoundsPosition(localCellOrigin.x, localCellOrigin.y);
				
				if (itemEditorInstance is IInvalidating)
					IInvalidating(itemEditorInstance).validateNow();
				itemEditorInstance.prepare();
				itemEditorInstance.visible = true;
			}
			else
			{
				if(item is IUIComponent)
					IUIComponent(item).setFocus();
			}
			
			if (itemEditorInstance != null || editedItemRenderer != null)
			{
				var editor:IEventDispatcher;
				if(itemEditorInstance)
				{
					editor = itemEditorInstance;
				}
				else
				{
					editor = editedItemRenderer;
				}
				editor.addEventListener(FocusEvent.FOCUS_OUT, editor_focusOutHandler);
				editor.addEventListener(KeyboardEvent.KEY_DOWN, editor_keyDownHandler);
				addRemoveUIEventEnterListener(DisplayObject(editor), true);
				
			}
			
			grid.invalidateDisplayList();
			
			if (grid.root)
				grid.systemManager.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
			var stage:Stage = grid.systemManager.stage;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler, true, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, sandBoxRoot_mouseDownHandler, false, 0, true);
			
			grid.systemManager.addEventListener(Event.RESIZE, editorAncestorResizeHandler);
			grid.addEventListener(Event.RESIZE, editorAncestorResizeHandler);        
		}
		
		
		private function wasLastEventMovingBackward():Boolean
		{
			if (lastEvent)
			{
				
				if (lastEvent.type == FocusEvent.KEY_FOCUS_CHANGE &&
					FocusEvent(lastEvent).shiftKey)
				{
					return true;
				}
				if (lastEvent.type == KeyboardEvent.KEY_DOWN && 
					KeyboardEvent(lastEvent).keyCode == Keyboard.TAB &&
					KeyboardEvent(lastEvent).shiftKey)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * 在指定行指定列开始编辑
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 */		
		public function startItemEditorSession(rowIndex:int, columnIndex:int):Boolean
		{
			if (!isValidCellPosition(rowIndex, columnIndex))
				return false;
			
			dataGrid.addEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING,
				dataGrid_gridItemEditorSessionStartingHandler,
				false,-50);
			
			var column:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn;
			
			if (!column || !column.visible)
				return false;
			var dataGridEvent:GridItemEditorEvent = new GridItemEditorEvent(
				GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING, 
				false, true); 
			dataGridEvent.rowIndex = Math.min(rowIndex, grid.dataProvider.length - 1);
			dataGridEvent.columnIndex = Math.min(columnIndex, grid.columns.length - 1);
			dataGridEvent.column = column;
			var editorStarted:Boolean = false;
			if (column.rendererIsEditable == true)
			{
				dataGrid_gridItemEditorSessionStartingHandler(dataGridEvent);   
				editorStarted = true;
			}
			else 
			{
				editorStarted = dataGrid.dispatchEvent(dataGridEvent);         
			}
			
			if (editorStarted) 
			{
				lastEditedItemPosition = { columnIndex: columnIndex, rowIndex: rowIndex };
				
				dataGrid.grid.caretRowIndex = rowIndex;
				dataGrid.grid.caretColumnIndex = columnIndex;
			}
			
			dataGrid.removeEventListener(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING,
				dataGrid_gridItemEditorSessionStartingHandler);
			
			return editorStarted;
		}
		
		/**
		 * 指定行指定列结束编辑
		 * @param cancel
		 * @return 
		 * 
		 */			
		public function endItemEditorSession(cancel:Boolean = false):Boolean
		{
			if (cancel)
			{
				cancelEdit();
				return false;
			}
			else
			{
				return endEdit();
			}
		}
		/**
		 * 结束编辑并且不保存
		 */		
		ns_egret function cancelEdit():void
		{
			if (itemEditorInstance)
			{
				
				dispatchCancelEvent();
				destroyItemEditor();
			}
			else if (editedItemRenderer)
			{
				
				destroyItemEditor();
			}
			
		}
		/**
		 * 当一个编辑被取消的时候，抛一个事件 
		 * 
		 */		
		private function dispatchCancelEvent():void
		{
			var dataGridEvent:GridItemEditorEvent =
				new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL);
			
			dataGridEvent.columnIndex = editedItemPosition.columnIndex;
			dataGridEvent.column = itemEditorInstance.column;
			dataGridEvent.rowIndex = editedItemPosition.rowIndex;
			dataGrid.dispatchEvent(dataGridEvent);
		}
		
		/**
		 * 当用户完成编辑的时候，这个方法被调用，用来关闭编辑框并保存数据。
		 * @return 
		 * 
		 */		
		private function endEdit():Boolean
		{
			
			if (!itemEditorInstance && editedItemRenderer)
			{
				inEndEdit = true;
				destroyItemEditor();
				inEndEdit = false;
				return true;
			}
			if (!itemEditorInstance)
				return false;
			
			inEndEdit = true;
			
			var itemPosition:Object = editedItemPosition;
			if (!saveItemEditorSession())
			{
				
				dispatchCancelEvent();
				inEndEdit = false;
				return false;
			}
			
			var dataGridEvent:GridItemEditorEvent =
				new GridItemEditorEvent(GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, false, true);
			dataGridEvent.columnIndex = itemPosition.columnIndex;
			dataGridEvent.column = dataGrid.columns.getItemAt(itemPosition.columnIndex) as GridColumn;
			dataGridEvent.rowIndex = itemPosition.rowIndex;
			dataGrid.dispatchEvent(dataGridEvent);
			
			inEndEdit = false;
			
			return true;
		}
		
		/**
		 * 保存当前编辑状态，可以被开发者取消。 
		 * @return 
		 * 
		 */		
		private function saveItemEditorSession():Boolean
		{
			var dataSaved:Boolean = false;
			
			if (itemEditorInstance)
			{
				dataSaved = itemEditorInstance.save();
				
				if (dataSaved)
					destroyItemEditor();
			}
			
			return dataSaved;
		}
		
		/**
		 * 在下一个可以编辑的位置开启编辑框 
		 * @param rowIndex
		 * @param columnIndex
		 * @param backward
		 * @return 
		 * 
		 */		
		private function openEditorInNextEditableCell(rowIndex:int, columnIndex:int, backward:Boolean):Boolean
		{
			var nextCell:Point = new Point(rowIndex, columnIndex);
			var openedEditor:Boolean = false;
			
			do
			{
				nextCell = getNextEditableCell(nextCell.x, nextCell.y, backward);
				
				if (nextCell)
					openedEditor = dataGrid.startItemEditorSession(nextCell.x, nextCell.y);                
			} while (nextCell && !openedEditor);
			
			return openedEditor;
		}
		
		/**
		 * 得到下一个可以被编辑的数据单元
		 * @param rowIndex
		 * @param columnIndex
		 * @param backward
		 * @return 
		 * 
		 */		
		private function getNextEditableCell(rowIndex:int, columnIndex:int, backward:Boolean):Point
		{
			var increment:int = backward ? -1 : 1;
			do {
				var nextColumn:int = columnIndex + increment;
				if (nextColumn >= 0 && nextColumn < dataGrid.columns.length)
				{
					columnIndex += increment;    
				}
				else
				{
					
					columnIndex = backward ? dataGrid.grid.columns.length - 1: 0;
					var nextRow:int = rowIndex + increment;
					if (nextRow >= 0 && nextRow < dataGrid.dataProvider.length)
						rowIndex += increment;
					else
						return null;
				}
			} while (!canEditColumn(columnIndex));
			
			return new Point(rowIndex, columnIndex);
		}
		
		/**
		 * 指定列是否可以被编辑 
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		private function canEditColumn(columnIndex:int):Boolean
		{
			var column:GridColumn = grid.columns.getItemAt(columnIndex) as GridColumn; 
			return (dataGrid.editable && 
				column.editable &&
				column.visible);
		}
			
		private function wasCellPreviouslySelected(rowIndex:int, columnIndex:int):Boolean
		{
			if (dataGrid.isRowSelectionMode())
				return dataGrid.selectionContainsIndex(rowIndex);
			else if (dataGrid.isCellSelectionMode())
				return dataGrid.selectionContainsCell(rowIndex, columnIndex);
			
			return false;
		}
		
		/**
		 * 判断一个数据单元的位置是否生效
		 * @param rowIndex
		 * @param cellIndex
		 * @return 
		 * 
		 */		
		private function isValidCellPosition(rowIndex:int, cellIndex:int):Boolean
		{
			if (rowIndex >= 0 && rowIndex < dataGrid.dataProvider.length &&
				cellIndex >= 0 && cellIndex < dataGrid.columns.length)
			{ 
				return true;
			}
			
			return false;
		}
		
		/**
		 * 对所有可视化子节点添加一个UIEvent.ENTER的事件
		 * @param element
		 * @param addListener
		 * 
		 */		
		private function addRemoveUIEventEnterListener(element:DisplayObject, addListener:Boolean):void
		{
			if (addListener)
				element.addEventListener(UIEvent.ENTER, editor_enterHandler);
			else
				element.removeEventListener(UIEvent.ENTER, editor_enterHandler);
			
			if (element is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = DisplayObjectContainer(element);
				var n:int = container.numChildren;
				for (var i:int = 0; i < n; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					
					if (child is DisplayObjectContainer)
					{
						addRemoveUIEventEnterListener(child, addListener);
					}
					else
					{
						if (addListener)
							child.addEventListener(UIEvent.ENTER, editor_enterHandler);
						else
							child.removeEventListener(UIEvent.ENTER, editor_enterHandler);
					}
				}
			}
			
		}
		
		/**
		 * 检测鼠标点击是否发生在了编辑框内 
		 * @param event
		 * @return 
		 * 
		 */		
		private function editorOwnsClick(event:Event):Boolean
		{
			if (event is MouseEvent)
			{
				var target:IUIComponent = getIUIComponent(DisplayObject(event.target));
				if (target)
					return editorOwns(target);
			}
			
			return false;
		}
		
		/**
		 * 检测一个子节点是否在编辑器内
		 * @param child
		 * @return 
		 * 
		 */		
		private function editorOwns(child:IUIComponent):Boolean
		{
			var isOwner:Function = function(parent:Object , child:Object):Boolean
			{
				if (parent.contains(child))
					return true;
				while (child && child != parent)
				{
					if(child is ISkin)
						child = ISkin(child).hostComponent;	
					else if (child is IUIComponent)
						child = IUIComponent(child).owner;
					else
						child = child.parent;
				}
				return child == parent;
			}
			return (itemEditorInstance && isOwner(itemEditorInstance , child) ||
				(editedItemRenderer && isOwner(editedItemRenderer , child)));
		}
		
		/**
		 * 得到拥有这个显示对象的控件 
		 * @param displayObject
		 * @return 
		 * 
		 */		
		private function getIUIComponent(displayObject:DisplayObject):IUIComponent
		{
			if (displayObject is IUIComponent)
				return IUIComponent(displayObject);
			
			var current:DisplayObject = displayObject.parent;
			while (current)
			{
				if (current is IUIComponent)
					return IUIComponent(current);
				
				current = current.parent;
			}
			
			return null;
		}

		/**
		 * startItemEditorSession事件的默认监听器
		 * @param event
		 * 
		 */		
		private function dataGrid_gridItemEditorSessionStartingHandler(event:GridItemEditorEvent):void
		{
			
			if (!event.isDefaultPrevented())
			{
				setEditedItemPosition({columnIndex: event.column.columnIndex, rowIndex: event.rowIndex});
			}
			else if (!itemEditorInstance)
			{
				_editedItemPosition = null;
				dataGrid.setFocus();
			}
		}
		
		/**
		 * 通过F2键来开启一个数据单元的编辑
		 * @param event
		 * 
		 */		
		private function dataGrid_keyboardDownHandler(event:KeyboardEvent):void
		{
			if (!dataGrid.editable || dataGrid.selectionMode == GridSelectionMode.NONE)
				return;
			
			if (event.isDefaultPrevented())
				return;
			
			lastEvent = event;
			
			if (event.keyCode == dataGrid.editKey)
			{
				if (itemEditorInstance)
					return;
				var nextCell:Point = null;
				if (dataGrid.isRowSelectionMode())
				{
					var lastColumn:int = lastEditedItemPosition ? lastEditedItemPosition.columnIndex : 0;
					openEditorInNextEditableCell(dataGrid.grid.caretRowIndex, 
						lastColumn - 1,
						false);
					return;
				}
				else if (canEditColumn(grid.caretColumnIndex))
				{
					dataGrid.startItemEditorSession(grid.caretRowIndex, grid.caretColumnIndex);                
				}
			}            
		}
		
		private function grid_gridMouseDownHandler(event:GridEvent):void
		{
			gotDoubleClickEvent = false;
			if (!dataGrid.editable || editorOwnsClick(event))
				return;
			
			if (!isValidCellPosition(event.rowIndex, event.columnIndex))
				return;
			
			lastEvent = event;
			
			var rowIndex:int = event.rowIndex;
			var columnIndex:int = event.columnIndex;
			var r:IGridItemRenderer = event.itemRenderer;
			
			lastItemDown = null;
			if (event.shiftKey || event.ctrlKey)
				return;
			if (itemEditorInstance)
			{
				if (!dataGrid.endItemEditorSession())
				{
					dataGrid.endItemEditorSession(true);
				}
				return;
			}
			var column:GridColumn = dataGrid.columns.getItemAt(columnIndex) as GridColumn;
			if (r && 
				(column.rendererIsEditable || dataGrid.editOnMouseUp|| wasCellPreviouslySelected(rowIndex, columnIndex)))
			{
				lastItemDown = r;
			}
			
		}
		
		/**
		 * 是否点击了开启编辑的编辑器
		 * @param event
		 * 
		 */		
		private function grid_gridMouseUpHandler(event:GridEvent):void
		{
			if (!dataGrid.editable)
				return;
			
			if (!isValidCellPosition(event.rowIndex, event.columnIndex))
				return;
			
			lastEvent = event;
			
			var eventRowIndex:int = event.rowIndex;
			var eventColumnIndex:int = event.columnIndex;
			if (dataGrid.selectionLength != 1)
				return;
			
			var rowIndex:int = eventRowIndex;
			var columnIndex:int = eventColumnIndex;
			
			var r:IVisualElement = event.itemRenderer;
			
			if (r && r != editedItemRenderer && 
				lastItemDown && lastItemDown == r)
			{
				if (columnIndex >= 0)
				{
					if (grid.columns.getItemAt(columnIndex).editable)
					{
						
						if (doubleClickTimer)
						{
							if (rowIndex == lastItemClickedPosition.rowIndex &&
								columnIndex == lastItemClickedPosition.columnIndex)
							{
								lastItemDown == null;
								return;
							}
							else 
							{
								
								doubleClickTimer.stop();
								doubleClickTimer = null;
							}
						}
						
						lastItemClickedPosition = { columnIndex: columnIndex, rowIndex: rowIndex};
						if (dataGrid.editOnDoubleClick || 
							InteractiveObject(lastItemDown).doubleClickEnabled == false)
						{
							
							dataGrid.startItemEditorSession(rowIndex, columnIndex);
						}
						else 
						{
							doubleClickTimer = new Timer(dataGrid.doubleClickTime, 1);
							doubleClickTimer.addEventListener(TimerEvent.TIMER, doubleClickTimerHandler);
							doubleClickTimer.start();                        
						}
					}
				}
			}
			
			lastItemDown = null;            
		}
		
		/**
		 * 是否双击了被开启的编辑器
		 * @param event
		 * 
		 */		
		private function grid_gridDoubleClickHandler(event:GridEvent):void
		{
			if (!dataGrid.editable)
				return;
			
			if (!isValidCellPosition(event.rowIndex, event.columnIndex))
				return;
			
			lastEvent = event;
			
			gotDoubleClickEvent = true;
		}
		
		/**
		 * 双击事件计时器 
		 * @param event
		 * 
		 */		
		private function doubleClickTimerHandler(event:TimerEvent):void
		{
			doubleClickTimer.removeEventListener(TimerEvent.TIMER, doubleClickTimerHandler);
			doubleClickTimer = null;
			
			if (!gotDoubleClickEvent)
			{
				dataGrid.startItemEditorSession(lastItemClickedPosition.rowIndex, lastItemClickedPosition.columnIndex);
			}
			
			gotDoubleClickEvent = false;
		}
		
		private function deactivateHandler(event:Event):void
		{
			if (itemEditorInstance || editedItemRenderer)
			{
				if (!dataGrid.endItemEditorSession())
				{
					dataGrid.endItemEditorSession(true);
				}
				dataGrid.setFocus();
			}
		}
		
		/**
		 * 失去焦点的时候关闭这个编辑器
		 * @param event
		 * 
		 */		
		private function editor_focusOutHandler(event:FocusEvent):void
		{
			if (event.relatedObject)
			{
				var component:IUIComponent = getIUIComponent(event.relatedObject);
				if (component && editorOwns(component))
					return;                
			}
			if (!event.relatedObject)
				return;
			
			if (itemEditorInstance || editedItemRenderer)
			{
				if (!dataGrid.endItemEditorSession())
				{
					dataGrid.endItemEditorSession(true);
				}
			}        
		}
		
		private function editor_enterHandler(event:Event):void
		{
			
			if (event is UIEvent)
				gotFlexEnterEvent = true;
		}
		/**
		 * 用来停止编辑的按键事件监听器 
		 * @param event
		 * 
		 */		
		private function editor_keyDownHandler(event:KeyboardEvent):void
		{
			
			if (event.isDefaultPrevented())
			{
				if (!(event.charCode == Keyboard.ENTER && gotFlexEnterEvent))
				{
					gotFlexEnterEvent = false;
					return;
				}
			}
			
			gotFlexEnterEvent = false;
			if (event.keyCode == Keyboard.ESCAPE)
			{
				cancelEdit();
			}
			else if (event.ctrlKey && event.charCode == 46)
			{   
				cancelEdit();
			}
			event.stopPropagation();
		}
		
		private function editorAncestorResizeHandler(event:Event):void
		{
			if (!dataGrid.endItemEditorSession())
			{
				dataGrid.endItemEditorSession(true);
			}
		}
		
		private function sandBoxRoot_mouseDownHandler(event:Event):void
		{
			if (editorOwnsClick(event))
			{
				return;
			}
			if (dataGrid.scroller && 
				dataGrid.scroller.contains(DisplayObject(event.target)) &&
				!grid.contains(DisplayObject(event.target)))
			{
				return;
			}
			if (!dataGrid.endItemEditorSession())
			{
				dataGrid.endItemEditorSession(true);
			}
			dataGrid.setFocus();
		}
		
	}
}