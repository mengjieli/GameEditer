package egret.ui.components
{
	import flash.events.MouseEvent;
	
	import egret.core.IVisualElement;
	import egret.layouts.HorizontalLayout;
	import egret.ui.core.Cursors;
	import egret.ui.skins.HDividerGroupSkin;

	/**
	 * @author xzper
	 */
	public class HDividerGroup extends DividedGroup
	{
		public function HDividerGroup()
		{
			super();
			this.skinName = HDividerGroupSkin;
			var hLayout : HorizontalLayout = new HorizontalLayout();
			hLayout.gap = 0;
			hLayout.useVirtualLayout = false;
			super.layout = hLayout;
		}

		override protected function get cursorName():String
		{
			return Cursors.DESKTOP_RESIZE_EW;
		}
		
		private var _minElementWidth:int = 0;
		public function get minElementWidth():int
		{
			return _minElementWidth;
		}
		public function set minElementWidth(value:int):void
		{
			_minElementWidth = value;
		}
		
		override protected function layoutDivider(divider:IVisualElement, prev:IVisualElement, next:IVisualElement):void
		{
			divider.x = next.x - horizontalLayout.gap/2;
		}
		
		protected var dividerStartX:Number;
		protected var dragStartX:Number;
		override protected function startDividerDrag(e:MouseEvent):void
		{
			super.startDividerDrag(e);
			dividerStartX = e.currentTarget.x;
			dragStartX = e.stageX;
		}
		
		override protected function dragMove(e:MouseEvent):void
		{
			var offSetX:Number = e.stageX-dragStartX;
			if(activeDivider["prev"].width+offSetX<minElementWidth)
			{
				offSetX = minElementWidth-activeDivider["prev"].width;
			}
			else if(activeDivider["next"].width-offSetX<minElementWidth)
			{
				offSetX = activeDivider["next"].width-minElementWidth;
			}
			dragUI.x = dividerStartX+offSetX;
		}
		
		override protected function applyDrag(e:MouseEvent):void
		{
			var offSetX:Number = dragUI.x - dividerStartX;
			activeDivider["prev"].percentWidth = 100*(activeDivider["prev"].width+offSetX)/contentGroup.width;
			activeDivider["next"].percentWidth = 100*(activeDivider["next"].width-offSetX)/contentGroup.width;
			this.invalidateDisplayList();
		}

		public function get horizontalLayout():HorizontalLayout
		{
			return HorizontalLayout(layout);
		}
	}
}