package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.animation.MotionPath;
	import egret.effects.animation.RepeatBehavior;
	import egret.effects.easing.IEaser;
	import egret.effects.effectClasses.AnimateInstance;
	import egret.effects.interpolation.IInterpolator;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * 当动画更新时派发
	 */
	[Event(name="effectUpdate", type="egret.events.EffectEvent")]
	
	/**
	 * 对于任何重复次数超过一次的动画，当动画开始新的一次重复时分派。
	 */	
	[Event(name="effectRepeat", type="egret.events.EffectEvent")]
	
	
	/**
	 * 此 Animate 效果可设置各个值之间的任意属性集的动画。
	 * 通过设置 motionPaths 属性，指定要设置动画的属性和值。
	 */
	public class Animate extends Effect
	{
		public function Animate(target:Object = null)
		{
			super(target);
			instanceClass = AnimateInstance;
		}
		
		private var numUpdateListeners:int = 0;
		
		private var _easer:IEaser;
		/**
		 * 此效果的缓动行为。默认情况下，Animate 的缓动是非线性的 (Sine(.5))。
		 */
		public function get easer():IEaser
		{
			return _easer;
		}
		
		public function set easer(value:IEaser):void
		{
			_easer = value;
		}
		
		private var _motionPaths:Vector.<MotionPath>;
		/**
		 * MotionPath 对象的 Vector，其中的每个对象都带有正在设置动画的属性的名称以及该属性在动画过程中所采用的值。
		 * 此 Vector 优先于 Animate 的子类中所声明的任何属性。
		 * 例如，如果此 Array 是直接在 Move 效果上设置的，则会忽略 Move 效果的任何属性（如 xFrom）。
		 */
		public function get motionPaths():Vector.<MotionPath>
		{
			return _motionPaths;
		}
		
		public function set motionPaths(value:Vector.<MotionPath>):void
		{
			_motionPaths = value;
		}
		
		private var _interpolator:IInterpolator = null;
		/**
		 * 此效果计算属性的起始值和结束值之间的值所用的插补器。
		 * 默认情况下，NumberInterpolator 类处理内插值，
		 */
		public function get interpolator():IInterpolator
		{
			return _interpolator;
		}
		
		public function set interpolator(value:IInterpolator):void
		{
			_interpolator = value;
		}
		
		private var _repeatBehavior:String = RepeatBehavior.LOOP;
		/**
		 * 一种重复效果的行为。值RepeatBehavior类中定义的常量。默认为RepeatBehavior.LOOP
		 */
		public function get repeatBehavior():String
		{
			return _repeatBehavior;
		}
		
		public function set repeatBehavior(value:String):void
		{
			_repeatBehavior = value;
		}
		
		private var _disableLayout:Boolean = false;
		/**
		 * 如果为 true，则对目标对象禁用任何布局约束。效果完成时，将还原这些属性。
		 */
		public function get disableLayout():Boolean
		{
			return _disableLayout;
		}
		
		public function set disableLayout(value:Boolean):void
		{
			_disableLayout = value;
		}
		
		override protected function initInstance(instance:IEffectInstance):void
		{
			super.initInstance(instance);
			
			var animateInstance:AnimateInstance = AnimateInstance(instance);
			
			animateInstance.addEventListener(EffectEvent.EFFECT_REPEAT, animationEventHandler);
			if (numUpdateListeners > 0)
				animateInstance.addEventListener(EffectEvent.EFFECT_UPDATE, animationEventHandler);
			
				animateInstance.easer = easer;
			
			if (interpolator)
				animateInstance.interpolator = interpolator;
			
			if (isNaN(repeatCount))
				animateInstance.repeatCount = repeatCount;
			
			animateInstance.repeatBehavior = repeatBehavior;
			animateInstance.disableLayout = disableLayout;
			
			if (motionPaths)
			{
				animateInstance.motionPaths = new Vector.<MotionPath>();
				for (var i:int = 0; i < motionPaths.length; ++i)
					animateInstance.motionPaths[i] = motionPaths[i].clone();
			}
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
		
		/**
		 * 派发动画事件
		 */
		private function animationEventHandler(event:EffectEvent):void
		{
			dispatchEvent(event);
		}
	}
}
