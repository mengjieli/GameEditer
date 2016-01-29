package egret.core
{
	/**
	 * 具有样式属性功能的组件接口
	 * @author dom
	 */
	public interface IStyleClient
	{
		/**
		 * 获取指定的名称的样式属性值
		 * @param styleProp 样式名称
		 */
		function getStyle(styleProp:String):*;
		/**
		 * 对此组件实例设置样式属性。在此组件上设置的样式会覆盖父级容器的同名样式。
		 * @param styleProp 样式名称
		 * @param newValue 样式值
		 */		
		function setStyle(styleProp:String, newValue:*):void;
		/**
		 * 清除在此组件实例上设置过的指定样式名。
		 * @param styleProp 样式名称
		 */		
		function clearStyle(styleProp:String):void;
		/**
		 * 组件上的样式发生改变
		 * @param styleProp 发生改变的样式名称，若为null表示所有样式都发生了改变。
		 */			
		function styleChanged(styleProp:String):void;
		/**
		 * 通知项列表样式发生改变
		 * @param styleProp 样式名称
		 */		
		function notifyStyleChangeInChildren(styleProp:String):void;
		/**
		 * 重新生成自身以及所有子项的原型链
		 * @param parentChain
		 */		
		function regenerateStyleCache(parentChain:Object):void;
		/**
		 * 样式原型链节点
		 */		
		function get styleProtoChain():Object;
	}
}