package main.panels.contenView
{
	import egret.ui.skins.IconTabBarButtonSkin;

	public class ContentTabBarSkin extends IconTabBarButtonSkin {
		
		
		public function ContentTabBarSkin()
		{
		}
		
		public var closeButton:ContentCloseButton;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			labelDisplay.right = 20;
			
			closeButton = new ContentCloseButton();
			closeButton.skinName = ContentCloseButtonSkin;
			closeButton.right = 5;
			closeButton.verticalCenter = 0;
			closeButton.scaleX = closeButton.scaleY = 0.6;
			closeButton.visible = false;
			group.addElement(closeButton);
		}
	}
}