package  egret.components.gridClasses
{
	
	import egret.components.Grid;
	import egret.components.Group;
	import egret.core.ns_egret;
	import egret.layouts.supportClasses.LayoutBase;
	
	use namespace ns_egret;
	
	/**
	 * 数据表格的可视化元素的层。 
	 * @author dom
	 * 
	 */	
	public class GridLayer extends Group
	{
		public function GridLayer()
		{
			super();
			layout = new LayoutBase();        
		}
		
		override public function invalidateDisplayList():void
		{
			var grid:Grid = parent as Grid;
			if (grid && grid.inUpdateDisplayList)
				return;
			
			if (grid)
				grid.invalidateDisplayList();
		}
		override public function invalidateSize():void
		{   
			var grid:Grid = parent as Grid;
			if (grid && grid.inUpdateDisplayList)
				return;
			
			if (grid)
				grid.invalidateSize();        
		}
	}
}