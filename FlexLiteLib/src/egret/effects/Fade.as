package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.effectClasses.FadeInstance;
	
	use namespace ns_egret;

	/**
	 * Fade 效果设置组件的 alpha 属性的动画。
	 */
	public class Fade extends Animate
	{
		public function Fade(target:Object=null)
		{
			super(target);
			instanceClass = FadeInstance;
		}
		
		public var alphaFrom:Number;

		public var alphaTo:Number;
		
		override protected function initInstance(instance:IEffectInstance):void
		{
			super.initInstance(instance);
			
			var fadeInstance:FadeInstance = FadeInstance(instance);
			fadeInstance.alphaFrom = alphaFrom;
			fadeInstance.alphaTo = alphaTo;
		}
	}
}