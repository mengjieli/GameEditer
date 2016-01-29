package egret.skins.vector
{
	import egret.core.ns_egret;
	import egret.components.DataGroup;
	import egret.components.TabBarButton;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;

	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * TabBar默认皮肤
	 * @author dom
	 */
	public class TabBarSkin extends VectorSkin
	{
		public function TabBarSkin()
		{
			super();
			minWidth = 60;
			minHeight = 20;
		}
		
		public var dataGroup:DataGroup;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			dataGroup = new DataGroup();
			dataGroup.percentWidth = 100;
			dataGroup.percentHeight = 100;
			dataGroup.itemRenderer = TabBarButton;
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.gap = -1;
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			layout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
			dataGroup.layout = layout;
			addElement(dataGroup);
		}
		
	}
}