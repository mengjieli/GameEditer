package egret.collections
{
	
	/**
	 * 具有排序和过滤功能的集合类数据源对象接口
	 * @author dom
	 */
	public interface ICollectionView extends ICollection
	{
		/**
		 * 对集合中的元素进行排序。若不传入任何参数，则把集合元素作为字符串进行升序排序。
		 * @param compareFunction 一个用来确定集合元素排序顺序的比较函数，示例：compareFunction(a:Object,b:Object):int。结果可以具有负值、0 或正值：<p>
		 * 若返回值为负，则表示 a 在排序后的序列中出现在 b 之前。<br>
		 * 若返回值为 0，则表示 a 和 b 具有相同的排序顺序。<br>
		 * 若返回值为正，则表示 a 在排序后的序列中出现在 b 之后。<br>
		 */
		function sort(compareFunction:Function=null):void;
		/**
		 * @copy Array#sortOn()
		 */		
		function sortOn(fieldName:String,options:*):void;
		/**
		 * 一个回调函数，用于过滤集合中不符合条件的元素。设置此属性后立即开始过滤，如果要取消过滤，把这个属性设置为null。
		 * 示例：filterFunction(item:Object):Boolean。返回false则会从集合中排除该元素。
		 */		
		function get filterFunction():Function;
		function set filterFunction(value:Function):void;
	}
}