package egret.skins.vector
{
	import egret.components.Button;
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * 水平滚动条默认皮肤
	 * @author dom
	 */
	public class HScrollBarSkin extends VectorSkin
	{
		public function HScrollBarSkin()
		{
			super();
			this.minWidth = 50;
			this.minHeight = 15;
		}
		
		public var decrementButton:Button;
		
		public var incrementButton:Button;
		
		public var thumb:Button;
		
		public var track:Button;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			track = new Button();
			track.left = 16;
			track.right = 16;
			track.width = 54;
			track.skinName = HScrollBarTrackSkin;
			addElement(track);
			
			decrementButton = new Button();
			decrementButton.left = 0;
			decrementButton.skinName = ScrollBarLeftButtonSkin;
			addElement(decrementButton);
			
			incrementButton = new Button();
			incrementButton.right = 0;
			incrementButton.skinName = ScrollBarRightButtonSkin;
			addElement(incrementButton);
			
			thumb = new Button();
			thumb.minWidth = 15;
			thumb.skinName = HScrollBarThumbSkin;
			addElement(thumb);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w,h);
		}
		
	}
}