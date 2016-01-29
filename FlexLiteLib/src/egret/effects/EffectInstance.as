package egret.effects
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import avmplus.getQualifiedClassName;
	
	import egret.core.ns_egret;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * EffectInstance 类代表在目标上播放的效果实例。每个目标都有与之相关联的单独效果实例。
	 * 效果实例的生存期是短暂的。
	 * 在目标上播放效果时会创建一个实例，当效果完成播放时将破坏此实例。
	 * 如果目标上同时播放了多个效果（例如，Parallel 效果），则每个效果都有其单独的效果实例。 
	 */
	public class EffectInstance extends EventDispatcher implements IEffectInstance
	{
		
		public function EffectInstance(target:Object)
		{
			super();
			this.target = target;
		}
		
		/**
		 *  startDelay和repeatDelay的计时器
		 */
		ns_egret var delayTimer:Timer;
		
		/**
		 * delayTimer开始的时间
		 */
		private var delayStartTime:Number = 0;
		
		/**
		 * 暂停时delayTimer经过的时间
		 */
		private var delayElapsedTime:Number = 0;
		
		/**
		 * 是否显式设置了持续时间
		 */
		ns_egret var durationExplicitlySet:Boolean = false;
		
		/**
		 * 实例对应效果的复杂效果的实例，如果不是复杂效果则为null
		 */
		ns_egret var parentCompositeEffectInstance:EffectInstance;
		
		/** 
		 * 已播放实例的次数。
		 */
		protected var playCount:int = 0;
		
		/**
		 * 调用end()方法结束时，防止效果重复的的标志
		 */
		ns_egret var stopRepeat:Boolean = false;
		
		/**
		 * 实际的持续时间包含startDelay，repeatDelay，repeatCount这些值
		 */
		ns_egret function get actualDuration():Number 
		{
			var value:Number = NaN;
			
			if (repeatCount > 0)
			{
				value = duration * repeatCount +
					(repeatDelay * (repeatCount - 1)) + startDelay;
			}
			return value;
		}
		
		private var _duration:Number = 500;
		/**
		 * @inheritDoc
		 */
		public function get duration():Number
		{
			if (!durationExplicitlySet &&
				parentCompositeEffectInstance)
			{
				return parentCompositeEffectInstance.duration;
			}
			else
			{
				return _duration;
			}
		}
		
		public function set duration(value:Number):void
		{
			durationExplicitlySet = true;
			_duration = value;
		}
		
		private var _effect:IEffect;
		/**
		 * @inheritDoc
		 */
		public function get effect():IEffect
		{
			return _effect;
		}
		
		public function set effect(value:IEffect):void
		{
			_effect = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get playheadTime():Number 
		{
			return Math.max(playCount - 1, 0) * (duration + repeatDelay) +
				(playReversed ? 0 : startDelay);
		}
		
		public function set playheadTime(value:Number):void
		{
			if (delayTimer && delayTimer.running)
			{
				delayTimer.reset();
				if (value < startDelay)
				{
					delayTimer = new Timer(startDelay - value, 1);
					delayStartTime = getTimer();
					delayTimer.addEventListener(TimerEvent.TIMER, delayTimerHandler);
					delayTimer.start();
				}
				else
				{
					playCount = 0;
					play();
				}
			}
		}
		
		private var _playReversed:Boolean;
		/**
		 * 内部指定效果是否在反向播放，在播放之前设置此属性
		 */
		ns_egret function get playReversed():Boolean
		{
			return _playReversed;
		}
		
		ns_egret function set playReversed(value:Boolean):void 
		{
			_playReversed = value;
		}
		
		private var _repeatCount:int = 0;
		/**
		 * @inheritDoc
		 */
		public function get repeatCount():int
		{
			return _repeatCount;
		}

		public function set repeatCount(value:int):void
		{
			_repeatCount = value;
		}
		
		private var _repeatDelay:int = 0;
		/**
		 * @inheritDoc
		 */
		public function get repeatDelay():int
		{
			return _repeatDelay;
		}
		
		public function set repeatDelay(value:int):void
		{
			_repeatDelay = value;
		}
		
		private var _startDelay:int = 0;
		/**
		 * @inheritDoc
		 */
		public function get startDelay():int
		{
			return _startDelay;
		}
		
		public function set startDelay(value:int):void
		{
			_startDelay = value;
		}
		
		private var _target:Object;
		/**
		 * @inheritDoc
		 */
		public function get target():Object
		{
			return _target;
		}
		
		public function set target(value:Object):void
		{
			_target = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function startEffect():void
		{   
			if (startDelay > 0 && !playReversed)
			{
				delayTimer = new Timer(startDelay, 1);
				delayStartTime = getTimer();
				delayTimer.addEventListener(TimerEvent.TIMER, delayTimerHandler);
				delayTimer.start();
			}
			else
			{
				play();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function play():void
		{
			playCount++;
			dispatchEvent(new EffectEvent(EffectEvent.EFFECT_START, false, false, this));
			if (target && (target is IEventDispatcher))
			{
				target.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_START, false, false, this));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function pause():void
		{   
			if (delayTimer && delayTimer.running && !isNaN(delayStartTime))
			{
				delayTimer.stop();
				delayElapsedTime = getTimer() - delayStartTime;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{   
			if (delayTimer)
				delayTimer.reset();
			stopRepeat = true;
			dispatchEvent(new EffectEvent(EffectEvent.EFFECT_STOP, false, false, this));        
			if (target && (target is IEventDispatcher))
				target.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_STOP, false, false, this));
			finishEffect();
		}
		
		/**
		 * @inheritDoc
		 */
		public function resume():void
		{
			if (delayTimer && !delayTimer.running && !isNaN(delayElapsedTime))
			{
				delayTimer.delay = !playReversed ? delayTimer.delay - delayElapsedTime : delayElapsedTime;
				delayStartTime = getTimer();
				delayTimer.start();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function reverse():void
		{
			if (repeatCount > 0)
				playCount = repeatCount - playCount + 1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function end():void
		{
			if (delayTimer)
				delayTimer.reset();
			stopRepeat = true;
			finishEffect();
		}
		
		/**
		 * @inheritDoc
		 */
		public function finishEffect():void
		{
			playCount = 0;
			dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END, false, false, this));
			if (target && (target is IEventDispatcher))
			{
				target.dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END,false, false, this));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function finishRepeat():void
		{
			if (!stopRepeat && playCount != 0 &&
				(playCount < repeatCount || repeatCount == 0))
			{
				if (repeatDelay > 0)
				{
					delayTimer = new Timer(repeatDelay, 1);
					delayStartTime = getTimer();
					delayTimer.addEventListener(TimerEvent.TIMER,
						delayTimerHandler);
					delayTimer.start();
				}
				else
				{
					play();
				}
			}
			else
			{
				finishEffect();
			}
		}
		
		ns_egret function playWithNoDuration():void
		{
			duration = 0;
			repeatCount = 1;
			repeatDelay = 0;
			startDelay = 0;
			startEffect();
		}
		
		private function delayTimerHandler(event:TimerEvent):void
		{
			delayTimer.reset();
			delayStartTime = NaN;
			delayElapsedTime = NaN;
			play();
		}
	}
	
}
