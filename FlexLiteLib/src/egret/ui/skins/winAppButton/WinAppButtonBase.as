package egret.ui.skins.winAppButton
{
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * win窗体的按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinAppButtonBase extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/windowBtn/normal.png")]
		private var uiNormalRes:Class;
		
		[Embed(source="/egret/ui/skins/assets/windowBtn/hover.png")]
		private var uiHoverRes:Class;
		
		[Embed(source="/egret/ui/skins/assets/windowBtn/down.png")]
		private var uiDownRes:Class;
		
		protected var iconSource:Object;
		
		private var back:UIAsset;
		
		private var icon:UIAsset;
		public function WinAppButtonBase()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minWidth = 33;
			this.minHeight = 24;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			back = new UIAsset()
			back.source = uiNormalRes;
			back.left = 0;
			back.right = 0;
			back.bottom = 0;
			back.top = 0;
			this.addElement(back);
			
			icon = new UIAsset()
			icon.source = iconSource;
			icon.verticalCenter = 0;
			icon.horizontalCenter = 0;
			this.addElement(icon);
		}
		
		override protected function commitCurrentState():void
		{
			icon.alpha = back.alpha = 1;
			switch(currentState)
			{
				case "up":
				{
					back.source = uiNormalRes;
					break;
				}
				case "over":
				{
					back.source = uiHoverRes;
					break;
				}
				case "down":
				{
					back.source = uiDownRes;
					break;
				}
				case "disabled":
				{
					back.alpha = 0.6;
					icon.alpha = 0.3;
					break;
				}	
			}
		}
	}
}


