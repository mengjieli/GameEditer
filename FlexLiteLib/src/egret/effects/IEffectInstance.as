package egret.effects
{
	/**
	 * IEffectInstance 接口代表在目标上播放的效果实例。
	 * 每个目标都有与之相关联的单独效果实例。效果实例的生存期是短暂的。
	 * 在目标上播放效果时会创建一个实例，当效果完成播放时将破坏此实例。
	 * 如果目标上同时播放了多个效果（例如，Parallel 效果），则每个效果都有其单独的效果实例。 
	 */
	public interface IEffectInstance
	{
		/** 
		 * 效果的持续时间（以毫秒为单位）。
		 */
		function get duration():Number;
		function set duration(value:Number):void;
		
		/**
		 * 创建此 IEffectInstance 对象的 IEffect 对象。
		 */
		function get effect():IEffect;
		function set effect(value:IEffect):void;
		
		/**
		 * 效果的当前时间位置。
		 * 此属性的值介于 0 和总持续时间（包括该效果的 startDelay、repeatCount 和 repeatDelay）之间。
		 */
		function get playheadTime():Number;
		function set playheadTime(value:Number):void;
		
		/**
		 * 效果的重复次数。可能的值为任何大于等于 0 的整数。
		 */
		function get repeatCount():int;
		function set repeatCount(value:int):void;
		
		/**
		 * 重复播放效果前需要等待的时间（以毫秒为单位）。
		 */
		function get repeatDelay():int;
		function set repeatDelay(value:int):void;
		
		/**
		 * 开始播放效果前需要等待的时间（以毫秒为单位）。
		 * 此值可以是任何大于或等于 0 的整数。
		 * 如果使用 repeatCount 属性重复播放效果，则只在首次播放该效果时应用 startDelay 属性。
		 */
		function get startDelay():int;
		function set startDelay(value:int):void;
		
		/**
		 * 要应用此效果的 UIComponent 对象。
		 */
		function get target():Object;
		function set target(value:Object):void;
		
		/**
		 * 经过 startDelay 所占用的这段时间后，在目标上播放效果实例。
		 * 由 Effect 类调用。在启动 EffectInstance 时，请使用此函数，而非 play() 方法。
		 */
		function startEffect():void;
		
		/**
		 * 在目标上播放效果实例。改为调用 startEffect() 方法，以在 EffectInstance 上开始播放效果。 
		 * <p>在 EffectInstance 的子类中，必须覆盖此方法。
		 * 此覆盖必须调用 super.play() 方法，以便从目标中分派 effectStart 事件。</p>
		 */
		function play():void;
		
		/**
		 * 暂停效果，直到调用 resume() 方法。
		 */
		function pause():void;
		
		/**
		 * 停止播放效果，使目标保持当前状态。
		 * 您需要通过调用 Effect.stop() 方法来调用此方法。在实现过程中，它会调用 finishEffect() 方法。 
		 * <p>如果调用此方法来结束播放效果，效果实例将分派 effectEnd 事件。</p>
		 */
		function stop():void;
		
		/**
		 * 在效果由 pause() 方法暂停后继续播放效果。
		 */
		function resume():void;
		
		/**
		 * 从效果的当前位置开始反向播放效果。
		 */
		function reverse():void;
		
		/**
		 * 中断当前播放的效果实例，立即跳转到效果的结束位置。
		 * 通过调用 Effect.end() 方法可调用此方法。在实现过程中，它会调用 finishEffect() 方法。 
		 * <p>如果调用此方法来结束播放效果，效果实例将分派 effectEnd 事件。</p>
		 */
		function end():void;
		
		/**
		 * 在完成效果播放时由 end() 方法调用。此函数将为效果目标分派 endEffect 事件。 
		 */
		function finishEffect():void;
		
		/**
		 * 每次完成重复效果的迭代播放后调用。 
		 */
		function finishRepeat():void;
	}
}
