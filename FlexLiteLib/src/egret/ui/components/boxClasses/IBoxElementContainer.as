package egret.ui.components.boxClasses
{
	/**
	 * 盒式元素容器接口
	 */
	public interface IBoxElementContainer extends IBoxElement
	{
		/**
		 * 第一个子元素
		 */
		function get firstElement():IBoxElement;
		function set firstElement(value:IBoxElement):void;
		/**
		 * 第二个子元素
		 */
		function get secondElement():IBoxElement;
		function set secondElement(value:IBoxElement):void;
	}
}