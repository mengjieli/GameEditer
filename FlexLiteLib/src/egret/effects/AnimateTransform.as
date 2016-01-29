package egret.effects
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import avmplus.getQualifiedClassName;
	
	import egret.core.ns_egret;
	import egret.effects.animation.Keyframe;
	import egret.effects.animation.MotionPath;
	import egret.effects.easing.Linear;
	import egret.effects.effectClasses.AnimateTransformInstance;
	import egret.events.EffectEvent;
	
	use namespace ns_egret;
	
	/**
	 * AnimateTransform 效果控制目标对象上所有与转换相关的动画。
	 * 在修改 overlapping 属性值时，平移、缩放和旋转等转换操作都会组合成同时运行的单个操作，
	 * 以避免发生任何冲突。此效果的工作原理是：将目标上当前所有转换效果组合成该目标的单个效果实例。
	 * 即同一 Parallel 效果内的多个转换效果将被组合到一起（在一个 Sequence 内的转换效果将单独运行）。 
	 */  
	public class AnimateTransform extends Animate
	{
		public function AnimateTransform(target:Object=null)
		{
			super(target);
			instanceClass = AnimateTransformInstance;
		}
		
		/**
		 * 指定在转换效果开始播放时，该效果是否围绕目标的中心 (width/2, height/2) 发生。
		 * 如果未设置该标志，转换中心将由对象的转换中心 (transformX, transformY, transformZ) 和此效果中的 transformX, transformY, transformZ 属性决定。
		 * 也就是说，转换中心就是目标对象的转换中心，其中的任何 transformX、transformY、transformZ 属性（如果已设置）都将由效果中的这些值覆盖。
		 */
		public var autoCenterTransform:Boolean = false;
		
		/**
		 * 设置转换中心的 x 坐标（由 autoCenterTransform 属性覆盖时除外）。 
		 */
		public var transformX:Number;
		
		/**
		 * 设置转换中心的 y 坐标（由 autoCenterTransform 属性覆盖时除外）。 
		 */
		public var transformY:Number;
		
		private function getOwningParallelEffect():Parallel
		{
			var prevParent:Parallel = null;
			var parent:Effect = parentCompositeEffect;
			while (parent)
			{
				if (parent is Sequence)
					break;
				prevParent = Parallel(parent);
				parent = parent.parentCompositeEffect;
			}
			return prevParent;
		}
		
		override public function createInstance(target:Object = null):IEffectInstance
		{       
			if (!target)
				target = this.target;
			
			var sharedInstance:IEffectInstance = null;
			var topmostParallel:Parallel = getOwningParallelEffect();
			if (topmostParallel != null)
				sharedInstance = IEffectInstance(getSharedInstance(topmostParallel, target));
			if (!sharedInstance)
			{
				var newInstance:IEffectInstance = super.createInstance(target);
				if (topmostParallel)
					storeSharedInstance(topmostParallel, target, newInstance);
				return newInstance;
			}
			else
			{
				initInstance(sharedInstance);
				return null;
			}
		}
		
		override protected function effectStartHandler(event:EffectEvent):void
		{
			super.effectStartHandler(event);
			var topmostParallel:Parallel = getOwningParallelEffect();
			if (topmostParallel != null)
				removeSharedInstance(topmostParallel, event.effectInstance.target);
		}
		
		/**
		 * 获取转换中心
		 */
		private function computeTransformCenterForTarget(target:Object, valueMap:Object = null):Point    
		{
			var computedTransformCenter:Point;
			if (autoCenterTransform)
			{
				var w:Number = (valueMap != null && valueMap["width"] !== undefined) ?
					valueMap["width"] :
					target.width;
				var h:Number = (valueMap != null && valueMap["height"] !== undefined) ?
					valueMap["height"] :
					target.height;
				computedTransformCenter = new Point(w/2, h/2);
			}
			else
			{
				computedTransformCenter = new Point(0,0);
				if (!isNaN(transformX))
					computedTransformCenter.x = transformX; 
				if (!isNaN(transformY))
					computedTransformCenter.y = transformY; 
			}
			return computedTransformCenter;
		}
		
		/**
		 * 插入关键帧
		 */
		private function insertKeyframe(keyframes:Vector.<Keyframe>, newKF:Keyframe):void
		{
			for (var i:int = 0; i < keyframes.length; i++)
			{
				if (keyframes[i].time > newKF.time)
				{
					keyframes.splice(i, 0, newKF);
					return;
				}
			}
			keyframes.push(newKF);
		}
		
		ns_egret function addMotionPath(property:String,
										   valueFrom:Number = NaN, valueTo:Number = NaN, valueBy:Number = NaN):void
		{
			if (isNaN(valueFrom))
			{
				if (!isNaN(valueTo) && !isNaN(valueBy))
					valueFrom = valueTo - valueBy;
			}
			var mp:MotionPath = new MotionPath(property);
			mp.keyframes = new <Keyframe>[new Keyframe(0, valueFrom),
				new Keyframe(duration, valueTo, valueBy)];
			mp.keyframes[1].easer = easer;
			
			if (motionPaths)
			{
				var n:int = motionPaths.length;
				for (var i:int = 0; i < n; i++)
				{
					var prop:MotionPath = MotionPath(motionPaths[i]);
					if (prop.property == mp.property)
					{
						for (var j:int = 0; j < mp.keyframes.length; j++)
						{
							insertKeyframe(prop.keyframes, mp.keyframes[j]);
						}
						return;
					}
				}
			}
			else
			{
				motionPaths = new Vector.<MotionPath>();
			}
			motionPaths.push(mp);
		}
		
		override protected function initInstance(instance:IEffectInstance):void
		{
			var i:int;
			var adjustedDuration:Number = duration;
			
			var transformInstance:AnimateTransformInstance =
				AnimateTransformInstance(instance);

			if (motionPaths)
			{            
				var instanceAnimProps:Array = [];
				for (i = 0; i < motionPaths.length; ++i)
				{
					instanceAnimProps[i] = motionPaths[i].clone();
					var mp:MotionPath = MotionPath(instanceAnimProps[i]);
					if (mp.keyframes)
					{
						for (var j:int = 0; j < mp.keyframes.length; ++j)
						{
							var kf:Keyframe = Keyframe(mp.keyframes[j]);
							if (isNaN(kf.time))
								kf.time = duration;
							if (startDelay != 0)
								kf.time += startDelay;
						}
						adjustedDuration = Math.max(adjustedDuration, 
							mp.keyframes[mp.keyframes.length - 1].time);
					}
				}
				var globalStartTime:Number = getGlobalStartTime();
				for (i = 0; i < instanceAnimProps.length; ++i)
					transformInstance.addMotionPath(instanceAnimProps[i], globalStartTime);
			}

			if (transformInstance.initialized)
				return;
			transformInstance.initialized = true;
			
			if (!autoCenterTransform)
				transformInstance.transformCenter = 
					computeTransformCenterForTarget(instance.target);
			transformInstance.autoCenterTransform = autoCenterTransform;
			
			var tmpStartDelay:Number = startDelay;
			startDelay = 0;
			var tmpAnimProps:Vector.<MotionPath> = motionPaths;
			motionPaths = null;
			super.initInstance(instance);
			startDelay = tmpStartDelay;
			motionPaths = tmpAnimProps;
			transformInstance.duration = Math.max(duration, adjustedDuration);
			//使用KeyFrames控制缓动函数，而不使用设置的值
			if(getQualifiedClassName(this) != getQualifiedClassName(AnimateTransform))
				transformInstance.easer = linearEaser;
		}
		
		/**子效果默认的缓动函数*/
		private static var linearEaser:Linear = new Linear();
		
		private function getGlobalStartTime():Number
		{
			var globalStartTime:Number = 0;
			var parent:Effect = parentCompositeEffect;
			while (parent)
			{
				globalStartTime += parent.startDelay;
				if (parent is Sequence)
				{
					var sequence:Sequence = Sequence(parent);
					for (var i:int = 0; i < sequence.children.length; ++i)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
					{
						var child:Effect = sequence.children[i];
						if (child == this)
							break;
						if (child is CompositeEffect)
							globalStartTime += CompositeEffect(child).compositeDuration;
						else
							globalStartTime += child.startDelay + 
								(child.duration * child.repeatCount) +
								(child.repeatDelay + (child.repeatCount - 1));
					}
				}
				parent = parent.parentCompositeEffect;
			}        
			return globalStartTime;
		}
		
		private static var sharedObjectMaps:Dictionary = new Dictionary(true);
		private static var sharedObjectRefcounts:Dictionary = new Dictionary(true);
		/**
		 * 获取共享的实例
		 */
		private static function getSharedInstance(topmostParallel:Parallel , target:Object):IEffectInstance
		{
			if (topmostParallel != null)
			{
				var sharedObjectMap:Dictionary = Dictionary(sharedObjectMaps[topmostParallel]);
				if (sharedObjectMap != null)
					return sharedObjectMap[target];
			}
			return null;
		}
		
		private static function removeSharedInstance(topmostParallel:Parallel , target:Object):void
		{
			if (topmostParallel != null)
			{
				var sharedObjectMap:Dictionary = sharedObjectMaps[topmostParallel];
				if (!sharedObjectMap)
					return;
				if (sharedObjectMap[target])
				{
					delete sharedObjectMap[target];
					sharedObjectRefcounts[topmostParallel] -= 1;
					if (sharedObjectRefcounts[topmostParallel] <= 0)
					{
						delete sharedObjectMaps[topmostParallel];
						delete sharedObjectRefcounts[topmostParallel];
					}
				}
			}
		}
		
		private static function storeSharedInstance(topmostParallel:Parallel , target:Object , effectInstance:IEffectInstance):void
		{
			if (topmostParallel != null)
			{
				var sharedObjectMap:Dictionary = sharedObjectMaps[topmostParallel];
				if (!sharedObjectMap)
				{
					sharedObjectMap = new Dictionary();
					sharedObjectMaps[topmostParallel] = sharedObjectMap;
				}
				if (!sharedObjectMap[target])
				{
					if (!sharedObjectRefcounts[topmostParallel])
						sharedObjectRefcounts[topmostParallel] = 1;
					else
						sharedObjectRefcounts[topmostParallel] += 1;
				}                
				sharedObjectMap[target] = effectInstance;
			}
		}
		
	}
}
