package egret.ui.skins.managerSkin
{
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	
	public class ButtonSkin extends Skin
	{
		public function ButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minWidth = 80;
			this.minHeight = 40;
		}
		private var backUI:Rect;
		
		public var labelDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			backUI = new Rect()
			backUI.strokeWeight = 2;
			backUI.percentHeight=backUI.percentWidth=100;
			this.addElement(backUI);
			
			labelDisplay = new Label();
			labelDisplay.textAlign = "center";
			labelDisplay.left = labelDisplay.right = 10;
			labelDisplay.horizontalCenter = 0;
			labelDisplay.verticalCenter = 0;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.size=18;
			this.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			backUI.fillAlpha = 1;
			backUI.strokeAlpha = 0;
			labelDisplay.textColor = 0xffffff;
			if(this.currentState == "up")
			{
				backUI.strokeAlpha = 1;
				backUI.fillAlpha = 0;
				backUI.strokeColor = 0x00a0f0;
				labelDisplay.textColor = 0x00a0f0;
			}
			else if(this.currentState == "over")
			{
				backUI.fillColor = 0x00a0f0;
			}
			else if(this.currentState == "down")
			{
				backUI.fillColor = 0x0085c8;
			}
			else if(this.currentState == "disabled")
			{
				backUI.strokeAlpha = 1;
				backUI.fillAlpha = 0;
				backUI.strokeColor = 0xe0e0e0;
				labelDisplay.textColor = 0xe0e0e0;
			}
		}
	}
}

