package egret.skins.vector
{
	import egret.components.Group;
	import egret.components.Menu;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.menuClasses.MenuBarItemRenderer;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;

	/**
	 * 菜单栏皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class MenuBarSkin extends Skin
	{
		public function MenuBarSkin()
		{
			super();
		}
		
		public var menuBarItemRenderer:Class = MenuBarItemRenderer;
		public var menu:Class = Menu;
		private var bg:Rect;
		public var contentGroup:Group
		private var group:Group;
		override protected function createChildren():void
		{
			group = new Group();
			group.minHeight = 21;
			group.minWidth = 21;
			group.left = 0;
			group.right = 0;
			this.addElement(group);
			
			bg = new Rect();
			bg.fillColor = 0xeeeeee;
			bg.left = bg.right = bg.top = bg.bottom = 0;
			group.addElement(bg);
			
			contentGroup = new Group();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = VerticalAlign.JUSTIFY;
			layout.gap = 0;
			contentGroup.layout = layout;
			contentGroup.top = 0;
			contentGroup.bottom = 0;
			contentGroup.left = 0;
			contentGroup.right = 0;
			group.addElement(contentGroup);
		}
		
		
	}
}