package egret.effects.animation
{
	/**
	 * SimpleMotionPath 类指定属性名称以及该属性随时间变化而采用的值，例如 Animate 效果。
	 */
	public class SimpleMotionPath extends MotionPath
	{
		
		/**
		 * 构造函数。您可以同时指定 valueFrom 和 valueTo 参数，
		 * 也可以在指定 valueBy 参数的同时指定 valueFrom 或 valueTo 参数。
		 * 如果忽略这些参数，则会从效果目标计算它们。
		 *  @param property 正在设置动画的属性的名称。
		 *  @param valueFrom 属性的初始值。
		 *  @param valueTo 属性的最终值。
		 *  @param valueBy 用于指定 delta 的可选参数，该 delta 用于计算 from 或 to 值（如果其中一个值被忽略）。
		 */    
		public function SimpleMotionPath(property:String = null, 
										 valueFrom:Object = null, valueTo:Object = null, 
										 valueBy:Object = null)
		{
			super();
			this.property = property;
			keyframes = new <Keyframe>[new Keyframe(0, valueFrom), 
				new Keyframe(NaN, valueTo, valueBy)];
		}
		
		/**
		 * 动画过程中属性的起始值。 
		 */
		public function get valueFrom():Object
		{
			return keyframes[0].value;
		}
		public function set valueFrom(value:Object):void
		{
			keyframes[0].value = value;
		}
		
		/**
		 * 已命名的属性将要设置动画的值。 
		 */
		public function get valueTo():Object
		{
			return keyframes[keyframes.length -1].value;
		}
		public function set valueTo(value:Object):void
		{
			keyframes[keyframes.length - 1].value = value;
		}
		
		/**
		 * 可指定用于计算 valueFrom 或 valueTo 值的 delta 的可选属性。
		 */
		public function get valueBy():Object
		{
			return keyframes[keyframes.length - 1].valueBy;
		}
		public function set valueBy(value:Object):void
		{
			keyframes[keyframes.length - 1].valueBy = value;
		}
	}
}