package egret.effects.interpolation
{
	/**
	 * IInterpolator 接口是由为 Animation 类计算值的类实现的。
	 * Animation 类可以处理在 Number 值和 Number 值的数组之间的参量插值，
	 * 但它无法处理不同类型的插值，或在不同类型的值之间的插值。
	 * 此接口的实现者可以提供任意插值功能，这样可以在任意值之间创建 Animation。
	 */
	public interface IInterpolator
	{
		
		/**
		 * 如果有在 0.0 和 1.0 之间的某个动画的已过去部分，以及要插补的开始值和结束值，则返回内插值。
		 * @param fraction 动画的已过去部分，在 0.0 和 1.0 之间。
		 * @param startValue 插值的开始值。
		 * @param endValue 插值的结束值。
		 * @return 内插值。
		 */
		function interpolate(fraction:Number, startValue:Object, endValue:Object):Object;
		
		/**
		 * 如果有一个基值和一个要添加到它的值，则返回该操作的结果。
		 * @param baseValue 插值的开始值。
		 * @param incrementValue  应用到 baseValue 的更改。
		 * @return 内插值。
		 */
		function increment(baseValue:Object, incrementValue:Object):Object;
		
		/**
		 * 如果有一个基值和一个从其减去的值，则返回该减量操作的结果。
		 * @param baseValue 插值的开始值。
		 * @param decrementValue  应用到 baseValue 的更改。
		 * @return  内插值。
		 */
		function decrement(baseValue:Object, decrementValue:Object):Object;
	}
}