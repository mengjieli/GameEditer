package egret.core
{
	
	/**
	 * 工厂接口,工厂类可以通过getInstance()方法不断获取新的实例。
	 * @author dom
	 */
	public interface IFactory
	{
		/**
		 * 获取实例
		 */		
		function getInstance():*;
	}
}