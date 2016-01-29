package egret.components.gridClasses
{
	import flash.geom.Rectangle;
	
	import egret.collections.ICollection;
	import egret.collections.ICollectionView;
	import egret.components.Grid;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	
	use namespace ns_egret;
	
	[ExcludeClass]
	/**
	 * 用 GridSelection类去追踪数据表格的selectionMode属性。
	 */	
	public class GridSelection
	{
		
		/**
		 * 排序过的选择或为选择的数据单元尺寸的列表，用于根据选择模式来呈现行和数据单元选项用的。
		 * 
		 */		
		private var cellRegions:Vector.<CellRect> = new Vector.<CellRect>();
		
		/**
		 * 如果preserveSelection,和 selectionMode属性值是"singleRow" 或者 "singleCell"的话。
		 * 缓存这个数据项一边我们在之后刷新的时候可以得到这个选择项的索引。
		 */		
		private var selectedItem:Object;
		
		
		private var inCollectionHandler:Boolean;
		
		public function GridSelection()
		{
			super();
		}
		
		private var _grid:Grid;
		
		/**
		 * 相关联的gird数据表格 
		 * @return 
		 * 
		 */		
		public function get grid():Grid
		{
			return _grid;
		}
		
		public function set grid(value:Grid):void
		{
			_grid = value;
		}
		
		private var _preserveSelection:Boolean = true;
		
		/**
		 * 如果这个值为true，并且selectionMode的值为GridSelectionMode.SINGLE_ROW或者
		 * GridSelectionMode.SINGLE_CELL， 当 dataProvider刷新其值之后，选择项被保存到收集表里。
		 * 默认值为true
		 * @return 
		 * 
		 */		
		public function get preserveSelection():Boolean
		{
			return _preserveSelection;
		}
		
		public function set preserveSelection(value:Boolean):void
		{
			if (_preserveSelection == value)
				return;
			
			_preserveSelection = value;
			
			selectedItem = null;
			if (_preserveSelection && 
				(selectionMode == GridSelectionMode.SINGLE_ROW || 
					selectionMode == GridSelectionMode.SINGLE_CELL) && 
				selectionLength > 0)
			{
				if (selectionMode == GridSelectionMode.SINGLE_ROW)
					selectedItem = grid.dataProvider.getItemAt(allRows()[0]);
				else  
					selectedItem = grid.dataProvider.getItemAt(allCells()[0].rowIndex);
			}
		}
		
		private var _requireSelection:Boolean = false;
		
		/**
		 * 当为true的时候，数据中的想必须总是至少有一个处于选择状态。
		 * 默认为false
		 * @return 
		 * 
		 */		
		public function get requireSelection():Boolean
		{
			return _requireSelection;
		}
		
		public function set requireSelection(value:Boolean):void
		{
			if (_requireSelection == value)
				return;
			
			_requireSelection = value;
			
			if (_requireSelection)
				ensureRequiredSelection();
		}
		
		private var _selectionLength:int = 0;    
		/**
		 * 选择项的长度
		 * @return 
		 * 
		 */		
		public function get selectionLength():int
		{
			var isRows:Boolean = isRowSelectionMode();
			
			if (_selectionLength < 0)
			{
				_selectionLength = 0;
				
				var cellRegionsLength:int = cellRegions.length;            
				for (var i:int = 0; i < cellRegionsLength; i++)
				{
					var cr:CellRect = cellRegions[i];
					var numSelected:int = isRows ? cr.height : cr.height * cr.width;
					
					if (cr.isAdd)
						_selectionLength += numSelected;
					else
						_selectionLength -= numSelected;
				}
			}
			
			return _selectionLength;        
		}
		
		private var _selectionMode:String = GridSelectionMode.SINGLE_ROW;
		
		/**
		 * 选择模式，有如下几个属性：
		 *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
		 *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
		 *  <code>GridSelectionMode.NONE</code>, 
		 *  <code>GridSelectionMode.SINGLE_CELL</code>, 
		 *  <code>GridSelectionMode.SINGLE_ROW</code>
		 * @return 
		 * 
		 */		
		public function get selectionMode():String
		{
			return _selectionMode;
		}
		
		public function set selectionMode(value:String):void
		{
			if (value == _selectionMode)
				return;
			
			switch (value)
			{
				case GridSelectionMode.SINGLE_ROW:
				case GridSelectionMode.MULTIPLE_ROWS:
				case GridSelectionMode.SINGLE_CELL:
				case GridSelectionMode.MULTIPLE_CELLS:
				case GridSelectionMode.NONE:
					_selectionMode = value;
					removeAll();
					break;
			}
		}
		
		/**
		 * 如果选择模式selectionMode为GridSelectionMode.SINGLE_CELL或者
		 * GridSelectionMode.MULTIPLE_CELLS的时候，返回一个所有选择的数据单元的列表
		 * @return 
		 * 
		 */		
		public function allCells():Vector.<CellPosition>
		{
			var cells:Vector.<CellPosition> = new Vector.<CellPosition>;
			
			if (!isCellSelectionMode())
				return cells;
			var bounds:Rectangle = getCellRegionsBounds();        
			var left:int = bounds.left;
			var right:int = bounds.right;
			var bottom:int = bounds.bottom;
			
			for (var rowIndex:int = bounds.top; rowIndex < bottom; rowIndex++)
			{
				for (var columnIndex:int = left; columnIndex < right; columnIndex++)
				{
					if (regionsContainCell(rowIndex, columnIndex))
						cells.push(new CellPosition(rowIndex, columnIndex));
				}
			}
			
			return cells;
		}
		
		/**
		 * 如果选择模式 selectionMode为GridSelectionMode.SINGLE_ROW或者GridSelectionMode.MULTIPLE_ROWS的时候
		 * 返回被选择的行的列表
		 * @return 
		 * 
		 */		
		public function allRows():Vector.<int>
		{
			if (!isRowSelectionMode())
				return new Vector.<int>(0, true);
			
			var rows:Vector.<int> = new Vector.<int>();
			
			var bounds:Rectangle = getCellRegionsBounds();
			var bottom:int = bounds.bottom;
			
			for (var rowIndex:int = bounds.top; rowIndex < bottom; rowIndex++)
			{
				
				if (regionsContainCell(rowIndex, 0))
					rows.push(rowIndex);
			}
			
			return rows;
		}
		/**
		 * 如果selectionMode为 GridSelectionMode.MULTIPLE_ROWS的时候选择所有行。
		 * 如果selectionMode为GridSelectionMode.MULTIPLE_CELLS的时候选择所有可见数据单元
		 * @return 如果选择项改变的时候返回true
		 * 
		 */		
		public function selectAll():Boolean
		{
			var maxRows:int = getGridDataProviderLength();
			
			if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				return setRows(0, maxRows);
			}
			else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
			{
				var maxColumns:int = getGridColumnsLength();
				return setCellRegion(0, 0, maxRows, maxColumns);
			}
			
			return false;
		}
		/**
		 * 移除掉当前的选择项。
		 * @return 
		 * 
		 */		
		public function removeAll():Boolean
		{
			var selectionChanged:Boolean = selectionLength > 0;
			
			removeSelection();
			selectionChanged = ensureRequiredSelection() || selectionChanged;
			
			return selectionChanged;
		}
		
		/**
		 * 如果选择模式selectionMode为GridSelectionMode.SINGLE_ROW或者GridSelectionMode.MULTIPLE_ROWS
		 * 的话，则返回指定行是否在当前的选择项里。
		 * @param rowIndex
		 * @return 
		 * 
		 */		
		public function containsRow(rowIndex:int):Boolean
		{
			if (!validateIndex(rowIndex))
				return false;
			
			return regionsContainCell(rowIndex, 0);
		}
		/**
		 * 如果选择模式selectionMode为GridSelectionMode.SINGLE_ROW,
		 * 则返回指定的多行是否在当前的选择项里。
		 * @param rowsIndices
		 * @return 
		 * 
		 */		
		public function containsRows(rowsIndices:Vector.<int>):Boolean
		{
			if (!validateIndices(rowsIndices))
				return false;
			
			for each (var rowIndex:int in rowsIndices)
			{
				if (!regionsContainCell(rowIndex, 0))
					return false;            
			}
			
			return true;
		}
		/**
		 * 指定选择的行 
		 * @param rowIndex
		 * @return 
		 * 
		 */		
		public function setRow(rowIndex:int):Boolean
		{        
			if (!validateIndex(rowIndex))
				return false;
			
			internalSetCellRegion(rowIndex);
			
			return true;
		}
		/**
		 * 如果可多选，添加选定行
		 * @param rowIndex
		 * @return 
		 * 
		 */		
		public function addRow(rowIndex:int):Boolean
		{
			if (!validateIndex(rowIndex))
				return false;
			
			if (selectionMode != GridSelectionMode.MULTIPLE_ROWS)
				return false;
			
			internalAddCell(rowIndex);
			
			return true;
		}
		
		/**
		 * 移除选定航 
		 * @param rowIndex
		 * @return 
		 * 
		 */		
		public function removeRow(rowIndex:int):Boolean
		{
			if (!validateIndex(rowIndex) )
				return false;
			
			if (requireSelection && containsRow(rowIndex) && selectionLength == 1)
				return false;
			
			internalRemoveCell(rowIndex);
			
			return true;
		}
		
		/**
		 * 设置从rowIndex开始选择rowCount这么多行
		 * @param rowIndex
		 * @param rowCount
		 * @return 
		 * 
		 */		
		public function setRows(rowIndex:int, rowCount:int):Boolean
		{
			if (!validateRowRegion(rowIndex, rowCount))
				return false;
			
			internalSetCellRegion(rowIndex, 0, rowCount, 1);
			
			return true;
		}
		
		/**
		 * 是否包含从rowIndex开始的columnIndex这么多个选择行
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function containsCell(rowIndex:int, columnIndex:int):Boolean
		{   
			if (!validateCell(rowIndex, columnIndex))
				return false;
			
			return regionsContainCell(rowIndex, columnIndex);
		}
		/**
		 * 是否包含指定的选择项
		 * @param rowIndex
		 * @param columnIndex
		 * @param rowCount
		 * @param columnCount
		 * @return 
		 * 
		 */		
		public function containsCellRegion(rowIndex:int, columnIndex:int,
										   rowCount:int, columnCount:int):Boolean
		{
			if (!validateCellRegion(rowIndex, columnIndex, rowCount, columnCount))
				return false;
			
			if (rowCount * columnCount > selectionLength)
				return false;
			
			var cellRegionsLength:int = cellRegions.length;
			
			if (cellRegionsLength == 0)
				return false;
			if (cellRegionsLength == 1)
			{
				var cr:CellRect = cellRegions[0];
				return (rowIndex >= cr.top && columnIndex >= cr.left &&
					rowIndex + rowCount <= cr.bottom &&
					columnIndex + columnCount <= cr.right);
			}
			var bottom:int = rowIndex + rowCount;
			var right:int = columnIndex + columnCount;
			
			for (var r:int = rowIndex; r < bottom; r++)
			{
				for (var c:int = columnIndex; c < right; c++)
				{
					if (!containsCell(r, c))
						return false;
				}
			}
			
			return true;
		}
		/**
		 * 设置选择的数据单元 
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function setCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (!validateCell(rowIndex, columnIndex))
				return false;
			var columnVisible:Boolean = isColumnVisible(columnIndex);
			if (columnVisible)
				internalSetCellRegion(rowIndex, columnIndex, 1, 1);
			
			return columnVisible;
		}
		/**
		 * 如果可多选，则添加一个选择单元 
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function addCell(rowIndex:int, columnIndex:int):Boolean
		{   
			if (!validateCellRegion(rowIndex, columnIndex, 1, 1))
				return false;
			var columnVisible:Boolean = isColumnVisible(columnIndex);
			if (columnVisible)
				internalAddCell(rowIndex, columnIndex);
			
			return columnVisible;
		}
		/**
		 * 从 rowIndex开始移除columnIndex这么多个选择的数据单元
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function removeCell(rowIndex:int, columnIndex:int):Boolean
		{
			if (!validateCell(rowIndex, columnIndex))
				return false;
			
			if (requireSelection && containsCell(rowIndex, columnIndex) && selectionLength == 1)
				return false;
			
			internalRemoveCell(rowIndex, columnIndex);
			
			return true;
		}
		/**
		 * 设置选择单元 
		 * @param rowIndex
		 * @param columnIndex
		 * @param rowCount
		 * @param columnCount
		 * @return 
		 * 
		 */		
		public function setCellRegion(rowIndex:int, columnIndex:int, 
									  rowCount:uint, columnCount:uint):Boolean
		{
			if (!validateCellRegion(rowIndex, columnIndex, rowCount, columnCount))
				return false;
			
			removeSelection();
			
			var startColumnIndex:int = columnIndex;
			var curColumnCount:int = 0;
			
			var endColumnIndex:int = columnIndex + columnCount - 1;
			for (var i:int = columnIndex; i <= endColumnIndex; i++)
			{    
				
				var columnVisible:Boolean = isColumnVisible(i);
				if (columnVisible)
				{
					curColumnCount++;
					continue;
				}
				internalAddCellRegion(rowIndex, startColumnIndex, rowCount, curColumnCount);
				
				curColumnCount = 0;
				startColumnIndex = i + 1;
			}
			if (curColumnCount > 0)
				internalAddCellRegion(rowIndex, startColumnIndex, rowCount, curColumnCount);
			
			return true;
		}
		
		private function isRowSelectionMode():Boolean
		{
			var mode:String = selectionMode;       
			return mode == GridSelectionMode.SINGLE_ROW || 
				mode == GridSelectionMode.MULTIPLE_ROWS;
		}
		
		private function isCellSelectionMode():Boolean
		{
			var mode:String = selectionMode;        
			return mode == GridSelectionMode.SINGLE_CELL || 
				mode == GridSelectionMode.MULTIPLE_CELLS;
		}
		/**
		 * 指定的列是否有效
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		private function isColumnVisible(columnIndex:int):Boolean
		{
			return GridColumn(grid.columns.getItemAt(columnIndex)).visible;
		}
		/**
		 * 得到列的数量 
		 * @return 
		 * 
		 */		
		private function getGridColumnsLength():uint
		{
			if (grid == null)
				return 0;
			
			var columns:ICollection = grid.columns;
			return (columns) ? columns.length : 0;
		}
		
		private function getGridDataProviderLength():uint
		{
			if (grid == null)
				return 0;
			
			var dataProvider:ICollection = grid.dataProvider;
			return (dataProvider) ? dataProvider.length : 0;
		}  
		/**
		 * 如果提供的数据单元在被选择的数据单元内，则返回true
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		private function regionsContainCell(rowIndex:int, columnIndex:int):Boolean
		{   
			var cellRegionsLength:int = cellRegions.length;
			var index:int = -1;
			for (var i:int = 0; i < cellRegionsLength; i++)
			{
				var cr:CellRect = cellRegions[i];
				if (cr.isAdd && cr.containsCell(rowIndex, columnIndex))
					index = i;
			}
			if (index == -1) 
				return false;
			for (i = index + 1; i < cellRegionsLength; i++)
			{
				cr = cellRegions[i];
				if (!cr.isAdd && cr.containsCell(rowIndex, columnIndex))
					return false;
			}
			
			return true;
		}
		
		/**
		 * 如果requiredSelection为真，那么必须至少有一个数据单元或行被选中。如果选中项发生了变化，
		 * 那么返回真。
		 * @return 如果选择项改变了
		 * 
		 */		
		private function ensureRequiredSelection():Boolean
		{
			var selectionChanged:Boolean;
			
			if (!requireSelection)
				return false;
			
			if (getGridDataProviderLength() == 0 || getGridColumnsLength() == 0)
				return false;
			if (isRowSelectionMode())
			{
				if (selectionLength == 0)
					selectionChanged = grid.setSelectedIndex(0);
			}
			else if (isCellSelectionMode())
			{
				if (selectionLength == 0)
					selectionChanged = grid.setSelectedCell(0, 0);
			}
			
			return selectionChanged;
		}
		
		/**
		 * 移除选择项
		 * 
		 */		
		private function removeSelection():void
		{
			cellRegions.length = 0;       
			_selectionLength = 0;
			selectedItem = null;
		}
				
		protected function validateIndex(index:int):Boolean
		{
			
			if (inCollectionHandler)
				return true;
			
			return isRowSelectionMode() && 
				index >= 0 && index < getGridDataProviderLength();
		}
		
		
		/**
		 * 如果选择模式为多行， 并且每一个索引表里的索引在数据源里都为有效的。那么返回真
		 * @param indices
		 * @return 
		 * 
		 */		
		protected function validateIndices(indices:Vector.<int>):Boolean
		{
			if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				
				if (inCollectionHandler)
					return true;
				
				for each (var index:int in indices)
				{
					if (index < 0 || index >= getGridDataProviderLength())
						return false;
				}            
				return true;
			}
			
			return false;
		}
		
		/**
		 * 如果选择模式为单数据单元或多数据单元，并且在列中都为有效的。那么返回真。
		 * @param rowIndex
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		protected function validateCell(rowIndex:int, columnIndex:int):Boolean
		{
			
			if (inCollectionHandler)
				return true;
			
			return isCellSelectionMode() && 
				rowIndex >= 0 && rowIndex < getGridDataProviderLength() &&
				columnIndex >= 0 && columnIndex < getGridColumnsLength();
		}
		
		/**
		 * 如果选择模式为多数据单元， 并且整个数据的都在指定区域内的话，返回真。
		 * @param rowIndex
		 * @param columnIndex
		 * @param rowCount
		 * @param columnCount
		 * @return 
		 * 
		 */		
		protected function validateCellRegion(rowIndex:int, columnIndex:int, 
											  rowCount:int, columnCount:int):Boolean
		{
			if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
			{
				
				if (inCollectionHandler)
					return true;
				
				var maxRows:int = getGridDataProviderLength();
				var maxColumns:int = getGridColumnsLength();
				return (rowIndex >= 0 && rowCount >= 0 &&
					rowIndex + rowCount <= maxRows &&
					columnIndex >= 0 && columnCount >= 0 &&
					columnIndex + columnCount <= maxColumns);
			}
			
			return false;       
		}
		
		/**
		 * 如果选择模式为多单元， 并且整个行的区域里包含在这个表格里。则返回true
		 * @param rowIndex
		 * @param rowCount
		 * @return 
		 * 
		 */		
		protected function validateRowRegion(rowIndex:int, rowCount:int):Boolean
		{
			if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
			{
				
				if (inCollectionHandler)
					return true;
				
				var maxRows:int = getGridDataProviderLength();
				return (rowIndex >= 0 && rowCount >= 0 && rowIndex + rowCount <= maxRows);
			}
			
			return false;       
		}
		
		/**
		 * 初始化列表的数据单元区域
		 * @param rowIndex
		 * @param columnIndex
		 * @param rowCount
		 * @param columnCount
		 * 
		 */		
		private function internalSetCellRegion(rowIndex:int, columnIndex:int=0, 
											   rowCount:uint=1, columnCount:uint=1):void
		{
			var cr:CellRect = 
				new CellRect(rowIndex, columnIndex, rowCount, columnCount, true);
			
			removeSelection();
			cellRegions.push(cr);
			
			_selectionLength = rowCount * columnCount;
			
			if (preserveSelection && 
				(selectionMode == GridSelectionMode.SINGLE_ROW || 
					selectionMode == GridSelectionMode.SINGLE_CELL))
			{
				selectedItem = grid.dataProvider.getItemAt(rowIndex);
			}
		}
	
		private function internalAddCellRegion(rowIndex:int, columnIndex:int=0, 
											   rowCount:uint=1, columnCount:uint=1):void
		{
			var cr:CellRect = 
				new CellRect(rowIndex, columnIndex, rowCount, columnCount, true);
			
			cellRegions.push(cr);
			
			_selectionLength += rowCount * columnCount;
		}
		
		/**
		 * 添加指定行/数据单元到列表的数据单元区域。
		 * @param rowIndex
		 * @param columnIndex
		 * 
		 */		
		private function internalAddCell(rowIndex:int, columnIndex:int=0):void
		{
			if (!regionsContainCell(rowIndex, columnIndex))
			{
				var cr:CellRect = 
					new CellRect(rowIndex, columnIndex, 1, 1, true);
				cellRegions.push(cr);
				if (_selectionLength >= 0)
					_selectionLength++;
			}
		}
		
		/**
		 * 移除指定行/数据单元到列表的数据单元区域。
		 * @param rowIndex
		 * @param columnIndex
		 * 
		 */	
		private function internalRemoveCell(rowIndex:int, columnIndex:int=0):void
		{
			if (regionsContainCell(rowIndex, columnIndex))
			{
				var cr:CellRect = 
					new CellRect(rowIndex, columnIndex, 1, 1, false);
				cellRegions.push(cr);
				if (_selectionLength >= 0)
					_selectionLength--;
				
				selectedItem = null;
			}
		}
		/**
		 * 得到所有添加的数据单元区域的矩形区域
		 * @return 
		 * 
		 */		
		private function getCellRegionsBounds():Rectangle
		{
			var bounds:Rectangle = new Rectangle();                         
			var cellRegionsLength:int = cellRegions.length;
			for (var i:int = 0; i < cellRegionsLength; i++)
			{
				var cr:CellRect = cellRegions[i];
				if (!cr.isAdd)
					continue;
				
				bounds = bounds.union(cr);
			}
			
			return bounds;
		}
		
		/**
		 * 当数据源抛出一个 CollectionEvent.COLLECTION_CHANGE时间的时候，将会触发这个监听器。
		 * @param event
		 * 
		 */		
		public function dataProviderCollectionChanged(event:CollectionEvent):void
		{
			inCollectionHandler = true;
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					dataProviderCollectionAdd(event);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					dataProviderCollectionMove(event);
					break;
				}
					
				case CollectionEventKind.REFRESH:
				{
					dataProviderCollectionRefresh(event);
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					dataProviderCollectionRemove(event);
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					dataProviderCollectionReplace(event);
					break;
				}
					
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
			}
			
			inCollectionHandler = false;
		}
		
		/**
		 * 向收数据表里添加一项 
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionAdd(event:CollectionEvent):void
		{
			handleRowAdd(event.location, event.items.length);
			ensureRequiredSelection();
		}
		
		private function handleRowAdd(insertIndex:int, insertCount:int=1):void
		{
			for (var cnt:int = 0; cnt < insertCount; cnt++)
			{
				for (var crIndex:int = 0; crIndex < cellRegions.length; crIndex++)
				{
					var cr:CellRect = cellRegions[crIndex];
					if (insertIndex <= cr.y)
					{
						cr.y++;
					}
					else if (insertIndex < cr.bottom)
					{
						var newCR:CellRect = 
							new CellRect(insertIndex + 1, cr.x, 
								cr.bottom - insertIndex, cr.width, 
								cr.isAdd);
						
						cr.height = insertIndex - cr.y;
						cellRegions.splice(++crIndex, 0, newCR);                    
						_selectionLength = -1;      
					}
				}
			}
		}
		/**
		 * 想已经从旧的位置移动到新的位置 
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionMove(event:CollectionEvent):void
		{
			var oldRowIndex:int = event.oldLocation;
			var newRowIndex:int = event.location;
			
			handleRowRemove(oldRowIndex);
			if (newRowIndex > oldRowIndex)
				newRowIndex--;
			
			handleRowAdd(newRowIndex);
		}
		/**
		 * 排序或者过滤器改变的时候 
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionRefresh(event:CollectionEvent):void
		{       
			handleRefreshAndReset(event);
		}
		
		private function handleRefreshAndReset(event:CollectionEvent):void
		{
			
			if (selectedItem)
			{
				var view:ICollectionView = event.currentTarget as ICollectionView;       
				if (view && view.getItemIndex(selectedItem)!=-1)
				{
					var newRowIndex:int = grid.dataProvider.getItemIndex(selectedItem);
					if (selectionMode == GridSelectionMode.SINGLE_ROW)
					{
						internalSetCellRegion(newRowIndex);
					}
					else
					{
						var oldSelectedCell:CellPosition = allCells()[0];
						internalSetCellRegion(newRowIndex, oldSelectedCell.columnIndex);
					}
					return;
				}
			}
			removeSelection();
			ensureRequiredSelection();
			return;            
		}
		
		/**
		 * 已经有一项从数据表里删除了
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionRemove(event:CollectionEvent):void
		{
			if (getGridDataProviderLength() == 0)
			{
				removeSelection();
				return;   
			}
			
			handleRowRemove(event.location, event.items.length);       
			ensureRequiredSelection();
		}
		
		private function handleRowRemove(removeIndex:int, removeCount:int=1):void
		{
			for (var cnt:int = 0; cnt < removeCount; cnt++)
			{
				var crIndex:int = 0
				while (crIndex < cellRegions.length)
				{
					var cr:CellRect = cellRegions[crIndex];
					if (removeIndex < cr.y)
					{
						cr.y--;
					}
					else if (removeIndex >= cr.y && removeIndex < cr.bottom)
					{
						_selectionLength = -1;  
						cr.height--;
						if (cr.height == 0)
						{
							cellRegions.splice(crIndex, 1);
							continue;
						}
					}
					crIndex++;
				}
			}        
		}
		
		/**
		 * 项被替换
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionReplace(event:CollectionEvent):void
		{
		}
		
		/**
		 * 数据表被重置的时候
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionReset(event:CollectionEvent):void
		{        
			handleRefreshAndReset(event);
		}
		/**
		 *一个或多个项被更新的时候 
		 * @param event
		 * 
		 */		
		private function dataProviderCollectionUpdate(event:CollectionEvent):void
		{
			
		}
		
		/**
		 * CollectionEvent.COLLECTION_CHANGE的监听器
		 * @param event
		 * 
		 */		
		public function columnsCollectionChanged(event:CollectionEvent):void
		{
			inCollectionHandler = true;
			
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					columnsCollectionAdd(event);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					columnsCollectionMove(event);
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					columnsCollectionRemove(event);
					break;
				}
					
				case CollectionEventKind.REPLACE:
				case CollectionEventKind.UPDATE:
				{
					break;
				}
					
				case CollectionEventKind.REFRESH:
				{
					columnsCollectionRefresh(event);
					break;                
				}
				case CollectionEventKind.RESET:
				{
					columnsCollectionReset(event);
					break;                
				}
			}
			
			inCollectionHandler = false;
		}
		
		/**
		 * 向列列表中添加一列 
		 * @param event
		 * 
		 */		
		private function columnsCollectionAdd(event:CollectionEvent):void
		{
			
			if (!isCellSelectionMode())
				return;
			
			handleColumnAdd(event.location, event.items.length);
			ensureRequiredSelection();
		}
		
		private function handleColumnAdd(insertIndex:int, insertCount:int=1):void
		{
			for (var cnt:int = 0; cnt < insertCount; cnt++)
			{
				for (var crIndex:int = 0; crIndex < cellRegions.length; crIndex++)
				{
					var cr:CellRect = cellRegions[crIndex];
					if (insertIndex <= cr.x)
					{
						cr.x++;
					}
					else if (insertIndex < cr.x)
					{
						var newCR:CellRect = 
							new CellRect(cr.y, insertIndex + 1,
								cr.height, cr.right - insertIndex, 
								cr.isAdd);
						
						cr.width = insertIndex - cr.x;
						cellRegions.splice(++crIndex, 0, newCR);
						_selectionLength = -1;  
					}
				}
			}
		}
		/**
		 * 列从旧的位置移动到了新的位置 
		 * @param event
		 * 
		 */		
		private function columnsCollectionMove(event:CollectionEvent):void
		{
			
			if (!isCellSelectionMode())
				return;
			
			var oldColumnIndex:int = event.oldLocation;
			var newColumnIndex:int = event.location;
			
			handleColumnRemove(oldColumnIndex);
			if (newColumnIndex > oldColumnIndex)
				newColumnIndex--;
			
			handleColumnAdd(newColumnIndex);
		}   
		/**
		 * 列被移除 
		 * @param event
		 * 
		 */		
		private function columnsCollectionRemove(event:CollectionEvent):void
		{
			
			if (!isCellSelectionMode())
				return;
			
			if (getGridColumnsLength() == 0)
			{
				removeSelection();
				return;   
			}
			
			handleColumnRemove(event.location, event.items.length);      
			ensureRequiredSelection();
		}
		
		private function handleColumnRemove(removeIndex:int, removeCount:int=1):void
		{
			for (var cnt:int = 0; cnt < removeCount; cnt++)
			{
				var crIndex:int = 0
				while (crIndex < cellRegions.length)
				{
					var cr:CellRect = cellRegions[crIndex];
					if (removeIndex < cr.x)
					{
						cr.x--;
					}
					else if (removeIndex >= cr.x && removeIndex < cr.right)
					{
						_selectionLength = -1;  
						cr.width--;
						if (cr.width == 0)
						{
							cellRegions.splice(crIndex, 1);
							continue;
						}
					}
					crIndex++;
				}
			}        
		}
		/**
		 * 列刷新 
		 * @param event
		 * 
		 */		
		private function columnsCollectionRefresh(event:CollectionEvent):void
		{
			columnsCollectionReset(event);
		}
		/**
		 * 列重置 
		 * @param event
		 * 
		 */		
		private function columnsCollectionReset(event:CollectionEvent):void
		{
			
			if (!isCellSelectionMode())
				return;
			
			removeSelection();
			ensureRequiredSelection();
		}
	}
}

import flash.geom.Rectangle;
internal class CellRect extends Rectangle
{
	public var isAdd:Boolean = false;
	public function CellRect(rowIndex:int, columnIndex:int, 
							 rowCount:uint, columnCount:uint, isAdd:Boolean)
	{
		super(columnIndex, rowIndex, columnCount, rowCount);
		this.isAdd = isAdd;
	}
	
	public function containsCell(cellRowIndex:int, cellColumnIndex:int):Boolean
	{
		return contains(cellColumnIndex, cellRowIndex);
	}
}