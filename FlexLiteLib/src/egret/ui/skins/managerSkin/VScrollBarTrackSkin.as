package egret.ui.skins.managerSkin
{
	import egret.components.Rect;
	import egret.components.Skin;
	
	public class VScrollBarTrackSkin extends Skin
	{
		
		public function VScrollBarTrackSkin()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			var backUI:Rect = new Rect();
			backUI.fillColor= 0xdcdedd;
			backUI.percentHeight = backUI.percentWidth = 100;
			addElement(backUI);
		}
	}
}

