package egret.ui.skins
{
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.VerticalAlign;
	
	/**
	 * 一般按钮的皮肤
	 * @author 雷羽佳
	 */
	public class ButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/button/normal.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/button/hover.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/button/down.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/button/disabled.png")]
		private var uiDisabled:Class;
		
		public function ButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minHeight = 23;
		}
		
		private var backUI:UIAsset;
		
		public var labelDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			backUI = new UIAsset()
			backUI.source = uiNormalRes;
			backUI.scale9Grid = new Rectangle(2,2,1,1);
			backUI.left = 0;
			backUI.right = 0;
			backUI.bottom = 0;
			backUI.top = 0;
			this.addElement(backUI);
			
			labelDisplay = new Label();
			labelDisplay.top = labelDisplay.bottom = 1;
			labelDisplay.left = labelDisplay.right = 10;
			labelDisplay.textAlign = TextFormatAlign.CENTER;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			this.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			labelDisplay.alpha = 1;
			switch(currentState)
			{
				case "up":
				{
					backUI.source = uiNormalRes;
					break;
				}
				case "over":
				{
					backUI.source = uiHoverRes;
					break;
				}
				case "down":
				{
					backUI.source = uiDownRes;
					break;
				}
				case "disabled":
				{
					backUI.source = uiDisabled;
					labelDisplay.alpha = 0.2;
					break;
				}	
			}
		}
	}
}