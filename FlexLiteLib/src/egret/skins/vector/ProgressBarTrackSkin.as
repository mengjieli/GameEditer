package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 进度条轨道默认皮肤
	 * @author dom
	 */
	public class ProgressBarTrackSkin extends VectorSkin
	{
		public function ProgressBarTrackSkin()
		{
			super();
			this.minHeight = 10;
			this.minWidth = 30;
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
				0xdddbdb, 1,
				verticalGradientMatrix(0, 0, w, h)); 
			if(w>4)
				drawLine(1,0,w-1,0,0xbcbcbc);
		}
	}
}