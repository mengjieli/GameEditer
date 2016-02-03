package main.panels.contenView
{
	import egret.components.Skin;
	import egret.components.UIAsset;

	public class ContentCloseButtonSkin extends Skin
	{
		[Embed(source="/assets/binding/button/close_normal.png")]
		private var uiNormalRes:Class;
		[Embed(source="/assets/binding/button/close_over.png")]
		private var uiHoverRes:Class;
		[Embed(source="/assets/binding/button/close_down.png")]
		private var uiDownRes:Class;
		
		public function ContentCloseButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}
		
		private var ui:UIAsset;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			ui = new UIAsset();
			this.addElement(ui);
		}
		
		override protected function commitCurrentState():void
		{
			switch(currentState)
			{
				case "up":
				{
					ui.source = uiNormalRes;
					break;
				}
				case "over":
				{
					ui.source = uiHoverRes;
					break;
				}
				case "down":
				{
					ui.source = uiDownRes;
					break;
				}
				case "disabled":
				{
					ui.source = uiNormalRes;
					break;
				}	
			}
		}
	}
}