package egret.skins.vector
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.text.TextFormatAlign;
	
	import egret.core.ns_egret;
	import egret.components.Label;
	import egret.layouts.VerticalAlign;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	
	/**
	 * ItemRenderer默认皮肤
	 * @author dom
	 */
	public class ItemRendererSkin extends VectorSkin
	{
		public function ItemRendererSkin()
		{
			super();
			states = ["up","over","down"];
			this.minHeight = 21;
			this.minWidth = 21;
		}
		
		public var labelDisplay:Label;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			labelDisplay = new Label();
			labelDisplay.textAlign = TextFormatAlign.CENTER;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.left = 5;
			labelDisplay.right = 5;
			labelDisplay.top = 3;
			labelDisplay.bottom = 3;
			addElement(labelDisplay);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			var g:Graphics = graphics;
			g.clear();
			var textColor:uint;
			switch (currentState)
			{			
				case "up":
				case "disabled":
					drawRoundRect(
						0, 0, w, h, 0,
						0xFFFFFF, 1,
						verticalGradientMatrix(0, 0, w, h)); 
					textColor = themeColors[0];
					break;
				case "over":
				case "down":
					drawRoundRect(
						0, 0, w, h, 0,
						borderColors[0], 1,
						verticalGradientMatrix(0, 0, w, h ),
						GradientType.LINEAR, null, 
						{ x: 0, y: 0, w: w, h: h - 1, r: 0});
					drawRoundRect(
						0, 0, w, h - 1, 0,
						0x4f83c4, 1,
						verticalGradientMatrix(0, 0, w, h - 1)); 
					textColor = themeColors[1];
					break;
			}
			if(labelDisplay)
			{
				labelDisplay.textColor = textColor;
				labelDisplay.applyTextFormatNow();
				labelDisplay.filters = (currentState=="over"||currentState=="down")?textOverFilter:null;
			}
		}
	}
}