package egret.ui.skins
{
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 * Doc文档选项卡的关闭按钮
	 * @author 雷羽佳
	 */
	public class DocCloseButtonSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButton.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButton_r.png")]
		private var uiNormalRes_r:Class;
		
		private var uiNormalSource:BitmapSource = new BitmapSource(uiNormalRes,uiNormalRes_r);
		
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButtonDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButtonDown_r.png")]
		private var uiDownRes_r:Class;
		
		private var uiDownSource:BitmapSource = new BitmapSource(uiDownRes,uiDownRes_r);
		
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButtonOver.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/closeBtn/CloseButtonOver_r.png")]
		private var uiHoverRes_r:Class;
		
		private var uiHoverSource:BitmapSource = new BitmapSource(uiHoverRes,uiHoverRes_r);

		public function DocCloseButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}

		private var icon:UIAsset;
		override protected function createChildren():void
		{
			super.createChildren();
			
			icon = new UIAsset();
			icon.x = 4;
			icon.y = 2;
			this.addElement(icon);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState()
			if(currentState == "up" || currentState == "disabled")
			{
				icon.source = uiNormalSource;
			}
			else if(currentState == "over")
			{
				icon.source = uiHoverSource;
			}
			else if(currentState == "down")
			{
				icon.source = uiDownSource;
			}
		}
		
	}
}