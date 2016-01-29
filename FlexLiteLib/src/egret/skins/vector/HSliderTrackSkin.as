package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 水平滑块track默认皮肤
	 * @author dom
	 */
	public class HSliderTrackSkin extends VectorSkin
	{
		public function HSliderTrackSkin()
		{
			super();
			states = ["up","over","down","disabled"];
			this.currentState = "up";
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
				0xdddbdb, 1,
				verticalGradientMatrix(0, offsetY, w, h)); 
			if(w>4)
				drawLine(1,offsetY,w-1,offsetY,0xbcbcbc);
		}
	}
}