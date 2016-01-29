package egret.components.gridClasses
{
	
	import egret.components.Grid;
	/**
	 * 动态创建的可视元素可使用此接口提供的方法，在显示这些元素之前进行自我配置。 
	 * @author dom
	 * 
	 */
	public interface IGridVisualElement
	{
		/**
		 * <p>在呈示 Grid 可视元素之前调用此方法，使元素可以对自身进行配置。此方法的参数指定可视元素将占用的单元格、
		 * 行（如果 columnIndex=-1）或列（如果 rowIndex=-1）。 </p>
		 * <p>如果可视元素是由使用工厂值的 DataGrid 外观部件生成的，如 selectionIndicator 或 hoverIndicator，
		 * 则 grid.dataGrid 是其外观部件为网格的 DataGrid。</p>
		 * @param grid 与此可视元素关联的 Grid。
		 * @param rowIndex 可视元素要占用的单元格行坐标，或者为 -1。
		 * @param columnIndex 可视元素要占用的单元格列坐标，或者为 -1。
		 * 
		 */		
		function prepareGridVisualElement(grid:Grid, rowIndex:int, columnIndex:int):void; 
	}
}