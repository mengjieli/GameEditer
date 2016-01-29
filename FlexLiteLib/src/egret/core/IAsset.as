package egret.core
{
	
	/**
	 * 
	 * @author dom
	 */
	public interface IAsset extends IInvalidating
	{
		/**
		 * 素材标识符。可以为Class,String,或DisplayObject实例等任意类型，具体规则由项目注入的素材适配器决定，
		 * 适配器根据此属性值解析获取对应的显示对象，并赋值给content属性。
		 */	
		function get source():Object;
		function set source(value:Object):void;
		/**
		 * 屏幕缩放参数，默认是1。当设置为支持retina屏时为2。
		 */		
		function get contentsScaleFactor():Number;
	}
}