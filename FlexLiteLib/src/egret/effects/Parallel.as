package egret.effects
{
	import egret.effects.effectClasses.ParallelInstance;
	
	/**
	 * Parallel 效果同时播放多个子效果。 
	 */
	public class Parallel extends CompositeEffect
	{
		public function Parallel(target:Object = null)
		{
			super(target);
			instanceClass = ParallelInstance;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get compositeDuration():Number
		{
			var parallelDuration:Number = 0;
			for (var i:int = 0; i < children.length; ++i)
			{
				var childDuration:Number;
				var child:Effect = Effect(children[i]);
				if (child is CompositeEffect)
					childDuration = CompositeEffect(child).compositeDuration;
				else
					childDuration = child.duration;
				childDuration = 
					childDuration * child.repeatCount +
					(child.repeatDelay * (child.repeatCount - 1)) +
					child.startDelay;
				parallelDuration = Math.max(parallelDuration, childDuration);
			}
			return parallelDuration;
		}
	}
}
