package egret.effects.effectClasses
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import egret.core.ns_egret;
	import egret.effects.animation.Animation;
	import egret.effects.animation.Keyframe;
	import egret.effects.animation.MotionPath;
	
	use namespace ns_egret;
	
	/**
	 * AnimateTransformInstance 类用于实现 AnimateTransform 效果的实例类
	 */
	public class AnimateTransformInstance extends AnimateInstance
	{

		public function AnimateTransformInstance(target:Object)
		{
			super(target);
		}
		
		/**
		 * 变换效果开始的标志
		 */
		private var started:Boolean = false;
		
		private var instanceStartTime:Number = 0;
		
		/**
		 * 储存当前的属性值
		 */
		private var currentValues:Object = {
			rotation:NaN,
			scaleX:NaN, scaleY:NaN,
			translationX:NaN, translationY:NaN};
		
		/**
		 * 如果为 true，则已经初始化与该转换相关的效果的此单一实例。
		 * 此属性供 AnimateTransform 使用，以防止在将多个转换效果集成到此单一实例中时重复初始化该实例。
		 */
		public var initialized:Boolean = false;
		
		/**
		 * 中心，此效果中的转换是围绕其发生的。特别是，旋转会围绕此点旋转，平移会移动此点，而缩放会以此点为中心进行缩放。
		 * 如果 autoCenterTransform 为 true，则将忽略此属性。
		 * 如果 autoCenterTransform 为 false 且未提供 transformCenter，则会使用目标对象的中心。
		 */
		public var transformCenter:Point;
		
		public var autoCenterTransform:Boolean;
		
		override public function startEffect():void
		{
			if (!started)
			{
				started = true;
				super.startEffect();
			}
		}
		
		private function isValidValue(value:Object):Boolean
		{
			return ((value is Number && !isNaN(Number(value))) ||
				(!(value is Number) && value !== null));
		}
		
		private function insertKeyframe(keyframes:Vector.<Keyframe>, 
										newKF:Keyframe, startDelay:Number = 0, first:Boolean = false):void
		{
			newKF.time += startDelay;
			for (var i:int = 0; i < keyframes.length; i++)
			{
				if (keyframes[i].time >= newKF.time)
				{
					if (keyframes[i].time == newKF.time)
					{
						if (first)
						{
							newKF.time += .01;
							keyframes.splice(i+1, 0, newKF);
						}
						else
						{
							newKF.time -= .01;
							keyframes.splice(i, 0, newKF);
						}
					}
					else
					{
						keyframes.splice(i, 0, newKF);
					}
					return;
				}
			}
			keyframes.push(newKF);
		}
		
		/**
		 * 使用相对于最外侧的 parent 效果的开始时间，将一个 MotionPath 对象添加到此实例中的 MotionPath 对象集中。
		 * 对于在与新的 MotionPath 对象相同的属性上起作用的此效果实例，
		 * 如果已经存在一个 MotionPath 对象，则只会将新 MotionPath 的关键帧添加到现有 MotionPath 中。
		 */
		public function addMotionPath(newMotionPath:MotionPath, newEffectStartTime:Number = 0):void
		{
			var added:Boolean = false;
			if (motionPaths)
			{
				var i:int;
				var j:int;
				var mp:MotionPath;
				var n:int = motionPaths.length;
				if (newEffectStartTime < instanceStartTime)
				{
					var deltaStartTime:Number = instanceStartTime - newEffectStartTime;
					for (i = 0; i < n; i++)
					{
						mp = MotionPath(motionPaths[i]);
						for (j = 0; j < mp.keyframes.length; j++)
							mp.keyframes[j].time += deltaStartTime;
					}
					instanceStartTime = newEffectStartTime;
				}
				for (i = 0; i < n; i++)
				{
					mp = MotionPath(motionPaths[i]);
					if (mp.property == newMotionPath.property)
					{
						for (j = 0; j < newMotionPath.keyframes.length; j++)
						{
							insertKeyframe(mp.keyframes, newMotionPath.keyframes[j], 
								(newEffectStartTime - instanceStartTime), (j == 0));
						}
						added = true;
						break;
					}
				}
			}
			else
			{
				motionPaths = new Vector.<MotionPath>();
				instanceStartTime = newEffectStartTime;
			}
			if (!added)
			{
				if (newEffectStartTime > instanceStartTime)
				{
					for (j = 0; j < newMotionPath.keyframes.length; j++)
						newMotionPath.keyframes[j].time += 
							(newEffectStartTime - instanceStartTime);
				}
				motionPaths.push(newMotionPath);
			}
			n = motionPaths.length;
			for (i = 0; i < n; i++)
			{
				mp = MotionPath(motionPaths[i]);
				var kf:Keyframe = mp.keyframes[mp.keyframes.length-1];
				if (!isNaN(kf.time))
					duration = Math.max(duration, kf.time);
			}
		}
		
		override public function play():void
		{
			if (motionPaths)
			{
				var i:int;
				var j:int;
				updateTransformCenter();
				var adjustXY:Boolean = (transformCenter.x != 0 || transformCenter.y != 0);
				
				for (i = 0; i < motionPaths.length; ++i)
				{
					var animProp:MotionPath = motionPaths[i];
					if (adjustXY && 
						(animProp.property == "translationX" || 
							animProp.property == "translationY"))
					{
						for (j = 0; j < animProp.keyframes.length; ++j)
						{
							var kf:Keyframe = animProp.keyframes[j];
							if (isValidValue(kf.value))
							{
								if (animProp.property == "translationX")
								{
									kf.value += transformCenter.x;
								}
								else
								{
									kf.value += transformCenter.y;
								}
							}
						}
					}
				}
			}
			super.play();
		}
		
		override public function animationEnd(animation:Animation):void
		{
			started = false;
			super.animationEnd(animation);
		}
		
		private function updateTransformCenter():void
		{
			if (!transformCenter)
				transformCenter = new Point(0,0);
			if (autoCenterTransform)
			{
				transformCenter.x = target.width / 2;
				transformCenter.y = target.height / 2;
			}
		}

		override protected function getCurrentValue(property:String):*
		{
			switch(property)
			{
				case "translationX":
				case "translationY":
				{
					updateTransformCenter();
					var position:Point = TransformUtil.transformPointToParent(target as DisplayObject,transformCenter);
					if (property == "translationX")
						return position.x;
					if (property == "translationY")
						return position.y;
					break;
				}            
				default:
					return super.getCurrentValue(property);
			}
		}
		
		private static var position:Point = new Point();
		override protected function applyValues(anim:Animation):void
		{
			var tmpScaleX:Number;
			var tmpScaleY:Number;
			var tmpPosition:Point;
			var tmpRotation:Number;
			
			for (var i:int = 0; i < motionPaths.length; ++i)
			{
				if (currentValues[motionPaths[i].property] !== undefined)
					currentValues[motionPaths[i].property] = 
						anim.currentValue[motionPaths[i].property];
				else
					setValue(motionPaths[i].property, 
						anim.currentValue[motionPaths[i].property]);
			}
			
			tmpRotation = !isNaN(currentValues.rotation) ? 
				currentValues.rotation : getCurrentValue("rotation");
			tmpScaleX = !isNaN(currentValues.scaleX) ? 
				currentValues.scaleX : getCurrentValue("scaleX");
			tmpScaleY = !isNaN(currentValues.scaleY) ? 
				currentValues.scaleY : getCurrentValue("scaleY");
			
			position.x = !isNaN(currentValues.translationX) ? 
				currentValues.translationX : 
				getCurrentValue("translationX");
			position.y = !isNaN(currentValues.translationY) ? 
				currentValues.translationY : 
				getCurrentValue("translationY");
			
			if(!lastTranslationPoint)
				lastTranslationPoint = position.clone();
			if(isNaN(currentValues.translationX) && Math.abs(position.x-lastTranslationPoint.x)<0.1)
				position.x = lastTranslationPoint.x;
			if(isNaN(currentValues.translationY) && Math.abs(position.y-lastTranslationPoint.y)<0.1)
				position.y = lastTranslationPoint.y;
			lastTranslationPoint.x = position.x;
			lastTranslationPoint.y = position.y;
			tmpPosition = position;
			
			TransformUtil.transformAround(target as DisplayObject,
				transformCenter,tmpPosition,tmpScaleX,tmpScaleY,tmpRotation);
		}
		
		/**
		 * 记录上次中心点的位置，当当前计算的中心点和上次位置相差不大时为了防止误差，
		 * 就使用上次的值。
		 */
		private var lastTranslationPoint:Point;
	}
}