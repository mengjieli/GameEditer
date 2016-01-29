package egret.components.gridClasses
{
	import egret.components.DataGrid;
	import egret.core.IInvalidating;
	import egret.core.IVisualElement;
	import egret.managers.ILayoutManagerClient;

	
	/**
	 * DataGrid控件的可视元素的接口。
	 * @author dom
	 * 
	 */	
	public interface IDataGridElement extends IVisualElement, ILayoutManagerClient, IInvalidating
	{
		/**
		 * 与此元素相关联的 DataGrid 控件。 
		 */		
		function get dataGrid():DataGrid;
		function set dataGrid(value:DataGrid):void;        
	}
}