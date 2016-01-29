package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 水平滑块track默认皮肤
	 * @author dom
	 */
	public class VSliderTrackHighlightSkin extends VectorSkin
	{
		public function VSliderTrackHighlightSkin()
		{
			super();
			this.minHeight = 15;
			this.minWidth = 4;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			var offsetX:Number = Math.round(w*0.5-2);
			
			graphics.clear();
			graphics.beginFill(0xFFFFFF,0);
			graphics.drawRect(0,0,w,h);
			graphics.endFill();
			w=4;
			graphics.lineStyle();
			drawRoundRect(
				offsetX,0, w, h, 1,
				fillColors[2], 1,
				verticalGradientMatrix(offsetX,0, w, h)); 
			if(h>5)
				drawLine(offsetX,1,offsetX,h-1,0x457cb2);
		}
	}
}