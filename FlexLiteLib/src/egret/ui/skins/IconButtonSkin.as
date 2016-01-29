package egret.ui.skins
{
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * 只包含图片的按钮的皮肤
	 * @author 雷羽佳
	 */
	public class IconButtonSkin extends Skin
	{
		public function IconButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minHeight = this.minWidth = 24;
		}
		
		private var ui:Rect;
		
		public var iconDisplay:UIAsset;
		override protected function createChildren():void
		{
			super.createChildren();

			ui = new Rect();
			ui.percentWidth = ui.percentHeight = 100;
			ui.fillColor = 0xffffff;
			ui.fillAlpha = 0;
			this.addElement(ui);
			
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			iconDisplay.horizontalCenter = 0;
			this.addElement(iconDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			if(currentState == "up" || currentState == "disabled")
			{
				ui.fillColor = 0xffffff;
				ui.fillAlpha = 0;
			}
			else if(currentState == "over")
			{
				ui.fillColor = 0x34464e;
				ui.fillAlpha = 1;
			}
			else if(currentState == "down")
			{
				ui.fillColor = 0x1b2124;
				ui.fillAlpha = 1;
			}
			
			if(currentState == "disabled")
				this.ui.alpha = this.iconDisplay.alpha = 0.5;
			else
				this.ui.alpha = this.iconDisplay.alpha = 1;
			
		}
	}
}