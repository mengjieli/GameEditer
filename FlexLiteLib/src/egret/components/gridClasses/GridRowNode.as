package  egret.components.gridClasses
{
	
	[ExcludeClass]
	
	/**
	 * 一个节点代表在指定行中所有数据单元中最高的高度
	 */	
	public final class GridRowNode
	{
		public var rowIndex:int;
		
		private var cellHeights:Vector.<Number>;
		public var maxCellHeight:Number = -1;
		public var fixedHeight:Number = -1;
		
		public var next:GridRowNode;
		public var prev:GridRowNode;
		public function GridRowNode(numColumns:uint, rowIndex:int)
		{
			super();
			
			this.rowIndex = rowIndex;
			_numColumns = numColumns;
			cellHeights = new Vector.<Number>(numColumns);
			GridDimensions.clearVector(cellHeights, -1);
		}
		
		private var _numColumns:uint;
		/**
		 * 行中的列数 
		 * @return 
		 * 
		 */		
		public function get numColumns():uint
		{
			return _numColumns;
		}
		public function set numColumns(value:uint):void
		{
			if (value == _numColumns)
				return;
			
			cellHeights.length = value;
			
			if (value > _numColumns)
			{
				for (var i:int = value - _numColumns; i < value; i++)
					cellHeights[i] = -1;
			}
			else
			{
				updateMaxHeight();
			}
			
			_numColumns = value;
		}
		/**
		 * 更新当前的最大高度 
		 * @return 
		 * 
		 */		
		private function updateMaxHeight():Boolean
		{
			var max:Number = -1;
			for each (var cellHeight:Number in cellHeights)
			{
				if (cellHeight > max)
					max = cellHeight;
			}
			
			var changed:Boolean = maxCellHeight != max;
			if (changed)
				maxCellHeight = max;
			return changed;
		}
		/**
		 * 得到指定单元格的高度 
		 * @param index
		 * @return 
		 * 
		 */		
		public function getCellHeight(index:int):Number
		{
			if (index < 0 || index >= cellHeights.length)
				return NaN;
			return cellHeights[index];
		}
		/**
		 * 设置指定单元格的高度 
		 * @param index
		 * @param value
		 * @return 
		 * 
		 */		
		public function setCellHeight(index:int, value:Number):Boolean
		{
			if (cellHeights[index] == value)
				return false;
			
			cellHeights[index] = value;
			if (value == maxCellHeight)
				return false;
			if (value > maxCellHeight)
			{
				maxCellHeight = value;
				return true;
			}
			return updateMaxHeight();
		}
		/**
		 * 在 startColumn位置插入count这么多列
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function insertColumns(startColumn:int, count:int):void
		{
			GridDimensions.insertValueToVector(cellHeights, startColumn, count, -1);
		}
		/**
		 * 把指定列 从fromCol移动到toCol
		 * @param fromCol
		 * @param toCol
		 * @param count
		 * 
		 */		
		public function moveColumns(fromCol:int, toCol:int, count:int):void
		{
			GridDimensions.insertElementsToVector(cellHeights, toCol, cellHeights.splice(fromCol, count));
		}
		/**
		 * 从startColumn位置开始清空count这么多列
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function clearColumns(startColumn:int, count:int):void
		{
			GridDimensions.clearVector(cellHeights, -1, startColumn, count);
			updateMaxHeight();
		}
		/**
		 * 从 startColumn开始移除count这么多列
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function removeColumns(startColumn:int, count:int):void
		{
			cellHeights.splice(startColumn, count);
			updateMaxHeight();
		}
		public function toString():String
		{
			var s:String = "";
			
			s += "(" + rowIndex + ", " + maxCellHeight + ") ";
			s += cellHeights + "\n";
			if (prev)
				s += prev.rowIndex;
			else
				s += "null";
			
			s += " <- -> ";
			if (next)
				s += next.rowIndex;
			else
				s += "null";
			
			return s;
		}
	}
}