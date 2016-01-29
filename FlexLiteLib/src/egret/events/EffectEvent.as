package egret.events
{
	import flash.events.Event;
	
	import egret.effects.IEffectInstance;
	
	/**
	 * 动画特效事件
	 * @author dom
	 */	
	public class EffectEvent extends Event
	{
		/**
		 * 动画播放结束
		 */		
		public static const EFFECT_END:String = "effectEnd";
		/**
		 * 动画播放被停止
		 */		
		public static const EFFECT_STOP:String = "effectStop";
		/**
		 * 动画播放开始
		 */		
		public static const EFFECT_START:String = "effectStart";
		/**
		 * 动画开始重复播放
		 */		
		public static const EFFECT_REPEAT:String = "effectRepeat";
		/**
		 * 动画播放更新
		 */		
		public static const EFFECT_UPDATE:String = "effectUpdate";
		
		/**
		 * 构造函数
		 */		
		public function EffectEvent(eventType:String, bubbles:Boolean = false,
									cancelable:Boolean = false,
									effectInstance:IEffectInstance = null)
		{
			super(eventType, bubbles, cancelable);
			this.effectInstance = effectInstance;
		}
		
		/**
		 * 事件的效果实例对象。您可以使用此属性从事件侦听器中访问效果实例对象的属性。
		 */
		public var effectInstance:IEffectInstance;
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new EffectEvent(type, bubbles, cancelable, effectInstance);
		}
	}
	
}
