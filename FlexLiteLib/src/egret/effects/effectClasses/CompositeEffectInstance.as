package egret.effects.effectClasses
{
	
	import egret.core.ns_egret;
	import egret.effects.EffectInstance;
	import egret.effects.IEffectInstance;
	import egret.effects.animation.Animation;
	import egret.effects.animation.MotionPath;
	import egret.effects.animation.SimpleMotionPath;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * CompositeEffectInstance 类用于实现 CompositeEffect 类的实例类
	 */
	public class CompositeEffectInstance extends EffectInstance
	{
		public function CompositeEffectInstance(target:Object)
		{
			super(target);
		}
		
		/**
		 * 正在播放或者等待播放的EffectInstances
		 */
		ns_egret var activeEffectQueue:Array = [];
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function get actualDuration():Number
		{
			var value:Number = NaN;
			if (repeatCount > 0)
			{
				value = durationWithoutRepeat * repeatCount +
					(repeatDelay * (repeatCount - 1)) + startDelay;
			}
			return value;
		}   
		
		private var _playheadTime:Number = 0;
		/**
		 * @inheritDoc
		 */
		override public function get playheadTime():Number
		{
			return _playheadTime;
		}
		
		override public function set playheadTime(value:Number):void
		{
			if (timerAnimation)
				timerAnimation.playheadTime = value;
			else
				_playheadTime = value;
			super.playheadTime = value;
		}

		ns_egret var childSets:Array = [];
		
		ns_egret function get durationWithoutRepeat():Number
		{
			return 0;
		}
		
		ns_egret var endEffectCalled:Boolean;
		
		ns_egret var timerAnimation:Animation;
		
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			timerAnimation = new Animation(animationUpdate);
			timerAnimation.duration = durationWithoutRepeat;
			timerAnimation.motionPaths = new Vector.<MotionPath>([new SimpleMotionPath("timer",0,0)]);
			timerAnimation.endFunction = animationEnd;
			timerAnimation.play();
			super.play();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void
		{   
			super.pause();
			
			if (timerAnimation)
				timerAnimation.pause();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{   
			super.stop();
			
			if (timerAnimation)
				timerAnimation.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function end():void
		{   
			super.end();
			if (timerAnimation)
				timerAnimation.end();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function resume():void
		{
			super.resume();
			
			if (timerAnimation)
				timerAnimation.resume();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reverse():void
		{
			super.reverse();
			super.playReversed = !playReversed;
			if (timerAnimation)
				timerAnimation.reverse();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function finishEffect():void
		{
			activeEffectQueue = null;
			super.finishEffect();
		}
		
		/**
		 * 向此 Composite 效果添加一组新的子效果。
		 * Sequence 效果将按子效果组的添加顺序一次播放一个子效果组。
		 * Parallel 效果将同时播放所有子效果组，而不考虑这些子效果组的添加顺序。
		 */
		public function addChildSet(childSet:Array):void
		{
			if (childSet)
			{
				var n:int = childSet.length;
				if (n > 0)
				{
					if (!childSets)
						childSets = [ childSet ];
					else
						childSets.push(childSet);
					
					for (var i:int = 0; i < n; i++)
					{
						childSet[i].addEventListener(EffectEvent.EFFECT_END,
							effectEndHandler);
						childSet[i].parentCompositeEffectInstance = this;
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function playWithNoDuration():void
		{
			super.playWithNoDuration();
			end();
		}
		
		public function animationUpdate(animation:Animation):void
		{
			_playheadTime = timerAnimation ?
				timerAnimation.playheadTime :
				_playheadTime;
		}
		
		public function animationEnd(animation:Animation):void
		{
			_playheadTime = timerAnimation ?
				timerAnimation.playheadTime :
				_playheadTime;
		}
		
		/**
		 * 在每个子效果完成播放时调用。子类必须实现此函数。
		 */
		protected function onEffectEnd(childEffect:IEffectInstance):void
		{
			
		}
		
		ns_egret function effectEndHandler(event:EffectEvent):void
		{
			onEffectEnd(event.effectInstance);
		}
	}
	
}
