package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 可翻页窗的事件
	 * @author 雷羽佳
	 * 
	 */	
	public class ViewStackPageEvent extends Event
	{
		/**
		 * 验证项目属性是否通过
		 */
		public static const VALIDATE:String = "validate";
		
		/**
		 * 验证结果
		 */
		public var result:Boolean;
		
		public function ViewStackPageEvent(type:String)
		{
			super(type);
		}
	}
}