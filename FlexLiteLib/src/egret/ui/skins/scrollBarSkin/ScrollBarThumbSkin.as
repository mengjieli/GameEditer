package egret.ui.skins.scrollBarSkin
{
	import egret.components.Rect;
	import egret.components.Skin;
	
	/**
	 * 滚动条手柄的皮肤基类
	 * @author 雷羽佳
	 */
	public class ScrollBarThumbSkin extends Skin
	{
		public function ScrollBarThumbSkin()
		{
			super();	
			this.states = ["up","over","down","disabled"]
		}
		
		private var ui:Rect;
		
		override protected function createChildren():void
		{
			super.createChildren();
			ui = new Rect();
			ui.percentHeight = ui.percentWidth = 100;
			ui.fillColor = 0x546c77;
			this.addElement(ui);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up" || currentState == "disabled")
			{
				ui.fillColor = 0x546c77;
			}else if(currentState == "over")
			{
				ui.fillColor = 0x709eb8;
			}else if(currentState == "down")
			{
				ui.fillColor = 0x546c77;
			}
		}
	}
}