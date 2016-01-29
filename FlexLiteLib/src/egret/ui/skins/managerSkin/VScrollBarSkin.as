package egret.ui.skins.managerSkin
{
	import egret.components.Button;
	import egret.components.Rect;
	import egret.components.Skin;

	public class VScrollBarSkin extends Skin
	{
		public function VScrollBarSkin()
		{
			super();
			this.minWidth = 12;
		}
		
		public var decrementButton:Button;
		public var incrementButton:Button;
		public var thumb:Button;
		public var track:Button;

		override protected function createChildren():void
		{
			super.createChildren();
			var backUI:Rect = new Rect();
			backUI.percentHeight = backUI.percentWidth = 100;
			backUI.fillColor = 0xdcdedd;
			this.addElement(backUI);
			
			track = new Button();
			track.top = track.bottom = 1;
			track.skinName = VScrollBarTrackSkin;
			track.percentWidth = 100;
			this.addElement(track);
			
			thumb = new Button();
//			thumb.horizontalCenter = 0;
			thumb.left = 1;
			thumb.right = 1;
			thumb.skinName = VScrollBarThumbSkin;
			this.addElement(thumb);
//			
//			decrementButton = new Button();
//			decrementButton.width = decrementButton.height = 10;
//			decrementButton.skinName = ScrollBarUpButtonSkin;
//			this.addElement(decrementButton);
//			
//			incrementButton = new Button();
//			incrementButton.bottom = 0;
//			incrementButton.width = incrementButton.height = 10;
//			incrementButton.skinName = ScrollBarDownButtonSkin;
//			this.addElement(incrementButton);
		}
	}
}
