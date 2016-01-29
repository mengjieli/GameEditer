package egret.ui.skins
{
	import egret.components.DataGroup;
	import egret.components.Skin;
	import egret.layouts.HorizontalLayout;
	import egret.ui.components.boxClasses.CloseTabButton;
	
	/**
	 * Doc切换选项卡条的皮肤
	 * @author 雷羽佳
	 * 
	 */	
	public class DocTabBarSkin extends Skin
	{
		public function DocTabBarSkin()
		{
			super();
			this.states = ["normal","disabled"]
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
//			bbhLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			dataGroup.layout = bbhLayout;
			dataGroup.itemRenderer = CloseTabButton;
			dataGroup.itemRendererSkinName = CloseTabButtonSkin;
		}
	}
}


