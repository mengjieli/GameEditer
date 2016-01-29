package egret.components.menuClasses
{
	import egret.components.IItemRenderer;

	/**
	 * 菜单项接口
	 */
	public interface IMenuItemRenderer extends IItemRenderer
	{
		/**
		 * 菜单项图标的皮肤名
		 */
		function get iconSkinName():Object;
		function set iconSkinName(value:Object):void;
		
		/**
		 * 指定菜单项的类型。有意义的值为 separator、check 或 radio
		 * Flex 将其他所有值或无类型条目的节点视为常规菜单条目。
		 * 如果使用默认数据描述符，则数据提供程序必须使用类型 XML 属性或对象字段来指定此特征。
		 */
		function get type():String;
		function set type(value:String):void;
		
		/**
		 * 是否含有子菜单
		 */
		function get hasChildren():Boolean;
		function set hasChildren(value:Boolean):void;
		
		/**
		 * 菜单项是否可用
		 */
		function get isEnabled():Boolean;
		function set isEnabled(value:Boolean):void;
		
		/**
		 * 是否已切换节点
		 */
		function get isToggled():Boolean;
		function set isToggled(value:Boolean):void;
	}
}