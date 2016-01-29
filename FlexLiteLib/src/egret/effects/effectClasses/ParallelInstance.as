package egret.effects.effectClasses
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import egret.core.ns_egret;
	import egret.effects.EffectInstance;
	import egret.effects.IEffectInstance;
	import egret.effects.Parallel;
	
	use namespace ns_egret;
	
	/**
	 * ParallelInstance 类用于实现 Parallel 效果的实例类
	 */  
	public class ParallelInstance extends CompositeEffectInstance
	{
		
		public function ParallelInstance(target:Object)
		{
			super(target);
		}

		/**
		 * 已经完成的效果实例
		 */
		private var doneEffectQueue:Array;
		
		/**
		 * 等待播放的效果实例
		 */
		private var replayEffectQueue:Array;
		
		private var isReversed:Boolean = false;	
		private var timer:Timer;
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function get durationWithoutRepeat():Number
		{
			var _duration:Number = 0;
			
			var n:int = childSets.length;
			for (var i:int = 0; i < n; i++)
			{
				var instances:Array = childSets[i];
				_duration = Math.max(instances[0].actualDuration, _duration);
			}
			return _duration;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set playheadTime(value:Number):void
		{        
			super.playheadTime = value;
			
			var compositeDur:Number = Parallel(effect).compositeDuration;
			var firstCycleDur:Number = compositeDur + startDelay + repeatDelay;
			var laterCycleDur:Number = compositeDur + repeatDelay;
			var totalDur:Number = firstCycleDur + laterCycleDur * (repeatCount - 1);
			var childPlayheadTime:Number;
			if (value <= firstCycleDur) {
				childPlayheadTime = Math.min(value - startDelay, compositeDur);
				playCount = 1;
			}
			else
			{
				if (value >= totalDur && repeatCount != 0)
				{
					childPlayheadTime = compositeDur;
					playCount = repeatCount;
				}
				else
				{
					var valueAfterFirstCycle:Number = value - firstCycleDur;
					childPlayheadTime = valueAfterFirstCycle % laterCycleDur;
					playCount = 1 + valueAfterFirstCycle / laterCycleDur;
				}
			}
			
			for (var i:int = 0; i < childSets.length; i++)
			{
				var instances:Array = childSets[i];            
				var m:int = instances.length;
				for (var j:int = 0; j < m; j++)
					instances[j].playheadTime = playReversed ?
						Math.max(0, (childPlayheadTime - 
							(durationWithoutRepeat - instances[j].actualDuration))) :
						childPlayheadTime;
			}

			if (playReversed && replayEffectQueue != null && replayEffectQueue.length > 0)
			{
				var position:Number = durationWithoutRepeat - playheadTime;
				var numDone:int = replayEffectQueue.length;	        
				for (i = numDone - 1; i >= 0; i--)
				{
					var childEffect:EffectInstance = replayEffectQueue[i];
					if (position <= childEffect.actualDuration)
					{
						if (activeEffectQueue == null)
							activeEffectQueue = [];
						activeEffectQueue.push(childEffect);
						replayEffectQueue.splice(i,1);
						
						childEffect.playReversed = playReversed;
						childEffect.startEffect();
					}
				}
			}
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			doneEffectQueue = [];
			activeEffectQueue = [];
			replayEffectQueue = [];

			super.play();
			
			var n:int;
			var i:int;
			
			n = childSets.length;
			for (i = 0; i < n; i++)
			{
				var instances:Array = childSets[i];
				
				var m:int = instances.length;
				for (var j:int = 0; j < m && activeEffectQueue != null; j++)
				{
					var childEffect:EffectInstance = instances[j];

					if (playReversed && childEffect.actualDuration < durationWithoutRepeat)
					{
						replayEffectQueue.push(childEffect);
						startTimer();
					}
					else
					{
						childEffect.playReversed = playReversed;
						activeEffectQueue.push(childEffect);
					}
				}		
			}
			
			if (activeEffectQueue.length > 0)
			{
				var queueCopy:Array = activeEffectQueue.slice(0);
				for (i = 0; i < queueCopy.length; i++)
				{
					queueCopy[i].startEffect();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void
		{	
			super.pause();
			if (activeEffectQueue)
			{
				var n:int = activeEffectQueue.length;
				for (var i:int = 0; i < n; i++)
				{
					activeEffectQueue[i].pause();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			stopTimer();
			
			if (activeEffectQueue)
			{
				var queueCopy:Array = activeEffectQueue.concat();
				activeEffectQueue = null;
				var n:int = queueCopy.length;
				for (var i:int = 0; i < n; i++)
				{
					if (queueCopy[i])
						queueCopy[i].stop();
				}
			}
			super.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function resume():void
		{
			super.resume();
			if (activeEffectQueue)
			{
				var n:int = activeEffectQueue.length;
				for (var i:int = 0; i < n; i++)
				{
					activeEffectQueue[i].resume();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reverse():void
		{
			super.reverse();
			
			var n:int;
			var i:int;
			
			if (isReversed)
			{
				n = activeEffectQueue.length;
				for (i = 0; i < n; i++)
				{
					activeEffectQueue[i].reverse();
				} 
				
				stopTimer();
			}
			else
			{
				replayEffectQueue = doneEffectQueue.splice(0);
				n = activeEffectQueue.length;
				for (i = 0; i < n; i++)
				{
					activeEffectQueue[i].reverse();
				} 
				
				startTimer();
			}
			
			isReversed = !isReversed;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function end():void
		{
			endEffectCalled = true;
			stopTimer();
			
			if (activeEffectQueue)
			{
				var queueCopy:Array = activeEffectQueue.concat();
				activeEffectQueue = null;
				var n:int = queueCopy.length;
				for (var i:int = 0; i < n; i++)
				{
					if (queueCopy[i])
						queueCopy[i].end();
				}
			}
			
			super.end();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onEffectEnd(childEffect:IEffectInstance):void
		{
			if (endEffectCalled || activeEffectQueue == null)
				return;
			
			var n:int = activeEffectQueue.length;	
			for (var i:int = 0; i < n; i++)
			{
				if (childEffect == activeEffectQueue[i])
				{
					doneEffectQueue.push(childEffect);
					activeEffectQueue.splice(i, 1);
					break;
				}
			}	
			
			if (n == 1)
			{
				finishRepeat();
			}
		}
		
		private function startTimer():void
		{
			if (!timer)
			{
				timer = new Timer(10);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
			}
			timer.start();
		}

		private function stopTimer():void
		{
			if (timer)
				timer.reset();
		}

		private function timerHandler(event:TimerEvent):void
		{
			var position:Number = durationWithoutRepeat - playheadTime;
			var numDone:int = replayEffectQueue.length;	
			
			if (numDone == 0)
			{
				stopTimer();
				return;
			}
			
			for (var i:int = numDone - 1; i >= 0; i--)
			{
				var childEffect:EffectInstance = replayEffectQueue[i];
				
				if (position <= childEffect.actualDuration)
				{
					if (activeEffectQueue == null)
						activeEffectQueue = [];
					activeEffectQueue.push(childEffect);
					replayEffectQueue.splice(i,1);
					
					childEffect.playReversed =playReversed;
					childEffect.startEffect();
				} 
			}
		}
	}
}
