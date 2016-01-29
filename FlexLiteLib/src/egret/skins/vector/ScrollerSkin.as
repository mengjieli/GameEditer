package egret.skins.vector
{
	import egret.components.HScrollBar;
	import egret.components.VScrollBar;
	import egret.core.ns_egret;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * 垂直滚动条默认皮肤
	 * @author dom
	 */
	public class ScrollerSkin extends VectorSkin
	{
		public function ScrollerSkin()
		{
			super();
		}
		
		public var horizontalScrollBar:HScrollBar;
		
		public var verticalScrollBar:VScrollBar;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			horizontalScrollBar = new HScrollBar();
			horizontalScrollBar.visible = false;
			horizontalScrollBar.skinName = HScrollBarSkin;
			addElement(horizontalScrollBar);
			
			verticalScrollBar = new VScrollBar();
			verticalScrollBar.visible = false;
			verticalScrollBar.skinName = VScrollBarSkin;
			addElement(verticalScrollBar);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w,h);
		}
		
	}
}