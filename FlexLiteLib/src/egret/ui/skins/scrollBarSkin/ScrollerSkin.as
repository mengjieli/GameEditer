package egret.ui.skins.scrollBarSkin
{
	import egret.components.HScrollBar;
	import egret.components.Skin;
	import egret.components.VScrollBar;
	
	/**
	 * 滚动条皮肤
	 * @author 雷羽佳
	 */
	public class ScrollerSkin extends Skin
	{
		public function ScrollerSkin()
		{
			super();
		}
		
		public var horizontalScrollBar:HScrollBar;
		public var verticalScrollBar:VScrollBar;
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			horizontalScrollBar = new HScrollBar();
			horizontalScrollBar.visible = false;
			addElement(horizontalScrollBar);
			
			verticalScrollBar = new VScrollBar();
			verticalScrollBar.visible = false;
			addElement(verticalScrollBar);
		}
	}
}

