package egret.effects.effectClasses
{
	import egret.core.ns_egret;
	import egret.effects.animation.Keyframe;
	import egret.effects.animation.MotionPath;

	use namespace ns_egret;

	/**
	 * FadeInstance 类用于实现 Fade 效果的实例类。
	 */
	public class FadeInstance extends AnimateInstance
	{
		public function FadeInstance(target:Object)
		{
			super(target);
		}
		
		/**
		 * 介于 0.0 和 1.0 之间的 alpha 属性的初始值
		 */
		public var alphaFrom:Number;
		
		/**
		 * 介于 0.0 和 1.0 之间的 alpha 属性的最终值
		 */
		public var alphaTo:Number;
		
		override public function play():void
		{
			var fromValue:Number = alphaFrom;
			var toValue:Number = alphaTo;

			if ("visible" in target && !target.visible)
			{
				if (isNaN(fromValue))
					fromValue = target.alpha;
				if (isNaN(toValue))
					toValue = target.alpha;
				if (fromValue == 0 && toValue != 0)
				{
					target.alpha = 0;
					target.visible = true;
				}
			}
			
			motionPaths = new <MotionPath>[new MotionPath("alpha")];
			motionPaths[0].keyframes = new <Keyframe>[new Keyframe(0, alphaFrom), 
				new Keyframe(duration, alphaTo)];
			
			super.play();
		}
	}
}