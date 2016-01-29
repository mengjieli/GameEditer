package egret.ui.skins
{
	import egret.components.DataGroup;
	import egret.components.Skin;
	import egret.components.TabBarButton;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	
	/**
	 * 切换选项卡条的皮肤
	 * @author 雷羽佳
	 * 
	 */	
	public class TabBarSkin extends Skin
	{
		public function TabBarSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var dataGroup:DataGroup;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			dataGroup = new DataGroup();
			dataGroup.percentWidth = 100;
			dataGroup.percentHeight = 100;
			this.addElement(dataGroup);
			
			var bbhLayout:HorizontalLayout = new HorizontalLayout();
			bbhLayout.gap = -1;
			bbhLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			dataGroup.layout = bbhLayout;
			dataGroup.itemRenderer = TabBarButton;
			dataGroup.itemRendererSkinName = IconTabBarButtonSkin;
		}
	}
}



