package egret.ui.skins
{
	import egret.components.Group;
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
			group.minHeight = 23;
			group.minWidth = 23;
			group.left = 0;
			group.right = 0;
			this.addElement(group);
			
			bg = new Rect();
			bg.fillColor = 0xeeeeee;
			bg.fillAlpha = 0;
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
import egret.components.Menu;
import egret.ui.skins.MenuItemRendererSkin;
import egret.ui.skins.MenuSkin;


class Menu extends egret.components.Menu
{
	public function Menu()
	{
		super();
		this.skinName = MenuSkin;
		this.itemRendererSkinName = MenuItemRendererSkin;
	}
}



