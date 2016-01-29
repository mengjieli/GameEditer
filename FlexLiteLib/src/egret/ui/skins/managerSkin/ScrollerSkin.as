package egret.ui.skins.managerSkin
{
	import egret.components.Skin;
	import egret.components.VScrollBar;

	public class ScrollerSkin extends Skin
	{
		public function ScrollerSkin()
		{
			super();
		}
		
		public var verticalScrollBar:VScrollBar;
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			verticalScrollBar = new VScrollBar();
			verticalScrollBar.skinName = VScrollBarSkin;
			verticalScrollBar.visible = false;
			addElement(verticalScrollBar);
		}
	}
}