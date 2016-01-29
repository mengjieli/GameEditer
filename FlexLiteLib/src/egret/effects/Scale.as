package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.animation.MotionPath;
	import egret.effects.effectClasses.AnimateTransformInstance;
	
	use namespace ns_egret;
	
	/**
	 * Scale 效果围绕转换中心在 x 和 y 方向上缩放目标对象。
	 */
	public class Scale extends AnimateTransform
	{
		public function Scale(target:Object=null)
		{
			super(target);
			instanceClass = AnimateTransformInstance;
		}
		
		/**
		 * 在 y 方向上的起始比例因子。比例值为 0.0 时无效。
		 */
		public var scaleYFrom:Number;

		/**
		 * 在 y 方向上的结束比例因子。比例值为 0.0 时无效。
		 */
		public var scaleYTo:Number;

		/**
		 * 在 y 方向上按其缩放对象的因子。
		 */
		public var scaleYBy:Number;
		
		/**
		 * 在 x 方向上的起始比例因子。比例值为 0.0 时无效。
		 */
		public var scaleXFrom:Number;

		/**
		 * 在 x 方向上的结束比例因子。比例值为 0.0 时无效。
		 */
		public var scaleXTo:Number;

		/**
		 * 在 x 方向上按其缩放对象的因子。
		 */
		public var scaleXBy:Number;
		
		override public function createInstance(target:Object = null):IEffectInstance
		{
			motionPaths = new Vector.<MotionPath>();
			return super.createInstance(target);
		}

		override protected function initInstance(instance:IEffectInstance):void
		{
			addMotionPath("scaleX", scaleXFrom, scaleXTo, scaleXBy);
			addMotionPath("scaleY", scaleYFrom, scaleYTo, scaleYBy);
			super.initInstance(instance);
		}    
	}
}
