package flower.events
{
	public class TouchEvent extends Event
	{
		public static const TOUCH_BEGIN:String = "touch_begin";
		public static const TOUCH_MOVE:String = "touch_move";
		public static const TOUCH_END:String = "touch_end";
		
		public var touchX:int;
		public var touchY:int;
		public var stageX:int;
		public var stageY:int;
		
		public function TouchEvent(type:String,bubbles:Boolean=true)
		{
			super(type,bubbles);
		}
	}
}