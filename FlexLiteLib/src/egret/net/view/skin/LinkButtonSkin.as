package egret.net.view.skin
{
	import flash.text.TextFormatAlign;
	
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	
	/**
	 * 链接按钮的皮肤
	 * @author 雷羽佳
	 */
	public class LinkButtonSkin extends Skin
	{
		public function LinkButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minHeight = 23;
		}
		
		public var labelDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			var rect:Rect = new Rect();
			rect.fillAlpha = 0;
			rect.fillColor = 0xffffff;
			rect.left = 0;
			rect.right = 0;
			rect.bottom = 0;
			rect.top = 0;
			this.addElement(rect);
			
			labelDisplay = new Label();
			labelDisplay.left = labelDisplay.right = 10;
			labelDisplay.verticalCenter = 0;
			labelDisplay.textAlign = TextFormatAlign.CENTER;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.textColor = 0xfefefe;
			labelDisplay.underline = true;
			this.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			labelDisplay.alpha = 1;
			labelDisplay.textColor = 0xfefefe;
			switch(currentState)
			{
				case "up":
				{
					labelDisplay.textColor = 0xfefefe;
					break;
				}
				case "over":
				{
					labelDisplay.textColor = 0xffffff;
					break;
				}
				case "down":
				{
					labelDisplay.textColor = 0xffffff;
					break;
				}
				case "disabled":
				{
					labelDisplay.textColor = 0xffffff;
					labelDisplay.alpha = 0.2;
				}	
			}
		}
	}
}


