package egret.ui.skins.scrollBarSkin
{
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * 滚动条基本按钮
	 * @author 雷羽佳
	 */
	public class ScrollBarBaseButtonSkin extends Skin
	{
		protected var uiUpSource:Object;
		protected var uiOverSource:Object;
		protected var uiDownSource:Object;
		
		public function ScrollBarBaseButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}
		
		private var ui:UIAsset;
		private var back:Rect;

		override protected function createChildren():void
		{
			super.createChildren();
			back = new Rect();
			back.fillColor = 0x2f3b45;
			back.percentHeight = back.percentWidth = 100;
			this.addElement(back);
			
			ui = new UIAsset();
			ui.horizontalCenter = ui.verticalCenter = 0;
			this.addElement(ui);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "disabled")
			{
				ui.alpha = 0.5;
			}else
			{
				ui.alpha = 1;	
			}
			
			if(currentState == "up" || currentState == "disabled")
			{
				ui.source = uiUpSource;
			}else if(currentState == "over")
			{
				ui.source = uiOverSource;
			}else if(currentState == "down")
			{
				ui.source = uiDownSource;
			}
			
		}
	}
}


