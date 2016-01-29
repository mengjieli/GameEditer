package egret.ui.skins.scrollBarSkin
{
	import egret.components.Button;
	import egret.components.Skin;
	
	/**
	 * 水平滚动条
	 * @author 雷羽佳
	 */
	public class HScrollBarSkin extends Skin
	{
		public function HScrollBarSkin()
		{
			super();
			this.states = ["normal","disabled","inactive"];
			this.height = 13;
			this.minWidth = 26;
		}
		public var track:Button;
		public var thumb:Button;
		public var decrementButton:Button;
		public var incrementButton:Button;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			track = new Button();
			track.left = track.right = 13;
			track.minWidth = 15;
			track.percentHeight = 100;
			track.focusEnabled = false;
			track.tabEnabled = false;
			track.skinName = HScrollBarTrackSkin;;
			this.addElement(track);
			
			thumb = new Button();
			thumb.minWidth = 15;
			thumb.verticalCenter = 0;
			thumb.percentHeight = 100;
			thumb.focusEnabled = false;
			thumb.tabEnabled = false;
			thumb.skinName = ScrollBarThumbSkin;
			this.addElement(thumb);
			
			decrementButton = new Button();
			decrementButton.width = decrementButton.height = 13;
			decrementButton.left = 0;
			decrementButton.focusEnabled = false;
			decrementButton.tabEnabled = false;
			decrementButton.skinName = ScrollBarLeftButtonSkin;
			this.addElement(decrementButton);
			
			incrementButton = new Button();
			incrementButton.right = 0;
			incrementButton.width = incrementButton.height = 13;
			incrementButton.focusEnabled = false;
			incrementButton.tabEnabled = false;
			incrementButton.skinName = ScrollBarRightButtonSkin;
			this.addElement(incrementButton);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
		}
	}
}