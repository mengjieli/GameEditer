package egret.core
{
	
	/**
	 * 工具提示组件接口
	 * @author dom
	 */
	public interface IToolTip extends IUIComponent
	{
		/**
		 * 工具提示的数据对象，通常为一个字符串。
		 */		
		function get toolTipData():Object;
		
		function set toolTipData(value:Object):void;
	}
}