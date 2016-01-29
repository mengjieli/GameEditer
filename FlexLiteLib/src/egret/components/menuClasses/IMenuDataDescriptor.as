package egret.components.menuClasses
{
	import egret.collections.ICollection;

	/**
	 * IMenuDataDescriptor 接口定义 Menu 或 MenuBar 控件的 dataDescriptor 必须实现的接口。
	 * 此接口提供了分析和修改通过 Menu 或 MenuBar 控件显示的数据集合的方法。
	 */
	public interface IMenuDataDescriptor
	{
		/**
		 * 提供对节点子项的访问。如果存在，则返回节点子项的集合。
		 * 如果节点是 Object，此方法会将该对象 children 字段的内容作为 ObjectCollection 返回。
		 * 如果节点是 XML，此方法将返回包含子元素的 XMLCollection。
		 */
		function getChildren(node:Object):ICollection;

		/**
		 * 确定节点实际是否有子节点。
		 */
		function hasChildren(node:Object):Boolean;
		
		/**
		 * 返回节点的类型标识符。基于菜单的控件使用此方法确定节点是否提供分隔符、单选按钮、复选框或常规项目。
		 */
		function getType(node:Object):String;

		/**
		 * 返回是否已启用节点。
		 */
		function isEnabled(node:Object):Boolean;
		
		/**
		 * 	设置数据提供程序中用于标识是否已启用节点的字段或属性的值。
		 * 此方法设置节点的 enabled 属性或字段的值。基于菜单的控件使用此方法。
		 */
		function setEnabled(node:Object, value:Boolean):void;
	
		/**
		 * 返回是否已切换节点。
		 */
		function isToggled(node:Object):Boolean;

		/**
		 * 设置数据提供程序中用于标识是否已切换节点的字段或属性的值。此方法设置节点的 toggled 属性或字段的值。
		 */
		function setToggled(node:Object, value:Boolean):void;

		/**
		 * 返回节点所属的单选按钮组的名称（如果存在）。
		 */
		function getGroupName(node:Object):String;
	}
}