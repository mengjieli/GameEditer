package egret.components.gridClasses
{
	/**
	 * 一个数据结构，存储单元格位置
	 * @author dom
	 */	
	public class CellPosition
	{    
		/**
		 * 构造函数
		 * @param rowIndex 行索引
		 * @param columnIndex 列索引
		 */		
		public function CellPosition(rowIndex:int = -1, columnIndex:int = -1)
		{
			super();
			
			_rowIndex = rowIndex;
			_columnIndex = columnIndex;
		}
		
		private var _columnIndex:int;
		/**
		 * 列索引。索引从0开始，-1表示未设置
		 */		
		public function get columnIndex():int
		{
			return _columnIndex;
		}
		public function set columnIndex(value:int):void
		{
			_columnIndex = value;
		}
		
		private var _rowIndex:int;
		/**
		 * 行索引。索引从0开始，-1表示未设置。
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