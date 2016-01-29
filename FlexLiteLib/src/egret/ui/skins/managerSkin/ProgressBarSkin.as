package egret.ui.skins.managerSkin
{
	import egret.components.Skin;
	import egret.components.SkinnableComponent;
	
	
	/**
	 * 进度条默认皮肤
	 * @author dom
	 */
	public class ProgressBarSkin extends Skin
	{
		public function ProgressBarSkin()
		{
			super();
			this.minHeight = 10;
			this.minWidth = 30;
		}
		
		public var thumb:SkinnableComponent;
		public var track:SkinnableComponent;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			track = new SkinnableComponent();
			track.skinName = ProgressBarTrackSkin;
			track.percentHeight=100;
			track.left = 0;
			track.right = 0;
			this.addElement(track);
			
			thumb = new SkinnableComponent();
			thumb.percentHeight=100;
			thumb.skinName = ProgressBarThumbSkin;
			this.addElement(thumb);
		}
	}
}
