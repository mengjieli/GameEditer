package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.animation.MotionPath;
	import egret.effects.effectClasses.AnimateTransformInstance;
	
	use namespace ns_egret;
	
	/**
	 * Rotate 效果在 x, y 平面中围绕转换中心旋转目标对象。 
	 */   
	public class Rotate extends AnimateTransform
	{
		public function Rotate(target:Object=null)
		{
			super(target);
			instanceClass = AnimateTransformInstance;
		}
		
		/** 
		 * 目标对象的起始旋转角度
		 */
		public var angleFrom:Number;
		
		/** 
		 * 目标对象的结束旋转角度
		 */
		public var angleTo:Number;
		
		/** 
		 * 旋转目标对象的度数
		 */
		public var angleBy:Number;
		
		override public function createInstance(target:Object = null):IEffectInstance
		{
			motionPaths = new Vector.<MotionPath>();
			return super.createInstance(target);
		}
		
		override protected function initInstance(instance:IEffectInstance):void
		{
			addMotionPath("rotation", angleFrom, angleTo, angleBy);
			super.initInstance(instance);
		}    
	}
}
