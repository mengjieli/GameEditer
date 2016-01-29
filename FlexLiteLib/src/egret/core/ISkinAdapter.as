package egret.core
{
	import egret.components.SkinnableComponent;

	/**
	 * 皮肤适配器接口。
	 * 若项目需要自定义可设置外观组件的skinName属性的解析规则，需要实现这个接口，
     * 然后调用Injector.mapClass(ISkinAdapter,YourSkinAdapter)注入到框架即可。
	 * @author dom
	 */
	public interface ISkinAdapter
	{
		/**
		 * 获取皮肤显示对象
		 * @param skinName 待解析的皮肤标识符
		 * @param client 主机组件实例
		 * @returns 皮肤对象实例
		 */
		function getSkin(skinName:Object,client:SkinnableComponent):Object;
	}
}