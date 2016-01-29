package egret.ui.components
{
	import egret.core.UIComponent;
	
	
	/**
	 * 
	 * @author dom
	 */
	public class FocusUIComponent extends UIComponent
	{
		public function FocusUIComponent()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			graphics.clear();
			graphics.beginFill(0xFFFFFF,0);
			graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
			graphics.endFill();
		}
	}
}