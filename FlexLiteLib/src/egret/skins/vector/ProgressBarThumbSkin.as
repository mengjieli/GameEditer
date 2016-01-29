package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * 
	 * @author dom
	 */
	public class ProgressBarThumbSkin extends VectorSkin
	{
		public function ProgressBarThumbSkin()
		{
			super();
			this.minHeight = 10;
			this.minWidth = 5;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			graphics.beginFill(0xFFFFFF,0);
			graphics.drawRect(0,0,w,h);
			graphics.endFill();
			graphics.lineStyle();
			drawRoundRect(
				0, 0, w, h, 0,
				fillColors[2], 1,
				verticalGradientMatrix(0, 0, w, h)); 
			if(w>5)
				drawLine(1,0,w-1,0,0x457cb2);
		}
	}
}