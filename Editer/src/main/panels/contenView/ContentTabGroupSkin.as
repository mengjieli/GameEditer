package main.panels.contenView
{
	import egret.ui.skins.TabGroupSkin;

	public class ContentTabGroupSkin extends TabGroupSkin
	{
		public function ContentTabGroupSkin()
		{
			super();
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			titleTabBar.itemRenderer = ContentTabBar;
			titleTabBar.itemRendererSkinName = ContentTabBarSkin;
		}
	}
}