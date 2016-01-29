package egret.skins.vector
{
	import egret.components.DataGroup;
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
			dataGroup = new DataGroup();
			dataGroup.left = dataGroup.right = dataGroup.top = dataGroup.bottom = 0;
			dataGroup.itemRenderer = ItemRenderer;
			this.addElement(dataGroup);
			
			var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			layout.gap = 0;
			dataGroup.layout = layout;
		}
	}
}


