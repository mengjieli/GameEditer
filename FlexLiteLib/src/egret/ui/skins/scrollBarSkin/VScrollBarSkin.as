package egret.ui.skins.scrollBarSkin
{
	import egret.components.Button;
	import egret.components.Skin;
	
	/**
	 * 纵向滚动条
	 * @author 雷羽佳
	 */
	public class VScrollBarSkin extends Skin
	{
		public function VScrollBarSkin()
		{
			super();
			this.states = ["normal","disabled","inactive"];
			this.width = 13;
		}
		
		public var track:Button;
		public var thumb:Button;
		public var decrementButton:Button;
		public var incrementButton:Button;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			track = new Button();
			track.top = track.bottom = 13;
			track.minHeight = 15;
			track.percentWidth = 100;
			track.focusEnabled = false;
			track.tabEnabled = false;
			track.skinName = VScrollBarTrackSkin;
			this.addElement(track);
			
			thumb = new Button();
			thumb.minHeight = 15;
			thumb.horizontalCenter = 0;
			thumb.percentWidth = 100;
			thumb.focusEnabled = false;
			thumb.tabEnabled = false;
			thumb.skinName = ScrollBarThumbSkin
			this.addElement(thumb);
			
			decrementButton = new Button();
			decrementButton.width = decrementButton.height = 13;
			decrementButton.focusEnabled = false;
			decrementButton.tabEnabled = false;
			decrementButton.skinName = ScrollBarUpButtonSkin;
			this.addElement(decrementButton);
			
			incrementButton = new Button();
			incrementButton.bottom = 0;
			incrementButton.width = incrementButton.height = 13;
			incrementButton.focusEnabled = false;
			incrementButton.tabEnabled = false;
			incrementButton.skinName = ScrollBarDownButtonSkin;
			this.addElement(incrementButton);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
		}
	}
}