package egret.ui.components
{
	import egret.core.IVisualElementContainer;

	public interface IPage extends IVisualElementContainer
	{
		/**
		 * 页面名称
		 */
		function get pageName():String;
		
		/**
		 * 页面的数据
		 */
		function set model(value:Object):void;
		
		/**
		 * 执行验证
		 */
		function doValidate():void
	}
}