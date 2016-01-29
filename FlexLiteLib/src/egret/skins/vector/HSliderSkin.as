package egret.skins.vector
{
	import egret.components.Button;
	import egret.components.SkinnableComponent;
	import egret.components.UIAsset;
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * 水平滑块默认皮肤
	 * @author dom
	 */
	public class HSliderSkin extends VectorSkin
	{
		public function HSliderSkin()
		{
			super();
			this.minWidth = 50;
			this.minHeight = 11;
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
			track.minWidth = 33;
			track.width = 100;
			track.tabEnabled = false;
			track.skinName = HSliderTrackSkin;
			addElement(track);
			
			trackHighlight = new SkinnableComponent();
			trackHighlight.top = 0;
			trackHighlight.bottom = 0;
			trackHighlight.minWidth = 33;
			trackHighlight.width = 100;
			trackHighlight.tabEnabled = false;
			trackHighlight.skinName = HSliderTrackHighlightSkin;
			addElement(trackHighlight);
			
			thumb = new Button();
			thumb.top = 0;
			thumb.bottom = 0;
			thumb.width = 11;
			thumb.height = 11;
			thumb.tabEnabled = false;
			thumb.skinName = SliderThumbSkin;
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