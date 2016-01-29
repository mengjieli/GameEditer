package egret.events
{
	
	import flash.events.Event;
	
	/**
	 * 补间效果的事件对象
	 */
	public class TweenEvent extends Event
	{
		/**
		 * 补间动画结束
		 */
		public static const TWEEN_END:String = "tweenEnd";
		
		/**
		 * 补间动画开始
		 */
		public static const TWEEN_START:String = "tweenStart";
		
		/**
		 * 补间动画更新
		 */
		public static const TWEEN_UPDATE:String = "tweenUpdate";

		public function TweenEvent(type:String, bubbles:Boolean = false,
								   cancelable:Boolean = false,
								   value:Object = null)
		{
			super(type, bubbles, cancelable);
			
			this.value = value;
		}
		
		/**
		 * 对于 tweenStart 或 tweenUpdate 事件，此值传递给 onTweenUpdate() 方法；
		 * 而对于 tweenEnd 事件，此值则传递给 onTweenEnd() 方法。
		 */
		public var value:Object;
		
		override public function clone():Event
		{
			return new TweenEvent(type, bubbles, cancelable, value);
		}
	}
	
}
