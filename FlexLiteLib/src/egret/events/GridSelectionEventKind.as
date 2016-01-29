package egret.events
{
	/**
	 * GridSelectionEventKind 类定义代表 spark.events.GridSelectionEvent 
	 * 类 kind 属性的有效值的常量。这些常量指示对选定内容进行的更改类型。
	 * @author dom
	 * 
	 */	
	public final class GridSelectionEventKind
	{
		/**
		 * 指示应选择整个网格。 
		 */		
		public static const SELECT_ALL:String = "selectAll";
		/**
		 * 指示应清除当前选定内容。
		 */		
		public static const CLEAR_SELECTION:String = "clearSelection";
		/**
		 * 指示应将当前选定内容设置为此行。
		 */		
		public static const SET_ROW:String = "setRow";
		/**
		 * 指示应将此行添加到当前选定内容。
		 */		
		public static const ADD_ROW:String = "addRow";
		/**
		 * 指示应将此行从当前选定内容中删除。
		 */		
		public static const REMOVE_ROW:String = "removeRow";
		/**
		 * 指示应将当前选定内容设置为这些行。
		 */		
		public static const SET_ROWS:String = "setRows";
		/**
		 * 指示应将当前选定内容设置为此单元格。
		 */		
		public static const SET_CELL:String = "setCell";
		/**
		 * 指示应将此单元格添加到当前选定内容。
		 */		
		public static const ADD_CELL:String = "addCell";
		/**
		 * 指示应将此单元格从当前选定内容中删除。 
		 */		
		public static const REMOVE_CELL:String = "removeCell";
		/**
		 * 指示应将当前选定内容设置为此单元格区域。 
		 */		
		public static const SET_CELL_REGION:String = "setCellRegion";
	}
	
}
