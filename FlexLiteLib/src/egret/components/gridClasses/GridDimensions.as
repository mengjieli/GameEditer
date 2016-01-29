package egret.components.gridClasses
{
	import flash.geom.Rectangle;
	
	import egret.collections.ICollection;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.events.PropertyChangeEvent;
	
	[ExcludeClass]
	
	/**
	 * <p>表示数据表格宽度和高度的数据结构工具</p>
	 * 
	 * <p>找到从特定的数据单元开始的累计y距离，同时得到这个特定的数据单元在已定的y值内的索引。</p>
	 */	
	public class GridDimensions 
	{
		/**
		 * 在索引的开始位置插入一个指定的元素 
		 * @param vec 要被插入的列表
		 * @param startIndex 插入的开始位置
		 * @param elements 要插入的元素列表
		 * 
		 */		
		public static function insertElementsToVector(vec:Vector.<Number>, startIndex:int, elements:Vector.<Number>):void
		{
			var oldLength:int = vec.length;
			var count:int = elements.length;
			vec.length += count;
			var vecLength:int = vec.length;
			var i:int;
			for (i = oldLength - 1; i >= startIndex; i--)
				vec[i + count] = vec[i];
			
			var endIndex:int = startIndex + elements.length;
			var j:int = 0;
			for (i = startIndex; i < endIndex; i++)
				vec[i] = elements[j++];
		}
		
		/**
		 * 在起始位置按照指定的数量插入元素
		 * @param vec 要被插入的列表
		 * @param startIndex 起始位置
		 * @param count 要插入的元素数量
		 * @param value 要插入的元素的值
		 * 
		 */		
		public static function insertValueToVector(vec:Vector.<Number>, startIndex:int, count:int, value:Number):void
		{
			var oldLength:int = vec.length;
			vec.length += count;
			var vecLength:int = vec.length;
			for (var i:int = oldLength - 1; i >= startIndex; i--)
				vec[i + count] = vec[i];
			
			clearVector(vec, value, startIndex, count);
		}
		
		/**
		 * 从开始位置起在列表中插入指定的数量的指定的值
		 * @param vec 要被插入的列表
		 * @param value 指定的值
		 * @param startIndex 起始位置
		 * @param count 要插入的数量 ，-1表示一直插到尾
		 * 
		 */		
		public static function clearVector(vec:Vector.<Number>, value:Number, startIndex:int = 0, count:int = -1):void
		{
			var endIndex:int = (count == -1) ? vec.length : startIndex + count;
			
			for (var i:int = startIndex; i < endIndex; i++)
				vec[i] = value;
		}
		/**
		 * 把一个数值规划到最大值和最小值之间
		 * @param a 要被操作的值
		 * @param min 最小界限
		 * @param max 最大界限
		 * @return 
		 * 
		 */		
		private static function bound(a:Number, min:Number, max:Number):Number
		{
			if (a < min)
				a = min;
			else if (a > max)
				a = max;
			
			return a;
		}
		private var rowList:GridRowList = new GridRowList();
		private var _columnWidths:Vector.<Number> = new Vector.<Number>();
		//缓存累计的y值
		private var startY:Number = 0;
		private var recentNode:GridRowNode = null;
		private var startY2:Number = 0;
		private var recentNode2:GridRowNode = null;
		
		private var typicalCellWidths:Vector.<Number> = new Vector.<Number>();
		private var typicalCellHeights:Vector.<Number> = new Vector.<Number>();
		private var maxTypicalCellHeight:Number = NaN;
		private var useMaxTypicalCellHeight:Boolean = true;
		public function GridDimensions()
		{
			super();
		}
		private var _rowCount:int = 0;
		
		/**
		 * 数据表中的行数。 如果设置的值小于当前值的话，则后面的行将被移除掉
		 * @return 
		 * 
		 */		
		public function get rowCount():int
		{
			return _rowCount;
		}
		public function set rowCount(value:int):void
		{
			if (value == _rowCount)
				return;
			
			//移除掉比设定值大的行
			//同时清空缓存节点
			if (value < _rowCount)
				removeRowsAt(value, value - _rowCount)
			
			_rowCount = value;
		}
		private var _columnCount:int = 0;
		/**
		 * 数据表的列数，设置此值将清空缓存 
		 * @return 
		 * 
		 */		
		public function get columnCount():int
		{
			return _columnCount;
		}
		public function set columnCount(value:int):void
		{
			
			//清空缓存数据
			clearHeights();
			
			//修复列的数量
			_columnCount = value;
			_columnWidths.length = value;
			typicalCellHeights.length = value;
			typicalCellWidths.length = value;
			rowList.numColumns = value;
			//清空剩余列表
			clearTypicalCellWidthsAndHeights();
			clearVector(_columnWidths, NaN, 0, _columnCount);
		}
		private var _rowGap:Number = 0;
		
		/**
		 * 行之间的间隔 
		 * @return 
		 * 
		 */		
		public function get rowGap():Number
		{
			return _rowGap;
		}
		public function set rowGap(value:Number):void
		{
			if (value == _rowGap)
				return;
			
			_rowGap = value;
			recentNode = null;
			recentNode2 = null;
		}
		private var _columnGap:Number = 0;
		/**
		 * 列之间间隔
		 * @return 
		 * 
		 */		
		public function get columnGap():Number
		{
			return _columnGap;
		}
		public function set columnGap(value:Number):void
		{
			if (value == _columnGap)
				return;
			
			_columnGap = value;
			recentNode = null;
			recentNode2 = null;
		}
		private var _defaultRowHeight:Number = NaN;
		
		/**
		 * 行的默认高度
		 * 
		 * <p>如果行高没有被设置，那将会采用数据单元的最小值</p> 
		 * 
		 * <p>当variableRowHeight为false的时候，所有的行都会采用这个值来设置行高。</p> 
		 * 
		 * 默认为NaN
		 * 
		 * @return 
		 * 
		 */		
		public function get defaultRowHeight():Number
		{
			return useMaxTypicalCellHeight ? maxTypicalCellHeight : _defaultRowHeight;
		}
		public function set defaultRowHeight(value:Number):void
		{
			if (value == _defaultRowHeight)
				return;
			
			_defaultRowHeight = bound(value, _minRowHeight, _maxRowHeight);
			useMaxTypicalCellHeight = isNaN(_defaultRowHeight);
			recentNode = null;
			recentNode2 = null;
		}
		
		/**
		 * 默认行宽 ，150
		 */		
		public var defaultColumnWidth:Number = 150;
		/**
		 * 如果这个值为false，获取行高则返回默认行高，即 defaultRowHeight
		 */		
		public var variableRowHeight:Boolean = false; 
	
		private var _minRowHeight:Number = 0;
		/**
		 * 最小行高 
		 * @return 
		 * 
		 */		
		public function get minRowHeight():Number
		{
			return _minRowHeight;
		}
		public function set minRowHeight(value:Number):void
		{
			if (value == _minRowHeight)
				return;
			
			_minRowHeight = value;
			_defaultRowHeight = Math.max(_defaultRowHeight, _minRowHeight);
		}
		
		private var _maxRowHeight:Number = 10000;
		/**
		 * 最大行高 
		 * @return 
		 * 
		 */		
		public function get maxRowHeight():Number
		{
			return _maxRowHeight;
		}
		public function set maxRowHeight(value:Number):void
		{
			if (value == _maxRowHeight)
				return;
			
			_maxRowHeight = value;
			_defaultRowHeight = Math.min(_defaultRowHeight, _maxRowHeight);
		}
		
		/**
		 * 得到指定索引的行高， 如果variableRowHeight为true。
		 * 获取高度的顺序：setRowHeight的赋值 > 所有行内所有数据单元的最大行高>默认行高defaultRowHeight
		 * 如果variableRowHeight为false，那返回的高度为默认行高。返回的行高永远在最大值和最小值之间。
		 * @param row
		 * @return 
		 * 
		 */		
		public function getRowHeight(row:int):Number
		{
			//除非调用了setRowHeight，否则返回的永远是所有行内所有数据单元的最大行高
			var height:Number = defaultRowHeight;
			
			if (variableRowHeight)
			{
				var node:GridRowNode = rowList.find(row);
				if (node)
				{
					if (node.fixedHeight >= 0)
						height = node.fixedHeight;
					else if (node.maxCellHeight >= 0)
						height = node.maxCellHeight;
				}
			}
			
			return (!isNaN(height)) ? bound(height, minRowHeight, maxRowHeight) : height;
		}
		/**
		 * 设置指定行的行高。 设置的行高优先级比计算行高和默认行高都要高。但是一旦
		 * variableRowHeight被设置true，这个方法设置的值将失效。
		 * @param row
		 * @param height
		 * 
		 */		
		public function setRowHeight(row:int, height:Number):void
		{
			if (!variableRowHeight)
				return;
			
			var node:GridRowNode = rowList.find(row);
			
			if (node)
			{
				node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
			}
			else
			{
				node = rowList.insert(row);
				
				if (node)
					node.fixedHeight = bound(height, minRowHeight, maxRowHeight);
			}
		}
		/**
		 * 得到指定列的列宽， 返回的值是setColumnWidth设置的值，如果没有设置值，
		 * 将返回典型宽度。如果典型宽度没有设置值，将返回默认宽度。
		 * @param col
		 * @return 
		 * 
		 */		
		public function getColumnWidth(col:int):Number
		{    
			var w:Number = NaN;
			
			w = _columnWidths[col];
			
			if (isNaN(w))
				w = typicalCellWidths[col];
			
			if (isNaN(w))
				w = this.defaultColumnWidth;
			
			return w;
		}
		/**
		 * 设置指定列的宽度 
		 * @param col
		 * @param width
		 * 
		 */		
		public function setColumnWidth(col:int, width:Number):void
		{
			_columnWidths[col] = width;
		}
		/**
		 * 得到指定数据单元的高度。 返回值为通过setCellHeight设置的高度。
		 * 如果没有设置高度，将返回NaN.
		 * @param row
		 * @param col
		 * @return 
		 * 
		 */		
		public function getCellHeight(row:int, col:int):Number
		{
			var node:GridRowNode = rowList.find(row);
			
			if (node)
				return node.getCellHeight(col);
			
			return NaN;
		}
		/**
		 * 设置指定数据单元的高度 
		 * @param row
		 * @param col
		 * @param height
		 * 
		 */		
		public function setCellHeight(row:int, col:int, height:Number):void
		{
			if (!variableRowHeight)
				return;
			
			var node:GridRowNode = rowList.find(row);
			var oldHeight:Number = defaultRowHeight;
			
			if (node == null)
				node = rowList.insert(row);
			else
				oldHeight = node.maxCellHeight;
			
			if (node && node.setCellHeight(col, height))
			{
				if (recentNode && node.rowIndex < recentNode.rowIndex)
					startY += node.maxCellHeight - oldHeight;
				
				if (recentNode2 && node.rowIndex < recentNode2.rowIndex)
					startY2 += node.maxCellHeight - oldHeight;
			}
		}
		/**
		 * 返回 指定数据单元的布局尺寸。这个显示尺寸中的宽度和高度，就是所在的行高和列宽。
		 * @param row
		 * @param col
		 * @return 
		 * 
		 */		
		public function getCellBounds(row:int, col:int):Rectangle
		{
			
			if (row < 0 || row >= rowCount || col < 0 || col >= columnCount)
				return null;
			
			var x:Number = getCellX(row, col);
			var y:Number = getCellY(row, col);
			
			var width:Number = getColumnWidth(col);
			var height:Number = getRowHeight(row);
			
			return new Rectangle(x, y, width, height);
		}
		/**
		 * 返回指定数据单元的x坐标 
		 * @param row
		 * @param col
		 * @return 
		 * 
		 */		
		public function getCellX(row:int, col:int):Number
		{   
			var x:Number = 0;
			
			for (var i:int = 0; i < col; i++)
			{
				x += getColumnWidth(i) + columnGap;
			}
			
			return x;
		}
		/**
		 * 返回指定数据单元的y坐标 
		 * @param row
		 * @param col
		 * @return 
		 * 
		 */		
		public function getCellY(row:int, col:int):Number
		{ 
			
			if (!variableRowHeight || rowList.length == 0)
				return row * (defaultRowHeight + rowGap);
			
			if (row == 0)
				return 0;
			if (!recentNode2)
			{
				recentNode2 = rowList.first;
				startY2 = recentNode2.rowIndex * (defaultRowHeight + rowGap);
			}
			
			var y:Number;
			var recentIndex:int = recentNode2.rowIndex;
			
			if (row == recentIndex)
				y = startY2;
			else if (row < recentIndex)
				y = getPrevYAt(row, recentNode2, startY2);
			else
				y = getNextYAt(row, recentNode2, startY2);
			
			return y;
		}
		/**
		 * 返回指定行的起始Y坐标。指定行必须在起始节点startNode之前
		 * @param row 目标行
		 * @param startNode 查找到的节点
		 * @param startY 从第一行到起始节点的累计的y坐标
		 * @return 
		 * 
		 */		
		private function getPrevYAt(row:int, startNode:GridRowNode, startY:Number):Number
		{
			var node:GridRowNode = startNode;
			var nodeY:Number = startY;
			var prevNode:GridRowNode;
			var currentY:Number = startY;
			var indDiff:int;
			
			while (node)
			{
				if (node.rowIndex == row)
					break;
				
				prevNode = node.prev;
				
				if (!prevNode || (row < node.rowIndex && row > prevNode.rowIndex))
				{
					indDiff = node.rowIndex - row;
					currentY -= indDiff * (defaultRowHeight + rowGap);
					break;
				}
				indDiff = node.rowIndex - prevNode.rowIndex - 1;
				currentY = currentY - indDiff * (defaultRowHeight + rowGap) - (prevNode.maxCellHeight + rowGap);
				nodeY = currentY;
				node = prevNode;
			}
			
			this.recentNode2 = node;
			this.startY2 = nodeY;
			
			return currentY;
		}
		/**
		 * 返回指定行的起始y坐标， 且指定行必须在起始节点startNode之后。
		 * @param row 目标行
		 * @param startNode 查找到的节点
		 * @param startY 从第一样开始到起始节点的累计y坐标
		 * @return 
		 * 
		 */		
		private function getNextYAt(row:int, startNode:GridRowNode, startY:Number):Number
		{
			var node:GridRowNode = startNode;
			var nodeY:Number = startY;
			var nextNode:GridRowNode;
			var currentY:Number = startY;
			var indDiff:int;
			
			while (node)
			{
				if (node.rowIndex == row)
					break;
				
				currentY += node.maxCellHeight;
				if (node.rowIndex < _rowCount - 1)
					currentY += rowGap;
				
				nextNode = node.next;
				
				if (!nextNode || (row > node.rowIndex && row < nextNode.rowIndex))
				{
					indDiff = row - node.rowIndex - 1;
					currentY += indDiff * (defaultRowHeight + rowGap);
					break;
				}
				indDiff = nextNode.rowIndex - node.rowIndex - 1;
				currentY = currentY + indDiff * (defaultRowHeight + rowGap);
				nodeY = currentY; 
				node = nextNode;
			}
			
			this.recentNode2 = node;
			this.startY2 = nodeY;
			
			return currentY;
		}
		
		/**
		 * 返回指定行的显示尺寸 
		 * @param row
		 * @return 
		 * 
		 */		
		public function getRowBounds(row:int):Rectangle
		{
			
			if ((row < 0) || (row >= _rowCount))
				return null;
			
			if (_columnCount == 0 || _rowCount == 0)
				return new Rectangle(0, 0, 0, 0);
			
			var x:Number = getCellX(row, 0);
			var y:Number = getCellY(row, 0);
			var rowWidth:Number = getCellX(row, _columnCount - 1) + getColumnWidth(_columnCount - 1) - x;
			var rowHeight:Number = getRowHeight(row);
			return new Rectangle(x, y, rowWidth, rowHeight);
		}
		/**
		 * 返回指定行被用于填补表格所有可见行最下端未使用空间的尺寸。
		 * 填补的行有用如下特性：index >= rowCount, height = defaultRowHeight.
		 * @param row
		 * @return 
		 * 
		 */		
		public function getPadRowBounds(row:int):Rectangle
		{
			if (row < 0)
				return null;
			
			if (row < rowCount)
				return getRowBounds(row);
			
			var lastRow:int = rowCount - 1;
			var lastCol:int = columnCount - 1;
			
			var x:Number = (lastRow >= 0) ? getCellX(lastRow, 0) : 0;
			var lastRowBottom:Number = (lastRow >= 0) ? getCellY(lastRow, 0) + getRowHeight(lastRow) : 0;
			var padRowCount:int = row - rowCount;
			var padRowTotalGap:Number = (padRowCount > 0) ? (padRowCount - 1) * rowGap : 0;
			var y:Number = lastRowBottom + (padRowCount * defaultRowHeight) + padRowTotalGap;
			
			var rowWidth:Number = 0;
			if ((lastCol >= 0) && (lastRow >= 0))
				rowWidth = getCellX(lastRow, lastCol) + getColumnWidth(lastCol) - x;
			else if (lastCol >= 0)
				rowWidth = getCellX(0, lastCol) + getColumnWidth(lastCol) - x;
			else if (lastRow >= 0)
				rowWidth = getCellX(lastRow, 0) + getColumnWidth(0) - x;
			
			return new Rectangle(x, y, rowWidth, defaultRowHeight);
			
		}
		/**
		 * 得到指定列的尺寸
		 * @param col
		 * @return 
		 * 
		 */		
		public function getColumnBounds(col:int):Rectangle
		{
			
			if ((col < 0) || (col >= _columnCount))
				return null;
			
			if (_columnCount == 0 || _rowCount == 0)
				return new Rectangle(0, 0, 0, 0);
			
			var x:Number = getCellX(0, col);
			var y:Number = getCellY(0, col);
			var colWidth:Number = getColumnWidth(col);
			var colHeight:Number = getCellY(_rowCount - 1, col) + getRowHeight(_rowCount - 1) - y;
			return new Rectangle(x, y, colWidth, colHeight);
		}
		
		/**
		 * 得到指定坐标的行的索引。
		 * @param x
		 * @param y
		 * @return 如果设置的坐标在列表区域以外，则返回-1
		 * 
		 */		
		public function getRowIndexAt(x:Number, y:Number):int
		{
			if (y < 0)
				return -1;
			
			var index:int;
			
			if (!variableRowHeight || rowList.length == 0)
			{
				index = y / (defaultRowHeight + rowGap);
				return index < _rowCount ? index : -1;
			}
			
			if (y == 0)
				return _rowCount > 0 ? 0 : -1;
			if (!recentNode)
			{
				recentNode = rowList.first;
				startY = recentNode.rowIndex * (defaultRowHeight + rowGap);
			}
			if (isYInRow(y, startY, recentNode))
				index = recentNode.rowIndex;
			else if (y < startY)
				index = getPrevRowIndexAt(y, recentNode, startY);
			else
				index = getNextRowIndexAt(y, recentNode, startY);
			
			return index < _rowCount ? index : -1;
		}
		/**
		 * 指定y坐标是否在行的区域内。
		 * @param y
		 * @param startY
		 * @param node
		 * @return 
		 * 
		 */		
		private function isYInRow(y:Number, startY:Number, node:GridRowNode):Boolean
		{
			var end:Number = startY + node.maxCellHeight;
			if (node.rowIndex != rowCount - 1)
				end += rowGap;
			if (y >= startY && y < end)
				return true;
			
			return false;
		}
		/**
		 * 返回 包含指定y坐标值的行索引。这个行应该在起始节点之前。
		 * @param y 目标y坐标
		 * @param startNode 搜索的起始节点
		 * @param startY 从第一行到起始节点之间的累计y坐标
		 * @return 
		 * 
		 */		
		private function getPrevRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
		{
			var node:GridRowNode = startNode;
			var prevNode:GridRowNode = null;
			var index:int = node.rowIndex;
			var currentY:Number = startY;
			var prevY:Number;
			var targetY:Number = y;
			
			while (node)
			{
				
				if (isYInRow(targetY, currentY, node))
					break;
				prevNode = node.prev;
				
				if (!prevNode)
				{
					prevY = 0;
				}
				else
				{
					prevY = currentY;
					
					var indDiff:int = node.rowIndex - prevNode.rowIndex;
					if (indDiff > 1)
						prevY -= (indDiff - 1) * (defaultRowHeight + rowGap);
				}
				if (targetY < currentY && targetY >= prevY)
				{
					index = index - Math.ceil(Number(currentY - targetY)/(defaultRowHeight + rowGap));
					break;
				}
				currentY = prevY - prevNode.maxCellHeight - rowGap;
				node = node.prev;
				index = node.rowIndex;
			}
			
			this.recentNode = node;
			this.startY = currentY;
			
			return index;
		}
		
		/**
		 * 返回 包含指定y坐标的行的索引。这个行应该在起始节点之后
		 * @param y 目标y坐标
		 * @param startNode 检索的起始节点
		 * @param startY 从第一样到起始节点之间的累计y坐标
		 * @return 
		 * 
		 */		
		private function getNextRowIndexAt(y:Number, startNode:GridRowNode, startY:Number):int
		{
			var node:GridRowNode = startNode;
			var nextNode:GridRowNode = null;
			var index:int = node.rowIndex;
			var nodeY:Number = startY;
			var currentY:Number = startY;
			var nextY:Number;
			var targetY:Number = y;
			
			while (node)
			{
				
				if (isYInRow(targetY, nodeY, node))
					break;
				currentY += node.maxCellHeight;
				if (node.rowIndex != rowCount - 1)
					currentY += rowGap;
				nextNode = node.next;
				nextY = currentY;
				
				var indDiff:int;
				
				if (!nextNode)
				{
					indDiff = rowCount - 1 - node.rowIndex;
					
					nextY += indDiff * (defaultRowHeight + rowGap) - rowGap + 1;
				}
				else
				{
					indDiff = nextNode.rowIndex - node.rowIndex;
					nextY += (indDiff - 1) * (defaultRowHeight + rowGap);
				}
				if (targetY >= currentY && targetY < nextY)
				{
					index = index + Math.ceil(Number(targetY - currentY)/(defaultRowHeight + rowGap));
					break;
				}
				if (!nextNode)
				{
					index = -1;
					break;
				}
				nodeY = currentY = nextY;
				
				node = node.next;
				index = node.rowIndex;
			}
			
			this.recentNode = node;
			this.startY = nodeY;
			
			return index;
		}
		
		/**
		 * 返回指定坐标的列索引。返回-1代表指定坐标在列表区域之外。
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		public function getColumnIndexAt(x:Number, y:Number):int
		{
			var cur:Number = x;
			var i:int;
			
			for (i = 0; i < _columnCount; i++)
			{
				var temp:Number = _columnWidths[i];
				if (isNaN(temp))
				{
					temp = typicalCellWidths[i];
					if (temp == 0) 
						continue;
				}
				if (isNaN(temp))
					temp = defaultColumnWidth;
				
				cur -= temp + columnGap;
				
				if (cur <= 0)
					return i;
			}
			
			return -1;
		}
		
		/**
		 * 返回内容的总布局宽度(包含间隙),如果columnCountOverride被赋值，则将返回列的整体宽度。
		 * @param columnCountOverride
		 * @return 
		 * 
		 */		
		public function getContentWidth(columnCountOverride:int = -1):Number
		{
			var nCols:int = (columnCountOverride == -1) ? _columnCount : columnCountOverride;
			var contentWidth:Number = 0;
			var width:Number;
			var measuredColCount:int = 0;
			
			for (var i:int = 0; (i < _columnCount) && (measuredColCount < nCols); i++)
			{
				if (i >= _columnWidths.length)
				{
					contentWidth += defaultColumnWidth;
					measuredColCount++;
					continue;
				}
				
				width = _columnWidths[i];
				if (isNaN(width))
				{
					width = typicalCellWidths[i];
					
					if (width == 0)
						continue;
				}
				if (isNaN(width))
					width = defaultColumnWidth;
				
				contentWidth += width;
				measuredColCount++;
			}
			
			if (nCols > 1)
				contentWidth += (nCols - 1) * columnGap;
			
			return contentWidth;
		}
		
		/**
		 * 返回内容的总布局高度(包含间隙),如果rowHeightOverride被赋值，则将返回列的整体宽度。 
		 * @param rowCountOverride
		 * @return 
		 * 
		 */		
		public function getContentHeight(rowCountOverride:int = -1):Number
		{
			var nRows:int = (rowCountOverride == -1) ? rowCount : rowCountOverride;
			var contentHeight:Number = 0;
			
			if (nRows > 1)
				contentHeight += (nRows - 1) * rowGap;
			
			if (!variableRowHeight || rowList.length == 0)
				return contentHeight + nRows * defaultRowHeight;
			
			var node:GridRowNode = rowList.first;
			var numRows:int = 0;
			
			while (node && node.rowIndex < nRows)
			{
				contentHeight += node.maxCellHeight;
				numRows++;
				node = node.next;
			}
			
			contentHeight += (nRows - numRows) * defaultRowHeight;
			
			return contentHeight;
		}
		
		/**
		 * 返回数据单元的典型宽度之和(包含间隙)，如果columnCountOverride被复制，那将返回列的整体typicalCellWidth。
		 * @param columnCountOverride
		 * @return 
		 * 
		 */		
		public function getTypicalContentWidth(columnCountOverride:int = -1):Number
		{
			var nCols:int = (columnCountOverride == -1) ? _columnCount : columnCountOverride;
			var contentWidth:Number = 0;
			var measuredColCount:int = 0;
			
			for (var columnIndex:int = 0; (columnIndex < _columnCount) && (measuredColCount < nCols); columnIndex++)
			{
				
				var width:Number = columnIndex < _columnCount ? typicalCellWidths[columnIndex] : NaN;
				if (width == 0)
					continue;
				
				if (isNaN(width))
					width = defaultColumnWidth;
				
				contentWidth += width;
				measuredColCount++;
			}
			
			if (nCols > 1)
				contentWidth += (measuredColCount - 1) * columnGap;
			
			return contentWidth;
		}
		
		/**
		 * 返回在最大数据单元高度之内的最大行高(包含间隙)
		 * @param rowCountOverride
		 * @return 
		 * 
		 */		
		public function getTypicalContentHeight(rowCountOverride:int = -1):Number
		{
			var nRows:int = (rowCountOverride == -1) ? rowCount : rowCountOverride;
			var contentHeight:Number = 0;
			
			if (nRows > 1)
				contentHeight += (nRows - 1) * rowGap;
			
			if (!isNaN(defaultRowHeight))
				return contentHeight + nRows * defaultRowHeight;
			
			return 0;
		}
		/**
		 * 返回数据表格中被渲染数据单元的优先级最高的宽度。
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function getTypicalCellWidth(columnIndex:int):Number
		{
			return typicalCellWidths[columnIndex];
		}
		/**
		 * 设置数据表格指定列的最优宽度
		 * @param columnIndex
		 * @param value
		 * 
		 */		
		public function setTypicalCellWidth(columnIndex:int, value:Number):void
		{
			typicalCellWidths[columnIndex] = value;
		}
		/**
		 * 返回数据表格中被渲染数据单元的优先级最高的高度。
		 * @param columnIndex
		 * @return 
		 * 
		 */		
		public function getTypicalCellHeight(columnIndex:int):Number
		{
			return typicalCellHeights[columnIndex];
		}
		/**
		 * 设置数据表格指定列的最优高度
		 * @param columnIndex
		 * @param value
		 * 
		 */		
		public function setTypicalCellHeight(columnIndex:int, value:Number):void
		{
			typicalCellHeights[columnIndex] = value;
			
			var max:Number = 0;
			var typicalCellHeightsLength:int = typicalCellHeights.length;
			for (var i:int = 0; i < typicalCellHeightsLength; i++)
			{
				if (!isNaN(typicalCellHeights[i])) 
					max = Math.max(max, typicalCellHeights[i]);
			}
			this.maxTypicalCellHeight = max;
		}
		
		/**
		 * 清空所有行和列的典型数据单元 
		 * 
		 */		
		public function clearTypicalCellWidthsAndHeights():void
		{
			clearVector(typicalCellWidths, NaN);
			clearVector(typicalCellHeights, NaN);
			maxTypicalCellHeight = NaN;
		}
		/**
		 * 从起始行开始插入指定数量的行。这将使之后的行都往下移。
		 * @param startRow
		 * @param count
		 * 
		 */		
		public function insertRows(startRow:int, count:int):void
		{
			insertRowsAt(startRow, count);
		}
		/**
		 * 从起始列开始插入指定数量的列。这将使之后的列都往右移。
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function insertColumns(startColumn:int, count:int):void
		{
			var oldColumnCount:int = _columnCount;
			var newColumnCount:int = _columnCount + count;
			
			if (startColumn < 0 || startColumn > oldColumnCount)
				return;
			rowList.insertColumns(startColumn, count);
			_columnCount = newColumnCount;
			insertValueToVector(_columnWidths, startColumn, count, NaN);
			insertValueToVector(typicalCellWidths, startColumn, count, NaN);
			insertValueToVector(typicalCellHeights, startColumn, count, NaN);
		}
		/**
		 * 从起始行开始移除掉指定数量的行。 
		 * @param startRow
		 * @param count
		 * 
		 */		
		public function removeRows(startRow:int, count:int):void
		{
			removeRowsAt(startRow, count);
		}
		/**
		 * 从起始列开始移除掉指定数量的列。 
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function removeColumns(startColumn:int, count:int):void
		{
			var oldColumnCount:int = _columnCount;
			var newColumnCount:int = _columnCount - count;
			
			if (startColumn < 0 || startColumn >= oldColumnCount)
				return;
			if (newColumnCount <= 0)
			{
				columnCount = 0;
				return;
			}
			rowList.removeColumns(startColumn, count)
			_columnCount = newColumnCount;
			_columnWidths.splice(startColumn, count);
			typicalCellWidths.splice(startColumn, count);
			typicalCellHeights.splice(startColumn, count);
			recentNode = null;
			recentNode2 = null;
		}
		/**
		 * 从指定行开始移除掉指定书目的所有节点
		 * @param startRow
		 * @param count
		 * 
		 */		
		public function clearRows(startRow:int, count:int):void
		{
			if (startRow < 0 || count <= 0)
				return;
			
			var node:GridRowNode = rowList.findNearestLTE(startRow);
			var endRow:int = startRow + count;
			var oldNode:GridRowNode;
			
			if (node && node.rowIndex < startRow)
				node = node.next;
			
			while (node && node.rowIndex < endRow)
			{
				oldNode = node;
				node = node.next;
				rowList.removeNode(oldNode);
			}
			recentNode = null;
			recentNode2 = null;
		}
		/**
		 * 从起始列开始，移除掉指定数量的列。 
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function clearColumns(startColumn:int, count:int):void
		{
			if (startColumn < 0 || startColumn >= _columnCount)
				return;
			
			rowList.clearColumns(startColumn, count);
			
			clearVector(typicalCellWidths, NaN, startColumn, count);
			clearVector(typicalCellHeights, NaN, startColumn, count);
			clearVector(_columnWidths, NaN, startColumn, count);
			recentNode = null;
			recentNode2 = null;   
		}
		
		/**
		 * 从fromRow移动指定数量的行到toRow，这个操作不会影响行数。
		 * @param fromRow
		 * @param toRow
		 * @param count
		 * 
		 */		
		public function moveRows(fromRow:int, toRow:int, count:int):void
		{
			var rows:Vector.<GridRowNode> = removeRowsAt(fromRow, count);
			var diff:int = toRow - fromRow;
			for each (var node:GridRowNode in rows)
			{
				node.rowIndex = node.rowIndex + diff;
			}
			
			insertRowsAt(toRow, count, rows);
		}
		
		/**
		 * 从fromCol移动指定数量的列到toCol，这个操作不会影响到列数。
		 * @param fromCol
		 * @param toCol
		 * @param count
		 * 
		 */		
		public function moveColumns(fromCol:int, toCol:int, count:int):void
		{
			if (fromCol < 0 || fromCol >= _columnCount || toCol < 0 || toCol > _columnCount)
				return;
			
			rowList.moveColumns(fromCol, toCol, count);
			
			insertElementsToVector(_columnWidths, toCol, _columnWidths.splice(fromCol, count));
			insertElementsToVector(typicalCellWidths, toCol, typicalCellWidths.splice(fromCol, count));
			insertElementsToVector(typicalCellHeights, toCol, typicalCellHeights.splice(fromCol, count));
		}
		
		/**
		 * 清空所有缓存高度 
		 * 
		 */		
		public function clearHeights():void
		{
			rowList.removeAll();
			recentNode = null;
			recentNode2 = null;
			startY = 0;
			startY2 = 0;
		}
		
		/**
		 * 从startRow开始插入指定数量的行。
		 * @param startRow
		 * @param count
		 * @param nodes
		 * 
		 */		
		private function insertRowsAt(startRow:int, count:int, nodes:Vector.<GridRowNode> = null):void
		{
			if (startRow < 0 || count <= 0)
				return;
			
			var startNode:GridRowNode = rowList.findNearestLTE(startRow);
			var node:GridRowNode;
			
			if (startNode && startNode.rowIndex < startRow)
				startNode = startNode.next;
			if (nodes)
			{
				if (startNode)
				{
					for each (node in nodes)
					rowList.insertBefore(startNode, node);
				}
				else
				{
					for each (node in nodes)
					rowList.push(node);
				}
			}
			node = startNode;
			while (node)
			{
				node.rowIndex += count;
				node = node.next;
			}
			
			this.rowCount += count;
			recentNode = null;
			recentNode2 = null;
		}
		
		/**
		 * 从 startRow开始移除掉指定数量的行
		 * @param startRow
		 * @param count
		 * @return 
		 * 
		 */		
		private function removeRowsAt(startRow:int, count:int):Vector.<GridRowNode>
		{
			var vec:Vector.<GridRowNode> = new Vector.<GridRowNode>();
			if (startRow < 0 || count <= 0)
				return vec;
			
			var node:GridRowNode = rowList.findNearestLTE(startRow);
			var endRow:int = startRow + count;
			var oldNode:GridRowNode;
			
			if (node && node.rowIndex < startRow)
				node = node.next;
			
			while (node && node.rowIndex < endRow)
			{
				oldNode = node;
				vec.push(oldNode);
				node = node.next;
				rowList.removeNode(oldNode);
			}
			
			while (node)
			{
				node.rowIndex -= count;
				node = node.next;
			}
			
			_rowCount -= count;
			recentNode = null;
			recentNode2 = null;
			return vec;
		}
		
		/**
		 * dataProvider的变化的事件监听器
		 * @param event
		 * 
		 */		
		public function dataProviderCollectionChanged(event:CollectionEvent):void 
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					insertRows(event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					removeRows(event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					moveRows(event.oldLocation, event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.REFRESH:
				{
					clearHeights();
					break;
				}
					
				case CollectionEventKind.RESET:
				{
					clearHeights();
					clearTypicalCellWidthsAndHeights();
					break;
				}
					
				case CollectionEventKind.UPDATE:
				{
					
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					clearRows(event.location, event.items.length);
					break;
				}   
			}
		}
		
		/**
		 * 列变化的监听器
		 * @param event
		 * 
		 */		
		public function columnsCollectionChanged(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case CollectionEventKind.ADD: 
				{
					insertColumns(event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					removeColumns(event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					moveColumns(event.oldLocation, event.location, event.items.length);
					break;
				}
					
				case CollectionEventKind.REFRESH:
				case CollectionEventKind.RESET:
				{
					columnCount = ICollection(event.target).length;
					break;
				}
					
				case CollectionEventKind.UPDATE:
				{
					
					var pcEvent:PropertyChangeEvent;
					
					var itemsLength:int = event.items ? event.items.length : 0;                
					for (var i:int = 0; i < itemsLength; i++)
					{
						pcEvent = event.items[i] as PropertyChangeEvent;
						if (pcEvent && pcEvent.property == "visible")
							columns_visibleChangedHandler(pcEvent);
					}
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					clearColumns(event.location, event.items.length);
					break;
				}
			}
		}
		
		/**
		 * 当一个列的visibility属性变化时，CollectionEventKind.UPDATE事件的侦听器。
		 * @param pcEvent
		 * 
		 */		
		private function columns_visibleChangedHandler(pcEvent:PropertyChangeEvent):void
		{
			var column:GridColumn = pcEvent.source as GridColumn;
			var columnIndex:int = column.columnIndex;
			if (!column || columnIndex < 0 || columnIndex >= _columnCount)
				return;
			
			clearColumns(columnIndex, 1);
			if (column.visible)
			{
				setTypicalCellWidth(columnIndex, NaN);
				setTypicalCellHeight(columnIndex, NaN);
				if (!isNaN(column.width))
					setColumnWidth(columnIndex, column.width);
			}
			else
			{
				setTypicalCellWidth(columnIndex, 0);
				setTypicalCellHeight(columnIndex, 0);
				setColumnWidth(columnIndex, NaN);
			}
		}
		public function toString():String
		{
			return rowList.toString();
		}
	}
}