package egret.skins.vector
{
	import egret.components.DataGroup;
	import egret.components.supportClasses.ItemRenderer;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.skins.VectorSkin;
	
	
	/**
	 * SkinnableDataContainer默认皮肤
	 * @author dom
	 */
	public class SkinnableDataContainerSkin extends VectorSkin
	{
		public function SkinnableDataContainerSkin()
		{
			super();
			minWidth = 70;
			minHeight = 70;
		}
		
		public var dataGroup:DataGroup;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			dataGroup = new DataGroup();
			dataGroup.itemRenderer = ItemRenderer;
			var layout:VerticalLayout = new VerticalLayout();
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			dataGroup.layout = layout;
			addElement(dataGroup);
		}
	}
}