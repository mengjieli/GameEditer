package egret.effects
{
	import egret.effects.effectClasses.SequenceInstance;

	/**
	 * Sequence 效果以子效果的添加顺序依次播放多个子效果。 
	 */
	public class Sequence extends CompositeEffect
	{
		public function Sequence(target:Object=null)
		{
			super(target);
			instanceClass = SequenceInstance;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get compositeDuration():Number
		{
			var sequenceDuration:Number = 0;
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
				sequenceDuration += childDuration;
			}
			return sequenceDuration;
		}
	}
}