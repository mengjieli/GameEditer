package egret.ui.skins
{
	import egret.components.DataGroup;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.supportClasses.ItemRenderer;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	
	/** 
	 * 菜单皮肤
	 * @author xzper
	 */ 
	public class MenuSkin extends Skin
	{
		public function MenuSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var dataGroup:DataGroup;
		override protected function createChildren():void
		{
			var rect:Rect = new Rect();
			rect.strokeColor = 0x434346;
			rect.strokeAlpha = 1;
			rect.left = rect.top =  0;
			rect.right = rect.bottom = 1;
			rect.fillColor = 0x29323B;
			this.addElement(rect);
			
			dataGroup = new DataGroup();
			dataGroup.left = dataGroup.right = dataGroup.top;
			dataGroup.bottom = 4;
			dataGroup.itemRenderer = ItemRenderer;
			this.addElement(dataGroup);
			
			var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			layout.gap = 0;
			dataGroup.layout = layout;
		}
	}
}


