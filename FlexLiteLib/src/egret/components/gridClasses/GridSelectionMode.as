package egret.components.gridClasses
{
	/**
	 * 数据表格的选择模式
	 * @author dom
	 * 
	 */	
	public final class GridSelectionMode
	{
		public function GridSelectionMode()
		{
			super();
		}
		/**
		 * 不选择 
		 */		
		public static var NONE:String = "none";
		/**
		 * 选择单行 
		 */		
		public static var SINGLE_ROW:String = "singleRow";
		/**
		 * 选择多行 
		 */		
		public static var MULTIPLE_ROWS:String = "multipleRows";
		/**
		 * 选择单个数据单元 
		 */		
		public static var SINGLE_CELL:String = "singleCell";
		/**
		 * 选择多个数据单元 
		 */		
		public static var MULTIPLE_CELLS:String = "multipleCells";
		
	}
}