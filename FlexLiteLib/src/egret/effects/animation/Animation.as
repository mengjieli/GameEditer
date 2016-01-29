package egret.effects.animation
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import egret.core.ns_egret;
	import egret.effects.easing.IEaser;
	import egret.effects.easing.Sine;
	import egret.effects.interpolation.IInterpolator;
	
	use namespace ns_egret;

	/**
	 * 数值缓动工具类
	 * @author xzper
	 */
	public final class Animation
	{
		private static const TIMER_RESOLUTION:Number = 1000 / 60;
		
		/**
		 * 构造函数
		 * @param updateFunction 动画更新时的回调函数,updateFunction(animation:Animation):void
		 */	
		public function Animation(updateFunction:Function)
		{
			this.updateFunction = updateFunction;
		}
		
		/**
		 * 动画开始播放时的回调函数,只会在首次延迟等待结束时触发一次,若有重复播放，之后将触发repeatFunction。
		 * startFunction(animation:Animation):void
		 */
		public var startFunction:Function = null;
		/**
		 * 动画播放结束时的回调函数,可以是正常播放结束，也可以是被调用了end()方法导致结束。注意：stop()方法被调用不会触发这个函数。
		 * endFunction(animation:Animation):void
		 */
		public var endFunction:Function = null;
		/**
		 * 动画更新时的回调函数,updateFunction(animation:Animation):void
		 */
		public var updateFunction:Function = null;
		/**
		 * 动画被停止的回调函数，即stop()方法被调用。stopFunction(animation:Animation):void
		 */
		public var stopFunction:Function = null;
		/**
		 * 动画重复的回调函数，repeatFunction(animation:Animation):void
		 */
		public var repeatFunction:Function = null;
		
		/**
		 * 用于计算当前帧的时间
		 */
		private static var intervalTime:Number = NaN;
		
		private static var activeAnimations:Vector.<Animation> = new Vector.<Animation>;
		private static var timer:Timer = null;
		
		private var id:int = -1;
		private var _doSeek:Boolean = false;
		private var _isPlaying:Boolean = false;
		private var _doReverse:Boolean = false;
		private var _invertValues:Boolean = false;
		private var startTime:Number;
		private var started:Boolean = false;
		private var cycleStartTime:Number;
		private var delayTime:Number = -1;
		private static var delayedStartAnims:Vector.<Animation> = new Vector.<Animation>();
		private var delayedStartTime:Number = -1;
		
		/**
		 * 直到 Animation 的当前帧，包含计算的值的对象。
		 * 会使用属性名作为键，将这些值存储为 map 值。
		 */
		public var currentValue:Object;
		
		/**
		 * MotionPath 对象集，它定义随着时间的推移 Animation 将设置动画的属性和值。
		 */
		public var motionPaths:Vector.<MotionPath>;
		
		private var _playheadTime:Number = 0;
		/**
		 * 动画的总计已过去时间，包括任何开始延迟和重复。
		 * 对于播放了第一个循环的动画，此值将等于 cycleTime 的值。
		 */
		public function get playheadTime():Number
		{
			return _playheadTime + startDelay;
		}
		public function set playheadTime(value:Number):void
		{
			_invertValues = false; 
			seek(value, true);
		}
		/**
		 * 如果为 true，则表示当前正在播放动画。
		 * 除非已播放动画且尚未停止（以编程方式或自动）或暂停它，否则该值为 false。
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		/**
		 * 动画的时长（以毫秒为单位），不计算由 repeatCount 属性定义的任何重复。
		 */
		public var duration:Number = 500;

		private var _repeatBehavior:String = RepeatBehavior.LOOP;
		/**
		 * 设置重复动画的行为。
		 * 重复动画已将 repeatCount 属性设置为 0 或某个大于 1 的值。
		 * 此值应该为 RepeatBehavior.LOOP（意味着每次动画按相同的顺序重复）
		 * 或 RepeatBehavior.REVERSE（意味着对于每个迭代，动画都倒转方向）。
		 */
		public function get repeatBehavior():String
		{
			return _repeatBehavior;
		}
		
		public function set repeatBehavior(value:String):void
		{
			_repeatBehavior = value;
		}

		private var _repeatCount:int = 1;
		/**
		 * 此动画重复的次数。值为 0 意味着它会无限期地重复。
		 */
		public function set repeatCount(value:int):void
		{
			_repeatCount = value;
		}
		
		public function get repeatCount():int
		{
			return _repeatCount;
		}

		private var _repeatDelay:Number = 0;
		/**
		 * 在每次重复循环开始之前延迟的时间数量（以毫秒为单位）。
		 * 将此值设置为一个非零数字会恰好在其结束值处结束上一个动画循环。
		 * 但是，不延迟的重复可能会完全跳过该值，因为动画会从在一个循环的结尾附近平滑地过渡到越过下一个循环的开始处。
		 * 必须将此属性设置为大于等于 0 的一个值。 
		 */
		public function set repeatDelay(value:Number):void
		{
			_repeatDelay = value;
		}
		public function get repeatDelay():Number
		{
			return _repeatDelay;
		}
		
		private var _startDelay:Number = 0;
		/**
		 * 在动画开始之前等待的时间数量。必须将此属性设置为大于等于 0 的一个值。
		 */
		public function set startDelay(value:Number):void
		{
			_startDelay = value;
		}
		public function get startDelay():Number
		{
			return _startDelay;
		}
		
		/**
		 * Animation 实例所用的插补器，用于计算属性的开始值和结束值之间的值。
		 */
		public var interpolator:IInterpolator = null;
		
		private var _cycleTime:Number = 0;
		/**
		 * 在当前周期动画中的当前毫秒位置。该值介于 0 和 duration 之间。
		 * 动画的“周期”被定义为动画的单一重复，其中 repeatCount 属性用于定义将播放的周期数。
		 * 使用 seek() 方法更改动画的位置。
		 */
		public function get cycleTime():Number
		{
			return _cycleTime;
		}

		private var _cycleFraction:Number;
		/**
		 * 在已应用缓动之后，在动画中已过去的当前部分。
		 * 此值在 0 和 1 之间。动画的“周期”被定义为动画的单一重复，其中 repeatCount 属性用于定义将播放的周期数。
		 */
		public function get cycleFraction():Number
		{
			return _cycleFraction;
		}
		
		private static var defaultEaser:IEaser = new Sine(.5); 
		private var _easer:IEaser = defaultEaser;
		/**
		 * 此效果的缓动行为，默认为Sine(.5)
		 */
		public function get easer():IEaser
		{
			return _easer;
		}
		
		public function set easer(value:IEaser):void
		{
			if (!value)
			{
				value = defaultEaser;
			}
			_easer = value;
		}
		
		private var _playReversed:Boolean;
		/**
		 * 如果为 true，则反向播放动画。
		 * 如果当前播放动画的方向与 playReversed 的指定值相反，则动画将以动态方式更改方向。
		 */
		public function get playReversed():Boolean
		{
			return _playReversed;
		}

		public function set playReversed(value:Boolean):void
		{
			if (_isPlaying)
			{
				if (_invertValues != value)
				{
					_invertValues = value;
					seek(duration - _cycleTime, true);
				}
			}
			_doReverse = value;
			_playReversed = value;
		}
		
		/**
		 * 添加动画
		 */
		private static function addAnimation(animation:Animation):void
		{
			if (animation.motionPaths && animation.motionPaths.length > 0 &&
				animation.motionPaths[0] &&
				(animation.motionPaths[0].property == "width" ||
					animation.motionPaths[0].property == "height"))
			{
				activeAnimations.splice(0, 0, animation);
				animation.id = 0;
				for (var i:int = 1; i < activeAnimations.length; ++i)
					Animation(activeAnimations[i]).id = i;
			}
			else
			{
				animation.id = activeAnimations.length;
				activeAnimations.push(animation);
			}
			
			if (!timer)
			{
				pulse();
				timer = new Timer(TIMER_RESOLUTION);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
			}
			intervalTime = currentTime;
			animation.cycleStartTime = intervalTime;
		}
		
		private static function removeAnimationAt(index:int):void
		{
			if (index >= 0 && index < activeAnimations.length)
			{
				activeAnimations.splice(index, 1);
				
				var n:int = activeAnimations.length;
				for (var i:int = index; i < n; i++)
				{
					var curAnimation:Animation = Animation(activeAnimations[i]);
					curAnimation.id--;
				}
			}
			stopTimerIfDone();
		}
		
		private static function removeAnimation(animation:Animation):void
		{
			removeAnimationAt(animation.id);
		}
		
		private static function timerHandler(event:TimerEvent):void
		{
			intervalTime = pulse();
			
			var i:int = 0;
			
			while (i < activeAnimations.length)
			{
				var incrementIndex:Boolean = true;
				var animation:Animation = Animation(activeAnimations[i]);
				if (animation)
					incrementIndex = !animation.doInterval();
				if (incrementIndex)
					++i;
			}
			
			while (delayedStartAnims.length > 0)
			{
				var anim:Animation = Animation(delayedStartAnims[0]);
				var animStartTime:Number = anim.delayedStartTime;
				if (animStartTime < currentTime)
					if (anim.playReversed)
						anim.end();
					else
						anim.start();
					else
						break;
			}
			event.updateAfterEvent();
		}
		
		/**
		 * 计算插补值，派发更新事件。如果动画结束了则返回true
		 */
		private function doInterval():Boolean
		{
			var animationEnded:Boolean = false;
			var repeated:Boolean = false;
			
			if (_isPlaying || _doSeek)
			{
				var currentTime:Number = intervalTime - cycleStartTime;
				_playheadTime = intervalTime - startTime;
				if (currentTime >= duration)
				{
					var numRepeats:int = 2;
					if ((duration + repeatDelay) > 0)
						numRepeats += Math.floor((_playheadTime - duration) / (duration + repeatDelay));
					if (repeatCount == 0 || numRepeats <= repeatCount)
					{
						if (repeatDelay == 0)
						{
							_cycleTime = currentTime % duration;
							cycleStartTime = intervalTime - _cycleTime;
							currentTime = _cycleTime;                        
							if (repeatBehavior == RepeatBehavior.REVERSE)
							{
								if (repeatCount > 1)
									_invertValues = !(numRepeats%2);
								else
									_invertValues = !_invertValues;
							}
							repeated = true;
						}
						else
						{
							if (_doSeek)
							{
								_cycleTime = currentTime % (duration + repeatDelay);
								if (_cycleTime > duration)
									_cycleTime = duration;
								calculateValue(_cycleTime);
								sendUpdateEvent();
								return false;
							}
							else
							{
								_cycleTime = duration;
								calculateValue(_cycleTime);
								sendUpdateEvent();
								removeAnimation(this);
								var delayTimer:Timer = new Timer(repeatDelay, 1);
								delayTimer.addEventListener(TimerEvent.TIMER, repeat);
								delayTimer.start();
								return false;
							}
						}
					}
					else if (currentTime > duration)
					{
						currentTime = duration;
						_playheadTime = duration;
					}
				}
				_cycleTime = currentTime;
				
				calculateValue(currentTime);
				
				if (currentTime >= duration && !_doSeek)
				{
					if (!playReversed || startDelay == 0)
					{
						end();
						animationEnded = true;
					}
					else
					{
						stopAnimation();
						addToDelayedAnimations(startDelay);
					}
				}
				else
				{
					if (repeated)
						sendAnimationEvent("repeatFunction");
					sendUpdateEvent();
				}
			}
			return animationEnded;
		}
		
		/**
		 * 通知目标对象更新动画
		 */
		private function sendUpdateEvent():void
		{
			sendAnimationEvent("updateFunction");
		}
		
		/**
		 * 发送动画事件
		 */
		private function sendAnimationEvent(eventType:String):void
		{
			if(this[eventType] != null)
			{
				this[eventType](this);
			}
		}
		
		/**
		 * 计算当前值
		 */
		private function calculateValue(currentTime:Number):void
		{
			var i:int;
			
			currentValue = {};
			if (duration == 0)
			{
				for (i = 0; i < motionPaths.length; ++i)
				{
					currentValue[motionPaths[i].property] = 
						_invertValues ? 
						motionPaths[i].keyframes[0].value :
						motionPaths[i].keyframes[motionPaths[i].keyframes.length - 1].value;
				}
				return;
			}
			
			if (_invertValues)
				currentTime = duration - currentTime;
			
			_cycleFraction = easer.ease(currentTime/duration);
			
			if (motionPaths)
				for (i = 0; i < motionPaths.length; ++i)
					currentValue[motionPaths[i].property] = 
						motionPaths[i].getValue(_cycleFraction);
		}
		
		private function removeFromDelayedAnimations():void
		{
			if (this.delayedStartTime>=0)
			{
				for (var i:int = 0; i < delayedStartAnims.length; ++i)
				{
					if (delayedStartAnims[i] == this)
					{
						delayedStartAnims.splice(i, 1);
						break;
					}
				}
				this.delayedStartTime = -1;
			}
		}
		
		/**
		 * 中断动画，立即跳到动画的结尾，并对 animationTarget 调用 animationEnd() 函数。
		 */
		public function end():void
		{
			if (startDelay > 0 && delayedStartAnims.length > 0)
			{
				removeFromDelayedAnimations();
			}
			
			if (!started)
				sendAnimationEvent("startFunction");
			if (repeatCount > 1 && repeatBehavior == "reverse" && (repeatCount % 2 == 0))
				_invertValues = true;
			
			if (!(_doReverse && startDelay > 0))
			{
				calculateValue(duration);
				sendUpdateEvent();
			}
			
			sendAnimationEvent("endFunction");
			
			if (isPlaying)
				stopAnimation();
			else
				stopTimerIfDone();
		}
		
		private static function stopTimerIfDone():void
		{
			if (timer && activeAnimations.length == 0 && delayedStartAnims.length == 0)
			{
				intervalTime = NaN;
				timer.reset();
				timer = null;
			}
		}
		
		private function addToDelayedAnimations(timeToDelay:Number):void
		{
			if (!timer)
			{
				pulse();
				timer = new Timer(TIMER_RESOLUTION);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
			}
			var animStartTime:int = currentTime + timeToDelay;
			var insertIndex:int = -1;
			for (var i:int = 0; i < delayedStartAnims.length; ++i)
			{
				var timeAtIndex:int = delayedStartAnims[i].delayedStartTime;
				if (animStartTime < timeAtIndex)
				{
					insertIndex = i;
					break;
				}
			}
			if (insertIndex >= 0)
				delayedStartAnims.splice(insertIndex, 0, this);
			else
				delayedStartAnims.push(this);
			this.delayedStartTime = animStartTime;
		}
		
		/**
		 * 开始动画。如果动画已在播放，则会首先停止它，然后播放它。
		 */
		public function play():void
		{
			stopAnimation();
			var i:int;
			var j:int;
			for (i = 0; i < motionPaths.length; ++i)
			{
				var keyframes:Vector.<Keyframe> = motionPaths[i].keyframes;
				if (isNaN(keyframes[0].time))
					keyframes[0].time = 0;
				else if (keyframes[0].time > 0)
				{
					var startTime:Number = keyframes[0].time;
					keyframes.splice(0, 0, new Keyframe(0, null));
					keyframes.splice(1, 0, new Keyframe(startTime-1, null));
					if (playReversed)
					{
						keyframes[0].value = keyframes[2].value;
						keyframes[1].value = keyframes[2].value;
					}
				}
				for (j = 1; j < keyframes.length; ++j)
				{
					if (isNaN(keyframes[j].time))
						keyframes[j].time = duration;
				}
			}
			for (i = 0; i < motionPaths.length; ++i)
				motionPaths[i].scaleKeyframes(duration);
			
			if (_doReverse)
				_invertValues = true;
			
			if (startDelay > 0 && !playReversed)
				addToDelayedAnimations(startDelay);
			else
				start();
		}
		
		/**
		 * 前进到指定位置
		 */ 
		private function seek(playheadTime:Number, includeStartDelay:Boolean = false):void
		{
			startTime = cycleStartTime = intervalTime - playheadTime;
			_doSeek = true;
			
			if (!_isPlaying || playReversed)
			{
				var isPlayingTmp:Boolean = _isPlaying;
				intervalTime = currentTime;
				if (includeStartDelay && startDelay > 0)
				{
					if (this.delayedStartTime>=0)
					{
						removeFromDelayedAnimations();
						var postDelaySeekTime:Number = playheadTime - startDelay;
						if (playReversed)
							postDelaySeekTime -= duration;
						if (postDelaySeekTime < 0)
						{
							addToDelayedAnimations(startDelay - playheadTime);
							return;
						}
						else
						{
							playheadTime -= startDelay;
							if (!isPlaying)
								start();
							startTime = cycleStartTime = intervalTime - playheadTime;
							doInterval();
							_doSeek = false;
							return;
						}
					}
				}
				if (!isPlayingTmp)
				{
					sendAnimationEvent("startFunction");
					setupInterpolation();
				}
				startTime = cycleStartTime = intervalTime - playheadTime;
			}
			doInterval();
			_doSeek = false;
		}
		
		/**
		 * 设置数组插补器
		 */
		private function setupInterpolation():void
		{
			if (interpolator && motionPaths)
				for (var i:int = 0; i < motionPaths.length; ++i)
					motionPaths[i].interpolator = interpolator;
		}
		
		/**
		 * 从当前位置反向播放效果
		 */
		ns_egret function reverse():void
		{
			if (_isPlaying)
			{
				_doReverse = false;
				seek(duration - _cycleTime);
				_invertValues = !_invertValues;
			}
			else
			{
				_doReverse = !_doReverse;
			}
		}
		
		/**
		 * 在调用 resume() 方法之前暂停该效果。如果在 resume() 之前调用 stop()，则无法继续该动画。
		 */
		public function pause():void
		{
			if (this.delayedStartTime>=0)
			{
				delayTime = this.delayedStartTime - currentTime;
				removeFromDelayedAnimations();
			}
			_isPlaying = false;
		}
		
		private function stopAnimation():void
		{
			removeFromDelayedAnimations();
			if (id >= 0)
			{
				Animation.removeAnimationAt(id);
				id = -1;
				_invertValues = false;
				_isPlaying = false;
			}
		}
		/**
		 * 停止播放动画，且结束时不调用 end() 方法。将对 animationTarget 调用 animationStop() 函数。
		 */
		public function stop():void
		{
			stopAnimation();
			sendAnimationEvent("stopFunction");
		}
		
		/**
		 * 在效果由 pause() 方法暂停后继续播放效果。
		 */
		public function resume():void
		{
			_isPlaying = true;
			
			if (delayTime >= 0)
			{
				addToDelayedAnimations(delayTime);
			}
			else
			{
				cycleStartTime = intervalTime - _cycleTime;
				startTime = intervalTime - _playheadTime;
				if (_doReverse)
				{
					reverse();
					_doReverse = false;
				}
			}
		}
		
		private function repeat(event:TimerEvent = null):void
		{
			if (repeatBehavior == RepeatBehavior.REVERSE)
				_invertValues = !_invertValues;
			calculateValue(0);
			sendAnimationEvent("repeatFunction");
			sendUpdateEvent();
			Animation.addAnimation(this);
		}
		
		private function start(event:TimerEvent = null):void
		{
			var actualStartTime:int = 0;
			if (!playReversed && this.delayedStartTime>=0)
			{
				var overrun:int = currentTime - this.delayedStartTime;
				if (overrun > 0)
					actualStartTime = Math.min(overrun, duration);
				removeFromDelayedAnimations();
			}
			sendAnimationEvent("startFunction");
			setupInterpolation();
			calculateValue(0);
			sendUpdateEvent();
			Animation.addAnimation(this);
			startTime = cycleStartTime;
			_isPlaying = true;
			if (actualStartTime > 0)
				seek(actualStartTime);
			started = true;
		}
		
		private static var startTime:int = -1;
		private static var _currentTime:int = -1;
		private static function pulse():int
		{
			if (startTime < 0)
			{
				startTime = getTimer();
				_currentTime = 0;
				return _currentTime;
			}
			_currentTime = getTimer() - startTime;
			return _currentTime;
		}
		
		private static function get currentTime():int
		{
			if (_currentTime < 0)
			{
				return pulse();
			}
			return _currentTime;
		}
	}
}