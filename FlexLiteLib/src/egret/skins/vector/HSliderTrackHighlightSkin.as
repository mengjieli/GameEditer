package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 水平滑块track默认皮肤
	 * @author dom
	 */
	public class HSliderTrackHighlightSkin extends VectorSkin
	{
		public function HSliderTrackHighlightSkin()
		{
			super();
			this.minHeight = 4;
			this.minWidth = 15;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			var offsetY:Number = Math.round(h*0.5-2);
			
			graphics.clear();
			graphics.beginFill(0xFFFFFF,0);
			graphics.drawRect(0,0,w,h);
			graphics.endFill();
			h=4;
			graphics.lineStyle();
			drawRoundRect(
				0, offsetY, w, h, 1,
				fillColors[2], 1,
				verticalGradientMatrix(0, offsetY, w, h)); 
			if(w>5)
				drawLine(1,offsetY,w-1,offsetY,0x457cb2);
		}
	}
}