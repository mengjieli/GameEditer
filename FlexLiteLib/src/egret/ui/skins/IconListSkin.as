package egret.ui.skins
{
	import egret.components.Rect;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.skins.vector.ListSkin;
	import egret.ui.components.IconItemRenderer;
	import egret.ui.skins.scrollBarSkin.ScrollerSkin;

	/**
	 * 图表列表的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconListSkin extends egret.skins.vector.ListSkin
	{
		private var rect:Rect;
		
		public function IconListSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			rect = new Rect();
			rect.fillColor = 0x1e2329;
			rect.left = 0;
			rect.right = 0;
			rect.bottom = 0;
			rect.top = 0;
			this.addElement(rect);
			
			scroller.skinName = ScrollerSkin;
			scroller.left = 1;
			scroller.top = 1;
			scroller.right = 1;
			scroller.bottom = 1;
			scroller.minViewportInset = 0;
			this.addElement(scroller);
			
			dataGroup.itemRenderer = IconItemRenderer;
			var layout:VerticalLayout = new VerticalLayout();
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			dataGroup.layout = layout;
			scroller.viewport = dataGroup;
		}
	}
}