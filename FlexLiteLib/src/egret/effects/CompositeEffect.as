package egret.effects
{
	import egret.core.ns_egret;
	import egret.effects.effectClasses.CompositeEffectInstance;
	
	use namespace ns_egret;
	
	/**
	 * 复合效果类
	 */
	public class CompositeEffect extends Effect
	{
		
		public function CompositeEffect(target:Object = null)
		{
			super(target);
			instanceClass = CompositeEffectInstance;
		}   
		
		private var childTargets:Array;
		
		private var _children:Array = [];
		/**
		 * 包含此 CompositeEffect 的子效果的数组。
		 */
		public function get children():Array
		{
			return _children;
		}
		public function set children(value:Array):void
		{
			var i:int;
			if (_children)
				for (i = 0; i < _children.length; ++i)
					if (_children[i])
						Effect(_children[i]).parentCompositeEffect = null;
			_children = value;
			if (_children)
				for (i = 0; i < _children.length; ++i)
					if (_children[i])
						Effect(_children[i]).parentCompositeEffect = this;
		}
		
		/**
		 * 返回此效果的持续时间，由所有子效果的持续时间进行定义。
		 * 这会考虑所有子效果的 startDelay 和重复信息，以及其持续时间，并返回相应的结果。
		 */
		public function get compositeDuration():Number
		{
			return duration;
		}

		/**
		 * @inheritDoc
		 */
		override public function createInstance(target:Object = null):IEffectInstance
		{
			if (!childTargets)
				childTargets = [ target ];
			
			var newInstance:IEffectInstance = super.createInstance(target);
			
			childTargets = null;
			
			return newInstance;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function createInstances(targets:Array = null):Array
		{
			if (!targets)
				targets = this.targets;
			
			childTargets = targets;
			var newInstance:IEffectInstance = createInstance();
			childTargets = null;
			return newInstance ? [ newInstance ] : [];
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function initInstance(instance:IEffectInstance):void
		{
			super.initInstance(instance);
			
			var compInst:CompositeEffectInstance = CompositeEffectInstance(instance);
			
			var targets:Object = childTargets;
			if (!(targets is Array))
				targets = [ targets ];
			
			if (children)
			{
				var n:int = children.length;
				for (var i:int = 0; i < n; i++)
				{
					var childEffect:Effect = children[i];
					
					if (childEffect.targets.length == 0)
					{
						compInst.addChildSet(
							children[i].createInstances(targets));  
					}
					else
					{
						compInst.addChildSet(
							children[i].createInstances(childEffect.targets));
					}   
				}
			}       
		}   
		
		/**
		 * 将新的子效果添加到此复合效果。
		 * Sequence 效果按照子效果的添加顺序播放子效果，一次播放一个。
		 * Parallel 效果同时播放所有子效果；添加子效果的顺序无关紧要。
		 */
		public function addChild(childEffect:Effect):void
		{
			children.push(childEffect);
			Effect(childEffect).parentCompositeEffect = this;
		}
	}
	
}
