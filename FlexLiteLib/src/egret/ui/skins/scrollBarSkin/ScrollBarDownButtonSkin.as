package egret.ui.skins.scrollBarSkin
{
	import egret.core.BitmapSource;
	
	
	/**
	 * 滚动条下按钮
	 * @author 雷羽佳
	 */
	public class ScrollBarDownButtonSkin extends ScrollBarBaseButtonSkin
	{
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnNormal.png")]
		private var uiUpRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnNormal_r.png")]
		private var uiUpRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnHover.png")]
		private var uiOverRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnHover_r.png")]
		private var uiOverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/downBtnDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function ScrollBarDownButtonSkin()
		{
			super();
			uiUpSource = new BitmapSource(uiUpRes,uiUpRes_r);
			uiDownSource = new BitmapSource(uiDownRes,uiDownRes_r);
			uiOverSource = new BitmapSource(uiOverRes,uiOverRes_r);
		}
	}
}