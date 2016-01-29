package egret.skins.vector
{
	import flash.display.GradientType;
	
	import egret.components.DataGroup;
	import egret.components.Scroller;
	import egret.components.supportClasses.ItemRenderer;
	import egret.core.ns_egret;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * List默认皮肤
	 * @author dom
	 */
	public class ListSkin extends VectorSkin
	{
		public function ListSkin()
		{
			super();
			minWidth = 70;
			minHeight = 70;
		}
		
		public var dataGroup:DataGroup;
		
		public var scroller:Scroller;
		
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
			
			scroller = new Scroller();
			scroller.left = 0;
			scroller.top = 0;
			scroller.right = 0;
			scroller.bottom = 0;
			scroller.minViewportInset = 1;
			scroller.viewport = dataGroup;
			scroller.skinName = ScrollerSkin;
			addElement(scroller);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w,h);
			graphics.clear();
			drawRoundRect(
				0, 0, w, h, 0,
				borderColors[0], 1,
				verticalGradientMatrix(0, 0, w, h ),
				GradientType.LINEAR, null, 
				{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0}); 
		}
		
	}
}