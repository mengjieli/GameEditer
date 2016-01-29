package egret.skins.vector
{
	import egret.components.Button;
	import egret.components.SkinnableComponent;
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * 垂直滑块默认皮肤
	 * @author dom
	 */
	public class VSliderSkin extends VectorSkin
	{
		public function VSliderSkin()
		{
			super();
			this.minWidth = 11;
			this.minHeight = 50;
		}
		
		public var thumb:Button;
		
		public var track:Button;
		
		public var trackHighlight:SkinnableComponent;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			track = new Button;
			track.left = 0;
			track.right = 0;
			track.top = 0;
			track.bottom = 0;
			track.minHeight = 33;
			track.height = 100;
			track.tabEnabled = false;
			track.skinName = VSliderTrackSkin;
			addElement(track);
			
			trackHighlight = new SkinnableComponent();
			trackHighlight.left = 0;
			trackHighlight.right = 0;
			trackHighlight.minHeight = 33;
			trackHighlight.height = 100;
			trackHighlight.tabEnabled = false;
			trackHighlight.skinName = VSliderTrackHighlightSkin;
			addElement(trackHighlight);
			
			thumb = new Button();
			thumb.left = 0;
			thumb.right = 0;
			thumb.width = 11;
			thumb.height = 11;
			thumb.tabEnabled = false;
			thumb.skinName = SliderThumbSkin;
			addElement(thumb);
		}
		
		
	}
}