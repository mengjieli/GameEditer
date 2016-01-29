package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.animation.MotionPath;
	import egret.effects.effectClasses.AnimateTransformInstance;

	use namespace ns_egret;
	
	/**
	 * Move 效果按 x 和 y 方向移动目标对象。
	 * Move 效果的 x 和 y 属性规范指定对于转换中心应该在 x 和 y 上发生的更改，整体转换是围绕转换中心发生的。
	 * 因此，如果设置了 autoCenterTransform 属性，此效果中的 from/to/by 值将定义将目标的中心移动的量，而不是定义目标的 (x,y) 坐标。
	 */   
	public class Move extends AnimateTransform
	{
		public function Move(target:Object=null)
		{
			super(target);
			instanceClass = AnimateTransformInstance;
		}
		
		/** 
		 * 按其修改目标的 y 位置的像素数目。此值可以为负值
		 */
		public var yBy:Number;
		
		/** 
		 * 目标的初始 y 位置
		 */
		public var yFrom:Number;

		/** 
		 * 目标的最终 y 位置
		 */
		public var yTo:Number;
		
		/** 
		 * 按其修改目标的 x 位置的像素数目
		 */
		public var xBy:Number;
		
		/** 
		 * 目标的初始 x 位置
		 */
		public var xFrom:Number;
		
		/** 
		 * 最终 x
		 */
		public var xTo:Number;

		override public function createInstance(target:Object = null):IEffectInstance
		{
			motionPaths = new Vector.<MotionPath>();
			return super.createInstance(target);
		}
		
		override protected function initInstance(instance:IEffectInstance):void
		{
			addMotionPath("translationX", xFrom, xTo, xBy);
			addMotionPath("translationY", yFrom, yTo, yBy);
			super.initInstance(instance);
		}    
	}
}
