package egret.components
{
	
	/**
	 * IDataRenderer 接口用于为具有 data 属性的组件定义接口。 
	 * @author dom
	 */
	public interface IDataRenderer
	{
		/**
		 * 要呈示或编辑的数据。
		 */	
		function get data():Object;
		function set data(value:Object):void;
	}
}