package egret.ui.skins
{
	import egret.ui.components.boxClasses.CloseTabButton;
	import egret.ui.components.boxClasses.DocDropDownList;
	
	
	/**
	 * Doc选项卡面板组的皮肤
	 * @author 雷羽佳
	 */
	public class DocTabGroupSkin extends TabGroupSkin
	{
		public function DocTabGroupSkin()
		{
			super();
		}
		
		public var tabDropDown:DocDropDownList;
		
		override protected function createChildren():void
		{
			super.createChildren();
			titleTabBar.skinName = DocTabBarSkin;
			titleTabBar.itemRenderer = CloseTabButton;
			titleTabBar.itemRendererSkinName = CloseTabButtonSkin;
			
			tabDropDown = new DocDropDownList();
			tabDropDown.skinName = DocDropDownListSkin;
			tabDropDown.width = 30;
			this.addElement(tabDropDown);
		}
	}
}