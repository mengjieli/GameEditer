package egret.ui.skins
{
	import egret.components.DataGroup;
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.components.supportClasses.ItemRenderer;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.ui.skins.scrollBarSkin.ScrollerSkin;
	
	/**
	 * 列表的皮肤
	 * @author 雷羽佳
	 */
	public class ListSkin extends Skin
	{
		public function ListSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var scroller:Scroller
		public var dataGroup:DataGroup;
		override protected function createChildren():void
		{
			scroller = new Scroller();
			scroller.left = scroller.top = scroller.bottom = 0;
			scroller.right  = 0;
			scroller.minViewportInset = 0;
			scroller.skinName=ScrollerSkin;
			this.addElement(scroller);
			
			dataGroup = new DataGroup();
			dataGroup.itemRenderer = ItemRenderer;
			scroller.viewport = dataGroup;
			
			var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			layout.gap = 0;
			dataGroup.layout = layout;
			
			
		}
	}
}