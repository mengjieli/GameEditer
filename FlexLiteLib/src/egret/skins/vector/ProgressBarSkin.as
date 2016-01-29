package egret.skins.vector
{

	import egret.components.Label;
	import egret.components.SkinnableComponent;
	import egret.skins.VectorSkin;
	
	
	/**
	 * 进度条默认皮肤
	 * @author dom
	 */
	public class ProgressBarSkin extends VectorSkin
	{
		public function ProgressBarSkin()
		{
			super();
			this.minHeight = 24;
			this.minWidth = 30;
		}
		
		public var thumb:SkinnableComponent;
		public var track:SkinnableComponent;
		public var labelDisplay:Label;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			track = new SkinnableComponent();
			track.skinName = ProgressBarTrackSkin;
			track.left = 0;
			track.right = 0;
			addElement(track);
			
			thumb = new SkinnableComponent();
			thumb.skinName = ProgressBarThumbSkin;
			addElement(thumb);
			
			labelDisplay = new Label();
			labelDisplay.y = 14;
			labelDisplay.horizontalCenter = 0;
			addElement(labelDisplay);
		}
	}
}