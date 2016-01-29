package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * 水平滚动条thumb默认皮肤
	 * @author dom
	 */
	public class HScrollBarThumbSkin extends VectorSkin
	{
		public function HScrollBarThumbSkin()
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
			switch (currentState)
			{			
				case "up":
				case "disabled":
					drawCurrentState(0,0,w,h,borderColors[0],bottomLineColors[0],
						[fillColors[0],fillColors[1]],1);
					break;
				case "over":
					drawCurrentState(0,0,w,h,borderColors[1],bottomLineColors[1],
						[fillColors[2],fillColors[3]],1);
					break;
				case "down":
					drawCurrentState(0,0,w,h,borderColors[2],bottomLineColors[2],
						[fillColors[4],fillColors[5]],1);
					break;
			}
		}
	}
}