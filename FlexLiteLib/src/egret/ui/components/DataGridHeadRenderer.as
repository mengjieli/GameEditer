package egret.ui.components
{
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import egret.components.DataGrid;
	import egret.components.GridColumnHeaderGroup;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.components.gridClasses.GridColumn;
	import egret.components.gridClasses.GridItemRenderer;
	import egret.ui.skins.DataGridHeadRendererSkin;
	
	/**
	 * 数据表格的表头渲染器
	 * @author 雷羽佳
	 */
	public class DataGridHeadRenderer extends GridItemRenderer
	{
		private static const DEFAULT_COLOR_VALUE:uint = 0xCC;
		private static const DEFAULT_COLOR:uint = 0xCCCCCC;
		private static const DEFAULT_SYMBOL_COLOR:uint = 0x000000;
		
		private static var colorTransform:ColorTransform = new ColorTransform();
		
		public function DataGridHeadRenderer()
		{
			super();
			this.skinName = DataGridHeadRendererSkin;
		}
		
		//[SkinPart]
		public var labelDisplayGroup:Group;
		//[SkinPart]
		public var sortIndicatorGroup:Group;
		//[SkinPart]
		public var sortDown:UIAsset;
		//[SkinPart]
		public var sortUp:UIAsset;
		
		
		private function dispatchChangeEvent(type:String):void
		{
			if (hasEventListener(type))
				dispatchEvent(new Event(type));
		}
		
		private var _maxDisplayedLines:int = 1;
		
		public function get maxDisplayedLines():int
		{
			return _maxDisplayedLines;
		}
		
		public function set maxDisplayedLines(value:int):void
		{
			if (value == _maxDisplayedLines)
				return;
			
			_maxDisplayedLines = value;
			if (Label(labelDisplay))
				Label(labelDisplay).maxDisplayedLines = value;
			
			invalidateSize();
			invalidateDisplayList();
			
			dispatchChangeEvent("maxDisplayedLinesChanged");
		}
		
		override public function prepare(hasBeenRecycled:Boolean):void
		{
			super.prepare(hasBeenRecycled);
			
			if (labelDisplay && labelDisplayGroup && (labelDisplay.parent != labelDisplayGroup))
			{
				labelDisplayGroup.removeAllElements();
				labelDisplayGroup.addElement(labelDisplay);
			}
			
			const column:GridColumn = this.column;
			if (column && column.grid && column.grid.dataGrid && column.grid.dataGrid.columnHeaderGroup)
			{
				const dataGrid:DataGrid = column.grid.dataGrid;
				const columnHeaderGroup:GridColumnHeaderGroup = dataGrid.columnHeaderGroup;
				
				if (columnHeaderGroup.isSortIndicatorVisible(column.columnIndex))
				{
					sortIndicatorGroup.includeInLayout = true;
					if(column.sortDescending)
					{
						sortDown.visible = sortDown.includeInLayout = true;
						sortUp.visible = sortUp.includeInLayout = false;
					}
					else
					{
						sortDown.visible = sortDown.includeInLayout = false;
						sortUp.visible = sortUp.includeInLayout = true;
					}
				}
				else
				{
					sortIndicatorGroup.includeInLayout = false;
					sortDown.visible = sortDown.includeInLayout = false;
					sortUp.visible = sortUp.includeInLayout = false;
				}
			}
		}
	}
}