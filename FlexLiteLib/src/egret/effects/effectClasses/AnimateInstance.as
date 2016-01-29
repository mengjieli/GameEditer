package egret.effects.effectClasses
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import egret.core.IStyleClient;
	import egret.core.ns_egret;
	import egret.effects.EffectInstance;
	import egret.effects.animation.Animation;
	import egret.effects.animation.Keyframe;
	import egret.effects.animation.MotionPath;
	import egret.effects.animation.SimpleMotionPath;
	import egret.effects.easing.IEaser;
	import egret.effects.interpolation.IInterpolator;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * AnimateInstance 类用于实现 Animate 效果的实例类。
	 */
	public class AnimateInstance extends EffectInstance
	{
		public var animation:Animation;

		public function AnimateInstance(target:Object)
		{
			super(target);
		}
		
		/**
		 * 样式属性的字典
		 */
		private var isStyleMap:Object = new Object();
		
		private var _seekTime:Number = 0;
		private var reverseAnimation:Boolean;
		private var numUpdateListeners:int = 0;
		
		private var oldWidth:Number;
		private var oldHeight:Number;
		
		private var disabledConstraintsMap:Object;
		
		private var _motionPaths:Vector.<MotionPath>;
		/**
		 * MotionPath 对象集，它定义随着时间的推移 Animation 将设置动画的属性和值。
		 */
		public function get motionPaths():Vector.<MotionPath>
		{
			return _motionPaths;
		}
		public function set motionPaths(value:Vector.<MotionPath>):void
		{
			if (!_motionPaths)
				_motionPaths = value;
		}
		
		/**
		 * 如果为 true，则对目标对象禁用任何布局约束。效果完成时，将还原这些属性。
		 */
		public var disableLayout:Boolean;
		
		private var _easer:IEaser;
		/**
		 * 此效果的缓动行为。
		 */
		public function set easer(value:IEaser):void
		{
			_easer = value;
		}
		
		public function get easer():IEaser
		{
			return _easer;
		}
		
		private var _interpolator:IInterpolator;
		/**
		 * Animation 实例所用的插补器，用于计算属性的开始值和结束值之间的值。
		 */
		public function set interpolator(value:IInterpolator):void
		{
			_interpolator = value;
			
		}
		
		public function get interpolator():IInterpolator
		{
			return _interpolator;
		}
		
		private var _repeatBehavior:String;
		/**
		 * 设置重复动画的行为。
		 * 重复动画已将 repeatCount 属性设置为 0 或某个大于 1 的值。
		 * 此值应该为 RepeatBehavior.LOOP（意味着每次动画按相同的顺序重复）
		 * 或 RepeatBehavior.REVERSE（意味着对于每个迭代，动画都倒转方向）。
		 */
		public function set repeatBehavior(value:String):void
		{
			_repeatBehavior = value;
		}

		public function get repeatBehavior():String
		{
			return _repeatBehavior;
		}
		
		override ns_egret function set playReversed(value:Boolean):void
		{
			super.playReversed = value;
			
			if (value && animation)
				animation.reverse();
			
			reverseAnimation = value;
		}
		
		/**
		 *  @inheritDoc
		 */
		override public function get playheadTime():Number 
		{
			return animation ? animation.playheadTime : _seekTime;
		}
		
		override public function set playheadTime(value:Number):void
		{
			if (animation)
				animation.playheadTime = value;
			_seekTime = value;
		} 
		
		/**
		 * @inheritDoc
		 */
		override public function pause():void
		{
			super.pause();
			
			if (animation)
				animation.pause();
		}

		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			
			if (animation)
				animation.stop();
		}   
		
		/**
		 * @inheritDoc
		 */
		override public function resume():void
		{
			super.resume();
			
			if (animation)
				animation.resume();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reverse():void
		{
			super.reverse();
			
			if (animation)
				animation.reverse();
			
			reverseAnimation = !reverseAnimation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function end():void
		{
			if (animation)
			{
				animation.end();
				animation = null;
			}
			super.end();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function startEffect():void
		{
			//TODO?
			play();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			super.play();
			
			if (!motionPaths || motionPaths.length == 0)
			{
				var timer:Timer = new Timer(duration, 1);
				timer.addEventListener(TimerEvent.TIMER, noopAnimationHandler);
				timer.start();
				return;
			}
			
			isStyleMap = new Array(motionPaths.length);        
			
			var addWidthMP:Boolean;
			var addHeightMP:Boolean;
			var i:int;
			var j:int;
			for (i = 0; i < motionPaths.length; ++i)
			{
				var mp:MotionPath = MotionPath(motionPaths[i]);
				var keyframes:Vector.<Keyframe> = mp.keyframes;
				if (!keyframes)
					continue;
				
				if (interpolator)
					mp.interpolator = interpolator;
				if (duration > 0)
					for (j = 0; j < keyframes.length; ++j)
						if (!isNaN(keyframes[j].time))
							duration = Math.max(duration, keyframes[j].time);
			}
			
			if (addWidthMP)
				motionPaths.push(new SimpleMotionPath("width"));
			if (addHeightMP)
				motionPaths.push(new SimpleMotionPath("height"));
			
			animation = new Animation(animationUpdate);
			animation.duration = this.duration;
			animation.startFunction = animationStart;
			animation.endFunction = animationEnd;
			animation.stopFunction = animationStop;
			animation.repeatFunction = animationRepeat;
			animation.motionPaths = motionPaths;
			
			if (reverseAnimation)
				animation.playReversed = true;
			animation.interpolator = interpolator;
			animation.repeatCount = repeatCount;
			animation.repeatDelay = repeatDelay;
			animation.repeatBehavior = repeatBehavior;
			animation.easer = easer;
			animation.startDelay = startDelay;
			
			animation.play();
			if (_seekTime > 0)
				animation.playheadTime = _seekTime;
		}
		
		/**
		 * 应用动画对应的属性值
		 */
		protected function applyValues(anim:Animation):void
		{
			for (var i:int = 0; i < motionPaths.length; ++i)
			{
				var prop:String = motionPaths[i].property;
				setValue(prop, anim.currentValue[prop]);
			}
		}
		
		private function isValidValue(value:Object):Boolean
		{
			return ((value is Number && !isNaN(Number(value))) ||
				(!(value is Number) && value !== null));
		}
		
		/**
		 * 遍历motionPaths，用计算的值替换null。
		 */
		private function finalizeValues():void
		{
			var j:int;
			var prevValue:Object;
			for (var i:int = 0; i < motionPaths.length; ++i)
			{
				var motionPath:MotionPath = MotionPath(motionPaths[i]);
				var keyframes:Vector.<Keyframe> = motionPath.keyframes;
				if (!keyframes || keyframes.length == 0)
					continue;
				if (!isValidValue(keyframes[0].value))
				{
					if (keyframes.length > 0 &&
						isValidValue(keyframes[1].valueBy) &&
						isValidValue(keyframes[1].value))
					{
						keyframes[0].value = motionPath.interpolator.decrement(
							keyframes[1].value, keyframes[1].valueBy);
					}
					else
					{
						keyframes[0].value = getCurrentValue(motionPath.property);
					}
				}
				
				prevValue = keyframes[0].value;
				for (j = 1; j < keyframes.length; ++j)
				{
					var kf:Keyframe = Keyframe(keyframes[j]);
					if (!isValidValue(kf.value))
					{
						if (isValidValue(kf.valueBy))
							kf.value = motionPath.interpolator.increment(prevValue, kf.valueBy);
						else
						{
							// if next keyframe has value and valueBy, use them
							if (j <= (keyframes.length - 2) &&
								isValidValue(keyframes[j+1].value) &&
								isValidValue(keyframes[j+1].valueBy))
							{
								kf.value = motionPath.interpolator.decrement(
									keyframes[j+1].value, keyframes[j+1].valueBy);
							}
							else
							{
								kf.value = prevValue;
							}
						}
					}
					prevValue = kf.value;
				}
			}
		}
		
		public function animationStart(animation:Animation):void
		{
			if (disableLayout)
			{
				cacheConstraints();
			}
			else if (disabledConstraintsMap)
			{
				for (var constraint:String in disabledConstraintsMap)
					cacheConstraint(constraint);
				disabledConstraintsMap = null;
			}
			finalizeValues();
		}
		
		public function animationUpdate(animation:Animation):void
		{
			applyValues(animation);
			if (numUpdateListeners > 0)
			{
				var event:EffectEvent = new EffectEvent(EffectEvent.EFFECT_UPDATE);
				event.effectInstance = this;
				dispatchEvent(event);
			}
		}
		
		public function animationRepeat(animation:Animation):void
		{
			var event:EffectEvent = new EffectEvent(EffectEvent.EFFECT_REPEAT);
			event.effectInstance = this;
			dispatchEvent(event);
		}    
		
		private function animationCleanup():void
		{
			if (disableLayout)
			{
				reenableConstraints();
			}
		}
		
		public function animationEnd(animation:Animation):void
		{
			animationCleanup();
			finishEffect();
		}
		
		public function animationStop(animation:Animation):void
		{
			animationCleanup();
		}
		
		private function noopAnimationHandler(event:TimerEvent):void
		{
			finishEffect();
		}
		
		override public function addEventListener(type:String, listener:Function, 
												  useCapture:Boolean=false, priority:int=0, 
												  useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, 
				useWeakReference);
			if (type == EffectEvent.EFFECT_UPDATE)
				++numUpdateListeners;
		}
		
		override public function removeEventListener(type:String, listener:Function, 
													 useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			if (type == EffectEvent.EFFECT_UPDATE)
				--numUpdateListeners;
		}

		private var constraintsHolder:Object;		
		private function reenableConstraint(name:String):*
		{
			var value:* = constraintsHolder[name];
			if (value !== undefined)
			{
				if (name in target)
					target[name] = value;
				else
					target.setStyle(name, value);
				delete constraintsHolder[name];
			}
			return value;
		}
		
		private function reenableConstraints():void
		{
			if (constraintsHolder)
			{
				var left:* = reenableConstraint("left");
				var right:* = reenableConstraint("right");
				var top:* = reenableConstraint("top");
				var bottom:* = reenableConstraint("bottom");
				reenableConstraint("horizontalCenter");
				reenableConstraint("verticalCenter");
				constraintsHolder = null;
				if (left != undefined && right != undefined && "explicitWidth" in target)
					target.width = oldWidth;            
				if (top != undefined && bottom != undefined && "explicitHeight" in target)
					target.height = oldHeight;
			}
		}
		
		private function cacheConstraint(name:String):*
		{
			var isProperty:Boolean = (name in target);
			var value:*;
			if (isProperty)
				value = target[name];
			else
				value = target.getStyle(name);
			if (!isNaN(value) && value != null)
			{
				if (!constraintsHolder)
					constraintsHolder = {};
				constraintsHolder[name] = value;
				if (isProperty)
					target[name] = NaN;
				else if (target is IStyleClient)
					target.setStyle(name, undefined);
			}
			return value;
		}
		
		private function cacheConstraints():void
		{
			var left:* = cacheConstraint("left");
			var right:* = cacheConstraint("right");
			var top:* = cacheConstraint("top");
			var bottom:* = cacheConstraint("bottom");
			cacheConstraint("verticalCenter");
			cacheConstraint("horizontalCenter");
			if (left != undefined && right != undefined && "explicitWidth" in target)
			{
				var w:Number = target.width;    
				oldWidth = target.explicitWidth;
				target.width = w;
			}
			if (top != undefined && bottom != undefined && "explicitHeight" in target)
			{
				var h:Number = target.height;
				oldHeight = target.explicitHeight;
				target.height = h;
			}
		}
		
		protected function setupStyleMapEntry(property:String):void
		{
			if (isStyleMap[property] == undefined)
			{
				if (property in target)
				{
					isStyleMap[property] = false;
				}
				else
				{
					try {
						target.getStyle(property);
						isStyleMap[property] = true;
					}
					catch (err:Error)
					{
						throw new Error("propNotPropOrStyle"); 
					}
				}            
			}
		}
		
		protected function setValue(property:String, value:Object):void
		{
			setupStyleMapEntry(property);
			if (!isStyleMap[property])
				target[property] = value;
			else
				target.setStyle(property, value);
		}
		
		protected function getCurrentValue(property:String):*
		{
			setupStyleMapEntry(property);
			if (!isStyleMap[property])
				return target[property];
			else
				return target.getStyle(property);
		}
	}
}
