package egret.ui.components
{
	import flash.events.IEventDispatcher;
	
	import egret.components.IDataRenderer;
	
	/**
	 * 文档数据
	 */
	public interface IDocumentData extends IEventDispatcher , IDataRenderer
	{
		/**
		 * 文档对应的class
		 */
		function get clazz():Class;
		
		/**
		 * 文档的路径
		 */
		function get path():String;
		
		/**
		 * 持有数据的对象,通常是对应DocTabGroup
		 */
		function get owner():Object;
		function set owner(value:Object):void;
	}
}