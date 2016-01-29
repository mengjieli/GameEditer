package egret.skins.vector
{
	import egret.components.Grid;
	import egret.components.GridColumnHeaderGroup;
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.components.gridClasses.GridItemRenderer;
	import egret.components.gridClasses.GridLayer;
	
	
	/**
	 * 
	 * @author dom
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
		public var headerRenderer:Class = GridItemRenderer;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			this.columnSeparator = ColumnSeparator;
			this.headerColumnSeparator = HeaderColumnSeparator;
			this.rowSeparator = RowSeparator;
			this.selectionIndicator = SelectionIndicator;
			this.editorIndicator = EditorIndicator;
			
			var group:Group = new Group();
			group.top = group.left = group.right = group.bottom = 0;
			addElement(group);
			
			var contentGroup:Group = new Group();
			contentGroup.left = contentGroup.right = contentGroup.bottom = 0;
			contentGroup.top = 19;
			group.addElement(contentGroup);
			var rect:Rect = new Rect();
			rect.fillColor = 0x535353;
			contentGroup.addElement(rect);
			
			scroller = new Scroller();
			scroller.minViewportInset = 0;
			scroller.verticalScrollPolicy = "on";
			scroller.percentHeight = 100;
			scroller.percentWidth = 100;
			scroller.skinName = ScrollerSkin;
			contentGroup.addElement(scroller);
			
			grid = new Grid();
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
			columnHeaderGroup.minHeight = 20;
			columnHeaderGroup.columnSeparator = ColumnSeparator;
			columnHeaderGroup.headerRenderer = GridItemRenderer;
			group.addElement(columnHeaderGroup);
		}
	}
}
import egret.components.Rect;

class SelectionIndicator extends Rect
{
	public function SelectionIndicator()
	{
		super();
		fillColor = 0x596678;
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
		fillColor = 0x383838;
	}
}

class HeaderColumnSeparator extends Rect
{
	public function HeaderColumnSeparator()
	{
		super();
		width = 1;
		fillColor = 0x383838;
	}
}

class ColumnSeparator extends Rect
{
	public function ColumnSeparator()
	{
		super();
		width = 1;
		fillColor = 0x383838;
	}
}

