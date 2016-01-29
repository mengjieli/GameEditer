package egret.ui.skins.scrollBarSkin
{
	import egret.core.BitmapSource;
	
	
	/**
	 * 滚动条右按钮
	 * @author 雷羽佳
	 */
	public class ScrollBarRightButtonSkin extends ScrollBarBaseButtonSkin
	{
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnNormal.png")]
		private var uiUpRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnNormal_r.png")]
		private var uiUpRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnHover.png")]
		private var uiOverRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnHover_r.png")]
		private var uiOverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/rightBtnDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function ScrollBarRightButtonSkin()
		{
			super();
			uiUpSource = new BitmapSource(uiUpRes,uiUpRes_r);
			uiDownSource = new BitmapSource(uiDownRes,uiDownRes_r);
			uiOverSource = new BitmapSource(uiOverRes,uiOverRes_r);
		}
	}
}