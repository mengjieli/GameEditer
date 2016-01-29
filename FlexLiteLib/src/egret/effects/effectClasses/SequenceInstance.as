package egret.effects.effectClasses
{
	import egret.core.ns_egret;
	import egret.effects.EffectInstance;
	import egret.effects.IEffectInstance;
	import egret.effects.Sequence;
	
	use namespace ns_egret;
	
	/**
	 * SequenceInstance 类用于实现 Sequence 效果的实例类
	 */  
	public class SequenceInstance extends CompositeEffectInstance
	{

		public function SequenceInstance(target:Object)
		{
			super(target);
		}

		/**
		 * 已播放效果的持续时间
		 */
		private var currentInstanceDuration:Number = 0; 
		
		/**
		 * 当前播放的效果实例
		 */
		private var currentSet:Array;
		private var currentSetIndex:int = -1;
		
		private var isPaused:Boolean = false;
		
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
				_duration += instances[0].actualDuration;
			}
			
			return _duration;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set playheadTime(value:Number):void
		{
			super.playheadTime = value;

			var i:int, j:int, k:int, l:int;
			var compositeDur:Number = Sequence(effect).compositeDuration;
			var firstCycleDur:Number = compositeDur + startDelay + repeatDelay;
			var laterCycleDur:Number = compositeDur + repeatDelay;
			var totalDur:Number = firstCycleDur + laterCycleDur * (repeatCount - 1);
			var iterationPlayheadTime:Number;
			if (value <= firstCycleDur)
			{
				iterationPlayheadTime = Math.min(value - startDelay, compositeDur);
				playCount = 1;
			}
			else
			{
				if (value >= totalDur && repeatCount != 0)
				{
					iterationPlayheadTime = compositeDur;
					playCount = repeatCount;
				}
				else
				{
					var valueAfterFirstCycle:Number = value - firstCycleDur;
					iterationPlayheadTime = valueAfterFirstCycle % laterCycleDur;
					iterationPlayheadTime = Math.min(iterationPlayheadTime, compositeDur);
					playCount = 1 + valueAfterFirstCycle / laterCycleDur;
				}
			}
			
			if (activeEffectQueue && activeEffectQueue.length  > 0)
			{
				var cumulativeDuration:Number = 0;
				
				var activeLength:Number = activeEffectQueue.length;
				for (i = 0; i < activeLength; ++i)
				{
					var setToCompare:int = playReversed ? (activeLength - 1 - i) : i;
					var childEffectInstances:Array;
					var startTime:Number = cumulativeDuration;
					var endTime:Number = cumulativeDuration + childSets[setToCompare][0].actualDuration;
					cumulativeDuration = endTime;
					
					if (startTime <= iterationPlayheadTime && iterationPlayheadTime <= endTime)
					{
						endEffectCalled = true;
						
						if (currentSetIndex == setToCompare)
						{
							for (j = 0; j < currentSet.length; j++)
								currentSet[j].playheadTime = (iterationPlayheadTime - startTime);
						}
						else if (setToCompare < currentSetIndex)
						{
							if (playReversed)
							{
								for (j = 0; j < currentSet.length; j++)
									currentSet[j].end();

								for (j = currentSetIndex - 1; j > setToCompare; --j)
								{
									childEffectInstances = activeEffectQueue[j];
									for (k = 0; k < childEffectInstances.length; k++)
									{
										if (playReversed)
											childEffectInstances[k].playReversed = true;
										childEffectInstances[k].play();
										childEffectInstances[k].end();
									}
								}
							}
							else
							{
								for (j = 0; j < currentSet.length; j++)
								{
									currentSet[j].playheadTime = 0;
									currentSet[j].stop();
								}

								for (j = currentSetIndex - 1; j > setToCompare; --j)
								{
									childEffectInstances = activeEffectQueue[j];
									for (k = 0; k < childEffectInstances.length; k++)
									{
										childEffectInstances[k].play();
										childEffectInstances[k].stop();
									}
								}
							}
							currentSetIndex = setToCompare;
							playCurrentChildSet();
							for (k = 0; k < currentSet.length; k++)
							{
								currentSet[k].playheadTime = (iterationPlayheadTime - startTime);
								if (isPaused)
									currentSet[k].pause();
							}
						}
						else
						{
							if (playReversed)
							{
								for (j = 0; j < currentSet.length; j++)
								{
									currentSet[j].playheadTime = 0;
									currentSet[j].stop();
								}
								
								for (k = currentSetIndex + 1; k < setToCompare; k++)
								{
									childEffectInstances = activeEffectQueue[k];                          
									for (l = 0; l < childEffectInstances.length; l++)
									{
										childEffectInstances[l].playheadTime = 0;
										childEffectInstances[l].stop();
									}
								}                            
							}
							else
							{
								var currentEffectInstances:Array = currentSet.concat();
								for (j = 0; j < currentEffectInstances.length; j++)
									currentEffectInstances[j].end();
								
								for (k = currentSetIndex + 1; k < setToCompare; k++)
								{
									childEffectInstances = activeEffectQueue[k];                          
									for (l = 0; l < childEffectInstances.length; l++)
									{
										childEffectInstances[l].play();
										childEffectInstances[l].end();
									}
								}
							}
							
							currentSetIndex = setToCompare;
							playCurrentChildSet();
							for (k = 0; k < currentSet.length; k++)
							{
								currentSet[k].playheadTime = (iterationPlayheadTime - startTime);
								if (isPaused)
									currentSet[k].pause();
							}
						}
						endEffectCalled = false;
						break;
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			isPaused = false;
			activeEffectQueue = [];
			currentSetIndex = playReversed ? childSets.length : -1;
			
			var n:int;
			var i:int;

			n = childSets.length;
			for (i = 0; i < n; i++)
			{
				var instances:Array = childSets[i];
				activeEffectQueue.push(instances);
			}
			
			super.play();
			
			if (activeEffectQueue.length == 0)
			{
				finishRepeat();
				return;
			}
			playNextChildSet();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void
		{   
			super.pause();
			isPaused = true;
			if (currentSet && currentSet.length > 0)
			{
				var n:int = currentSet.length;
				for (var i:int = 0; i < n; i++)
				{
					currentSet[i].pause();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			isPaused = false;
			
			if (activeEffectQueue && activeEffectQueue.length > 0)
			{
				var queueCopy:Array = activeEffectQueue.concat();
				activeEffectQueue = null;
				var currentInstances:Array = queueCopy[currentSetIndex];
				if (currentInstances)
				{
					var currentCount:int = currentInstances.length;
					
					for (var i:int = 0; i < currentCount; i++)
						currentInstances[i].stop();
				}

				var n:int = queueCopy.length;
				for (var j:int = currentSetIndex + 1; j < n; j++)
				{
					var waitingInstances:Array = queueCopy[j];
					var m:int = waitingInstances.length;
					
					for (var k:int = 0; k < m; k++)
					{
						var instance:IEffectInstance = waitingInstances[k];
						instance.effect.deleteInstance(instance);
					}
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
			isPaused = false;
			if (currentSet && currentSet.length > 0)
			{
				var n:int = currentSet.length;
				for (var i:int = 0; i < n; i++)
				{
					currentSet[i].resume();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reverse():void
		{
			super.reverse();
			if (currentSet && currentSet.length > 0)
			{
				var n:int = currentSet.length;
				for (var i:int = 0; i < n; i++)
				{
					currentSet[i].reverse();
				}
			}
		}
		
		/**
		 * 中断当前正在播放的所有效果，跳过尚未开始播放的所有效果，并立即跳至最终的复合效果。
		 */
		override public function end():void
		{
			endEffectCalled = true;
			if (activeEffectQueue && activeEffectQueue.length > 0)
			{
				var queueCopy:Array = activeEffectQueue.concat();
				activeEffectQueue = null;
				
				var currentInstances:Array = queueCopy[currentSetIndex];
				if (currentInstances)
				{
					var currentCount:int = currentInstances.length;                
					for (var i:int = 0; i < currentCount; i++)
					{
						currentInstances[i].end();
					}
				}
				
				var n:int = queueCopy.length;
				for (var j:int = currentSetIndex + 1; j < n; j++)
				{
					var waitingInstances:Array = queueCopy[j];
					var m:int = waitingInstances.length;
					
					for (var k:int = 0; k < m; k++)
					{
						EffectInstance(waitingInstances[k]).playWithNoDuration();
					}
				}
			}
			isPaused = false;
			super.end();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onEffectEnd(childEffect:IEffectInstance):void
		{
			for (var i:int = 0; i < currentSet.length; i++)
			{
				if (childEffect == currentSet[i])
				{
					currentSet.splice(i, 1);
					break;
				}
			}   
			if (endEffectCalled)
				return; 
			
			if (currentSet.length == 0)
			{
				if (false == playNextChildSet())
					finishRepeat();
			}
		}

		private function playCurrentChildSet():void
		{
			var childEffect:EffectInstance;
			var instances:Array = activeEffectQueue[currentSetIndex];
			
			currentSet = [];
			
			for (var i:int = 0; i < instances.length; i++)
			{
				childEffect = instances[i];
				
				currentSet.push(childEffect);
				childEffect.playReversed = playReversed;
				childEffect.startEffect();
			}
			currentInstanceDuration += childEffect.actualDuration;
		}
		
		private function playNextChildSet(offset:Number = 0):Boolean
		{
			if (!playReversed)
			{
				if (!activeEffectQueue ||
					currentSetIndex++ >= activeEffectQueue.length - 1)
				{
					return false;
				}
			}
			else
			{
				if (currentSetIndex-- <= 0)
					return false;
			}
			playCurrentChildSet();
			return true;
		}
	}
	
}
