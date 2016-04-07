package view.dataView
{
	import flash.events.MouseEvent;
	
	import egret.components.supportClasses.ItemRenderer;

	public class ViewDataItem extends ItemRenderer
	{
		public function ViewDataItem()
		{
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			this.toolTip = value.toolTip;
		}
	}
}