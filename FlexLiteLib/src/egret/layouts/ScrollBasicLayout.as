package egret.layouts
{
	import flash.geom.Rectangle;
	
	import egret.layouts.BasicLayout;
	
	
	/**
	 * 鼠标中键滚动值更大的基本布局
	 * @author dom
	 */
	public class ScrollBasicLayout extends BasicLayout
	{
		/**
		 * 构造函数
		 */		
		public function ScrollBasicLayout()
		{
			super();
		}
		
		override protected function getElementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.left = scrollRect.left - 20;
			bounds.right = scrollRect.left; 
			return bounds;
		} 
		
		override protected function getElementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.left = scrollRect.right;
			bounds.right = scrollRect.right + 20;
			return bounds;
		} 
		
		override protected function getElementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.top = scrollRect.top - 20;
			bounds.bottom = scrollRect.top;
			return bounds;
		} 
		
		override protected function getElementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
		{
			var bounds:Rectangle = new Rectangle();
			bounds.top = scrollRect.bottom;
			bounds.bottom = scrollRect.bottom + 20;
			return bounds;
		}
	}
}