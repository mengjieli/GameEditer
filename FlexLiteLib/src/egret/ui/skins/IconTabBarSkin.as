package egret.ui.skins
{
	import egret.components.DataGroup;
	import egret.components.Skin;
	import egret.ui.components.IconTabBarButton;
	import egret.layouts.HorizontalLayout;

	/**
	 * 图标切换工具条的皮肤
	 * @author 雷羽佳
	 * 
	 */	
	public class IconTabBarSkin extends Skin
	{
		public function IconTabBarSkin()
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
			dataGroup.layout = bbhLayout;
			dataGroup.itemRenderer = IconTabBarButton;
			dataGroup.itemRendererSkinName = IconToggleButtonSkin;
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			
			if(currentState == "normal")
			{
				
			}else if(currentState == "disabled")
			{
				
			}
		}
	}
}