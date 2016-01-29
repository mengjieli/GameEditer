package egret.effects.animation
{
	import egret.core.ns_egret;
	import egret.effects.interpolation.IInterpolator;
	import egret.effects.interpolation.NumberInterpolator;
	
	use namespace ns_egret;

	/**
	 * MotionPath 类定义效果的 Keyframe 对象的集合，以及要设置动画的目标上属性的名称。
	 * 每个 Keyframe 对象都定义位于效果过程中某个特定时间的属性的值。
	 * 这样，效果就可以通过在两个关键帧所指定的值之间进行插补来计算目标属性的值。
	 * @author xzper
	 */
	public class MotionPath
	{
		
		/**
		 * 构造函数
		 * @param property 要设置动画的目标上属性的名称。
		 */
		public function MotionPath(property:String = null)
		{
			this.property = property;
		}
		
		/**
		 * 要设置动画的效果目标上属性的名称。
		 */
		public var property:String;

		public var interpolator:IInterpolator = NumberInterpolator.getInstance();
		
		/**
		 * 表示属性在动画过程中所采用的时间/值对的 Keyframe 对象序列。
		 */
		public var keyframes:Vector.<Keyframe>;
		
		
		/**
		 * 返回此 MotionPath 对象的副本（包含每个关键帧的副本）。
		 */
		public function clone():MotionPath
		{
			var mp:MotionPath = new MotionPath(property);
			mp.interpolator = interpolator;
			if (keyframes !== null)
			{
				mp.keyframes = new Vector.<Keyframe>();
				for (var i:int = 0; i < keyframes.length; ++i)
					mp.keyframes[i] = keyframes[i].clone();
			}
			return mp;
		}
		
		/**
		 * 计算每一个关键帧的timeFraction值
		 */
		ns_egret function scaleKeyframes(duration:Number):void
		{
			var n:int = keyframes.length;
			for (var i:int; i < n; ++i)
			{
				var kf:Keyframe = keyframes[i];
				kf.timeFraction = kf.time / duration;
			}
		}
		
		/**
		 * 给定已过去时间部分的情况下，计算并返回一个内插值。
		 * 该函数决定该部分所处于的关键帧时间间隔，
		 * 然后在该时间间隔内插补该时间间隔的定界关键帧值之间的值。
		 * @param fraction 效果的总体持续时间部分（从 0.0 到 1.0 之间的值）。
		 * @return 内插值
		 */
		public function getValue(fraction:Number):Object
		{
			if (!keyframes)
				return null;
			var n:int = keyframes.length;
			if (n == 2 && keyframes[1].timeFraction == 1)
			{
				var easedF:Number = (keyframes[1].easer!=null) ? 
					keyframes[1].easer.ease(fraction) : 
					fraction;
				return interpolator.interpolate(easedF, keyframes[0].value,
					keyframes[1].value);
			}
			if (isNaN(keyframes[0].timeFraction))
				scaleKeyframes(keyframes[keyframes.length-1].time);
			var prevT:Number = 0;
			var prevValue:Object = keyframes[0].value;
			for (var i:int = 1; i < n; ++i)
			{
				var kf:Keyframe = keyframes[i];
				if (fraction >= prevT && fraction < kf.timeFraction)
				{
					var t:Number = (fraction - prevT) / (kf.timeFraction - prevT);
					var easedT:Number = (kf.easer!=null) ? kf.easer.ease(t) : t;
					return interpolator.interpolate(easedT, prevValue, kf.value);
				}
				prevT = kf.timeFraction;
				prevValue = kf.value;
			}
			return keyframes[n-1].value;
		}
	}
}