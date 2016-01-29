package egret.skins.vector
{
	import flash.display.GradientType;
	
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 水平滚动条track默认皮肤
	 * @author dom
	 */
	public class HScrollBarTrackSkin extends VectorSkin
	{
		public function HScrollBarTrackSkin()
		{
			super();
			states = ["up","over","down","disabled"];
			this.currentState = "up";
			this.minHeight = 15;
			this.minWidth = 15;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			//绘制边框
			drawRoundRect(
				0, 0, w, h, 0,
				borderColors[0], 1,
				verticalGradientMatrix(0, 0, w, h ),
				GradientType.LINEAR, null, 
				{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0}); 
			//绘制填充
			drawRoundRect(
				1, 1, w - 2, h - 2, 0,
				0xdddbdb, 1,
				verticalGradientMatrix(1, 2, w - 2, h - 3)); 
			//绘制底线
			drawLine(1,1,w-1,1,0xbcbcbc);
		}
	}
}