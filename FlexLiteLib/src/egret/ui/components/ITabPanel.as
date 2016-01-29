package egret.ui.components
{
	import egret.components.IDataRenderer;
	import egret.core.IUIComponent;
	import egret.core.IVisualElement;
	
	/**
	 * 选项卡面板的接口
	 */
	public interface ITabPanel extends IDataRenderer , IVisualElement , IUIComponent
	{
		/**
		 * 当前是否显示
		 */
		function get show():Boolean;
		function set show(value:Boolean):void;
		
		/**
		 * 标题
		 */
		function get title():String;
		function set title(value:String):void;
		
		/**
		 * 项呈示器的主机组件的数据提供程序中的项目索引。
		 */		
		function get itemIndex():int;
		function set itemIndex(value:int):void;
		
		/**
		 * 更新数据与视图
		 */
		function updateOwner():void;
	}
}