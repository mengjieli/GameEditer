package egret.effects
{
	import flash.events.EventDispatcher;
	
	import avmplus.getQualifiedClassName;
	
	import egret.core.ns_egret;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * 在动画完成播放时（既可以是正常完成播放时，也可以是通过调用end()或stop()方法提前结束播放时）分派。
	 */	
	[Event(name="effectEnd", type="egret.events.EffectEvent")]
	/**
	 * 在动画被停止播放时分派，即当该动画的stop()方法被调用时。还将分派 EFFECT_END事件以指示已结束该动画。将首先发送此EFFECT_STOP事件，作为对动画未正常播放完的指示。
	 */	
	[Event(name="effectStop", type="egret.events.EffectEvent")]
	/**
	 * 当动画开始播放时分派。
	 */	
	[Event(name="effectStart", type="egret.events.EffectEvent")]
	
	/**
	 * Effect 类是一个抽象基类，用于定义所有效果的基本功能。
	 * Effect 类定义所有效果的基本工厂类。EffectInstance 类定义所有效果实例子类的基类。 
	 * @author xzper
	 */
	public class Effect extends EventDispatcher implements IEffect
	{
		public function Effect(target:Object = null)
		{
			super();
			this.target = target;
		}
		
		private var _instances:Array = [];
		
		private var _isPaused:Boolean = false;
		
		/**
		 * 是否在逆转播放
		 */
		ns_egret var playReversed:Boolean;
		
		private var effectStopped:Boolean;
		
		/**
		 * 效果所属的复杂效果
		 */
		ns_egret var parentCompositeEffect:Effect;
		
		private var _duration:Number = 500;
		ns_egret var durationExplicitlySet:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get duration():Number
		{
			if (!durationExplicitlySet &&
				parentCompositeEffect)
			{
				return parentCompositeEffect.duration;
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

		/**
		 * 一个 Class 类型的对象，用于指定此效果类的效果实例类。
		 * <p>Effect 类的所有子类都必须在其构造函数中设置此属性。</p>
		 */
		public var instanceClass:Class = IEffectInstance;
		
		/**
		 * @inheritDoc
		 */
		public function get isPlaying():Boolean
		{
			return _instances && _instances.length > 0;
		}
		
		/**
		 * 是否处于暂停状态，当调用了paused()方法后此属性为true
		 */
		public function get isPaused():Boolean
		{
			if(isPlaying)
				return _isPaused;
			else
				return false;
		}
		
		private var _perElementOffset:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get perElementOffset():Number
		{
			return _perElementOffset;
		}

		public function set perElementOffset(value:Number):void
		{
			_perElementOffset = value;
		}
		
		/**
		 * 效果的重复次数。可能的值为任何大于等于 0 的整数。
		 * 值为 1 表示播放一次效果。值为 0 表示无限制地循环播放效果，直到通过调用 end() 方法停止播放。
		 */
		public var repeatCount:int = 1;
		
		/**
		 * 重复播放效果前需要等待的时间（以毫秒为单位）。可能的值为任何大于等于 0 的整数。
		 */
		public var repeatDelay:int = 0;

		/**
		 * 开始播放效果前需要等待的时间（以毫秒为单位）。
		 * 此值可以是任何大于或等于 0 的整数。
		 * 如果使用 repeatCount 属性重复播放效果，则只在首次播放效果时应用 startDelay。
		 */
		public var startDelay:int = 0;
		
		/**
		 * @inheritDoc
		 */
		public function get target():Object
		{
			if (_targets.length > 0)
				return _targets[0]; 
			else
				return null;
		}
		
		public function set target(value:Object):void
		{
			_targets.splice(0);
			
			if (value)
				_targets[0] = value;
		}
		
		private var _targets:Array = [];
		/**
		 * @inheritDoc
		 */
		public function get targets():Array
		{
			return _targets;
		}

		public function set targets(value:Array):void
		{
			var n:int = value.length;
			for (var i:int = n - 1; i >= 0; i--)
			{
				if (value[i] == null)
					value.splice(i,1);
			}
			_targets = value;
		}
		
		private var _playheadTime:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get playheadTime():Number 
		{
			for (var i:int = 0; i < _instances.length; i++)
			{
				if (_instances[i])
					return IEffectInstance(_instances[i]).playheadTime;
			}
			return _playheadTime;
		}
		public function set playheadTime(value:Number):void
		{
			var started:Boolean = false;
			if (_instances.length == 0)
			{
				play();
				started = true;
			}
			for (var i:int = 0; i < _instances.length; i++)
			{
				if (_instances[i])
					IEffectInstance(_instances[i]).playheadTime = value;
			}
			if (started)
				pause();
			_playheadTime = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function createInstances(targets:Array = null):Array
		{
			if (!targets)
				targets = this.targets;
			
			var newInstances:Array = [];
			var offsetDelay:Number = 0;
			
			for each (var target:Object in targets) 
			{
				var newInstance:IEffectInstance = createInstance(target);
				if (newInstance)
				{
					newInstance.startDelay += offsetDelay;
					offsetDelay += perElementOffset;
					newInstances.push(newInstance);
				}
			}
			
			return newInstances; 
		}
		
		/**
		 * @inheritDoc
		 */
		public function createInstance(target:Object = null):IEffectInstance
		{       
			if (!target)
				target = this.target;
			
			var newInstance:IEffectInstance = IEffectInstance(new instanceClass(target));
			initInstance(newInstance);
			
			EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_START, effectStartHandler);
			EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_STOP, effectStopHandler);
			EventDispatcher(newInstance).addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			
			_instances.push(newInstance);
			
			return newInstance;
		}
		
		/**
		 *  将效果的属性复制到效果实例。 
		 *  <p>创建自定义效果时覆盖此方法，将属性从 Effect 类复制到效果实例类。
		 * 进行覆盖时，请调用 super.initInstance()。 </p>
		 *  @param EffectInstance 要初始化的效果实例。
		 */
		protected function initInstance(instance:IEffectInstance):void
		{
			instance.duration = duration;
			Object(instance).durationExplicitlySet = durationExplicitlySet;
			instance.effect = this;
			instance.repeatCount = repeatCount;
			instance.repeatDelay = repeatDelay;
			instance.startDelay = startDelay;
		}
		
		/**
		 * @inheritDoc
		 */
		public function deleteInstance(instance:IEffectInstance):void
		{
			EventDispatcher(instance).removeEventListener(
				EffectEvent.EFFECT_START, effectStartHandler);
			EventDispatcher(instance).removeEventListener(
				EffectEvent.EFFECT_STOP, effectStopHandler);
			EventDispatcher(instance).removeEventListener(
				EffectEvent.EFFECT_END, effectEndHandler);
			
			var n:int = _instances.length;
			for (var i:int = 0; i < n; i++)
			{
				if (_instances[i] === instance)
					_instances.splice(i, 1);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function play(targets:Array = null,playReversedFromEnd:Boolean = false):Array
		{
			effectStopped = false;
			_isPaused = false;
			playReversed = playReversedFromEnd;
			
			var newInstances:Array = createInstances(targets);
			
			var n:int = newInstances.length;
			for (var i:int = 0; i < n; i++) 
			{
				var newInstance:IEffectInstance = IEffectInstance(newInstances[i]);
				Object(newInstance).playReversed = playReversedFromEnd;
				newInstance.startEffect();
			}
			return newInstances; 
		}
		
		/**
		 * @inheritDoc
		 */
		public function pause():void
		{
			if (isPlaying && !_isPaused)
			{
				_isPaused = true;
				var n:int = _instances.length;
				for (var i:int = 0; i < n; i++)
				{
					IEffectInstance(_instances[i]).pause();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{   
			var n:int = _instances.length - 1;
			for (var i:int = n; i >= 0; i--)
			{
				var instance:IEffectInstance = IEffectInstance(_instances[i]);
				if (instance)
					instance.stop();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function resume():void
		{
			if (isPlaying && _isPaused)
			{
				_isPaused = false;
				var n:int = _instances.length;
				for (var i:int = 0; i < n; i++)
				{
					IEffectInstance(_instances[i]).resume();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function reverse():void
		{
			if (isPlaying)
			{
				var n:int = _instances.length;
				for (var i:int = 0; i < n; i++)
				{
					IEffectInstance(_instances[i]).reverse();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function end(effectInstance:IEffectInstance = null):void
		{
			if (effectInstance)
			{
				effectInstance.end();
			}
			else
			{
				var n:int = _instances.length;
				for (var i:int = n - 1; i >= 0; i--)
				{
					var instance:IEffectInstance = IEffectInstance(_instances[i]);
					if (instance)
						instance.end();
				}
			}
		}
		
		/**
		 * 当效果实例开始播放时调用此方法。
		 */
		protected function effectStartHandler(event:EffectEvent):void 
		{
			dispatchEvent(event);
		}
		
		/**
		 * 当效果实例已被 stop() 方法调用停止时调用。
		 */
		protected function effectStopHandler(event:EffectEvent):void
		{
			dispatchEvent(event);
			effectStopped = true;
		}
		
		/**
		 * 当效果实例完成播放时调用。
		 */
		protected function effectEndHandler(event:EffectEvent):void 
		{
			var instance:IEffectInstance = IEffectInstance(event.effectInstance);
			deleteInstance(instance);
			dispatchEvent(event);
		}
	}
}