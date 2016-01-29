package egret.ui.skins
{
	import egret.components.DataGrid;
	import egret.components.Grid;
	import egret.components.GridColumnHeaderGroup;
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.components.gridClasses.GridLayer;
	import egret.ui.components.DataGridHeadRenderer;
	
	
	/**
	 * 深色的datagrid皮肤
	 * @author 雷羽佳
	 */
	public class DataGridSkin extends Skin
	{
		public function DataGridSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var scroller:Scroller;
		
		public var grid:Grid;
		
		public var columnHeaderGroup:GridColumnHeaderGroup;
		
		public var columnSeparator:Class;
		public var headerColumnSeparator:Class;
		public var rowSeparator:Class;
		public var selectionIndicator:Class;
		public var editorIndicator:Class;
		public var hoverIndicator:Class;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			this.columnSeparator = ColumnSeparator;
			this.headerColumnSeparator = HeaderColumnSeparator;
			this.rowSeparator = RowSeparator;
			this.selectionIndicator = SelectionIndicator;
			this.editorIndicator = EditorIndicator;
			this.hoverIndicator = HoverIndicator;
			
			var group:Group = new Group();
			group.top = group.left = group.right = group.bottom = 0;
			addElement(group);
			
			var contentGroup:Group = new Group();
			contentGroup.left = contentGroup.right = contentGroup.bottom = 0;
			contentGroup.top = 23;
			group.addElement(contentGroup);
			var rect:Rect = new Rect();
			rect.percentHeight = rect.percentWidth = 100;
			rect.fillColor = 0x29323B;
			contentGroup.addElement(rect);
			
			scroller = new Scroller();
			scroller.minViewportInset = 0;
			scroller.verticalScrollPolicy = "auto";
			scroller.percentHeight = 100;
			scroller.percentWidth = 100;
			contentGroup.addElement(scroller);
			
			grid = new Grid();
			grid.resizableColumns = true;
			grid.itemRenderer = GridItemRenderer;
			var layer:GridLayer = new GridLayer();
			layer.name = "backgroundLayer";
			grid.addElement(layer);
			layer = new GridLayer();
			layer.name = "selectionLayer";
			grid.addElement(layer);
			layer = new GridLayer();
			layer.name = "editorIndicatorLayer";
			grid.addElement(layer);
			layer = new GridLayer();
			layer.name = "rendererLayer";
			grid.addElement(layer);
			layer = new GridLayer();
			layer.name = "overlayLayer";
			grid.addElement(layer);
			scroller.viewport = grid;
			
			columnHeaderGroup = new GridColumnHeaderGroup();
			columnHeaderGroup.percentWidth = 100;
			columnHeaderGroup.minHeight = 24;
			columnHeaderGroup.columnSeparator = ColumnSeparator;
			columnHeaderGroup.headerRenderer = DataGridHeadRenderer;
			group.addElement(columnHeaderGroup);
			
			
			var border:Rect = new Rect();
			border.mouseEnabled = false;
			border.fillAlpha = 0;
			border.strokeAlpha = 1;
			border.strokeColor = 0x1b2025;
			border.left = border.top = 0;
			border.right = border.bottom = 0;
			this.addElement(border);
			
			if(!DataGrid(hostComponent).itemEditor)
				(hostComponent as DataGrid).itemEditor = ItemEditor;
		}
	}
}
import egret.components.Rect;
import egret.components.gridClasses.DefaultGridItemEditor;
import egret.components.gridClasses.GridItemRenderer;
import egret.ui.skins.GridItemRendererSkin;
import egret.ui.skins.TextInputSkin;

class SelectionIndicator extends Rect
{
	public function SelectionIndicator()
	{
		super();
		fillColor = 0x396895;
	}
}

class HoverIndicator extends Rect
{
	public function HoverIndicator()
	{
		super();
		fillColor = 0x384552;
	}
}

class EditorIndicator extends Rect
{
	public function EditorIndicator()
	{
		super();
		fillColor = 0xFFFFFF;
	}
}

class RowSeparator extends Rect
{
	public function RowSeparator()
	{
		super();
		height = 1;
		fillColor = 0x1b2025;
	}
}

class HeaderColumnSeparator extends Rect
{
	public function HeaderColumnSeparator()
	{
		super();
		width = 1;
		fillColor = 0x1b2025;
	}
}

class ColumnSeparator extends Rect
{
	public function ColumnSeparator()
	{
		super();
		width = 1;
		fillColor = 0x1b2025;
	}
}

class GridItemRenderer extends egret.components.gridClasses.GridItemRenderer
{
	public function GridItemRenderer()
	{
		super();
		this.skinName = GridItemRendererSkin;
	}
}

class ItemEditor extends DefaultGridItemEditor
{
	public function ItemEditor()
	{
		super();
		this.skinName = TextInputSkin;
	}
}