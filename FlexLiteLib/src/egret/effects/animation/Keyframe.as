package egret.effects.animation
{
	import egret.core.ns_egret;
	import egret.effects.easing.IEaser;
	import egret.effects.easing.Linear;
	
	use namespace ns_egret;

	/**
	 * Keyframe 类用于定义位于效果过程中某个特定时间的属性的值。
	 * 例如，您可以创建三个关键帧，分别定义位于效果的开始处、中点和结束处的属性的值。
	 * 效果会在其持续时间内逐个关键帧设置目标上的属性更改的动画。
	 * <p>
	 * 效果的关键帧的集合称为效果的运动路径。
	 * 运动路径可以定义任何数量的关键帧。
	 * 这样效果就可以通过在两个关键帧所指定的值之间进行插补来计算属性的值。 
	 * </p>
	 * <p>
	 * 使用 MotionPath 类容纳 Keyframe 对象的集合，这些对象用于表示效果的运动路径。
	 * MotionPath 类指定目标上的属性的名称，Keyframe 对象的集合指定效果过程中不同时间的属性的值。
	 * </p>
	 */
	public class Keyframe
	{
		/**
		 * 构造函数
		 * @param time 以毫秒为单位的时间，此关键帧的效果目标应该在此时间处具有 value 参数指定的值。
		 * @param value 效果目标在给定的 time 处应该具有的值。
		 * @param valueBy 可选参数，如果提供该可选参数，
		 * 则可以通过将 valueBy 与 MotionPath 对象的关键帧集合中的前一个关键帧的 value 相加来动态地计算 value。
		 * 如果是序列中的第一个 Keyframe，则会忽略此值
		 * 
		 */
		public function Keyframe(time:Number = NaN, 
								 value:Object = null, valueBy:Object = null)
		{
			this.value = value;
			this.time = time;
			this.valueBy = valueBy;
		}
		
		/**
		 * 返回此 Keyframe 对象的副本。
		 */
		public function clone():Keyframe
		{
			var kf:Keyframe = new Keyframe(time, value, valueBy);
			kf.easer = easer;
			kf.timeFraction = timeFraction;
			return kf;
		}
		
		/**
		 * 效果目标的属性在 time 属性指定的时间处所应该具有的值。
		 */
		public var value:Object;
		
		/**
		 * 以毫秒为单位的时间，此关键帧的效果目标应该在此时间处具有 value 属性指定的值。
		 * 此时间与用此关键帧定义的效果的起始时间相关。
		 */
		public var time:Number;
		
		ns_egret var timeFraction:Number;
		
		private static var linearEaser:IEaser = new Linear();
		
		/**
		 * 对运动路径中前一个 Keyframe 对象与此 Keyframe 对象之间的运动所应用的缓动行为。
		 * 默认情况下，缓动是线性的，或者根本就没有缓动。 
		 */
		public var easer:IEaser = linearEaser;
		
		/**
		 * 用于计算此关键帧或前一个关键帧中的 value 的可选参数（如果已指定）。
		 * 如果在前一个关键帧中未设置 value，但此关键帧中同时定义了 value 和 valueBy，
		 * 则前一个关键帧中的 value 可以通过以此关键帧中的 value 减去此关键帧中的 valueBy 来计算。
		 */
		public var valueBy:Object;
	}
}