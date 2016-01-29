package egret.components.gridClasses
{
	/**
	 * 一个数据结果，存储单元格区域范围。
	 * @author dom
	 */	
	public class CellRegion
	{        
		/**
		 * 构造函数
		 * @param rowIndex 起始的行索引
		 * @param columnIndex 起始的列索引
		 * @param rowCount 行数量
		 * @param columnCount列数量
		 */		
		public function CellRegion(rowIndex:int = -1, columnIndex:int = -1,
								   rowCount:int = 0, columnCount:int = 0)
		{
			super();
			
			_rowIndex = rowIndex;
			_columnIndex = columnIndex;
			
			_rowCount = rowCount;
			_columnCount = columnCount;
		}
		
		private var _columnCount:int;
		/**
		 * 列数量
		 */		
		public function get columnCount():int
		{
			return _columnCount;
		}
		public function set columnCount(value:int):void
		{
			_columnCount = value;
		}
		
		private var _columnIndex:int;
		/**
		 * 起始列索引
		 */		
		public function get columnIndex():int
		{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void
		{
			_columnIndex = value;
		}
		
		private var _rowCount:int;
		/**
		 * 行数量
		 */		
		public function get rowCount():int
		{
			return _rowCount;
		}
		public function set rowCount(value:int):void
		{
			_rowCount = value;
		}
		
		private var _rowIndex:int;
		/**
		 * 起始行索引
		 */		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		public function set rowIndex(value:int):void
		{
			_rowIndex = value;
		}  
	}
}