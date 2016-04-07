package flower.tween
{
	
	public interface IPlugin
	{
		/**
		 * @language en_US
		 * Initialization Tween parser.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 初始化 Tween 插件。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		function init(tween:Tween, propertiesTo:Object, propertiesFrom:Object):Vector.<String>;
		
		/**
		 * @language en_US
		 * Renewal Movement content. We need to implement this method in a subclass.
		 * @param value 当前运动的位置。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 更新运动内容。需要在子类中实现该方法。
		 * @param value 当前运动的位置。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		function update(value:Number):void;
	}
}