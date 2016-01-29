package egret.utils.app
{
	import flash.events.Event;
	
	/**
	 * 应用程序间通讯事件
	 */
	public class AppConnectionEvent extends Event
	{
		/**
		 * 接收到消息
		 */
		public static const RECEIVE:String = "receive";
		
		/**
		 * 发送了消息
		 */
		public static const SEND:String = "send";

		
		public function AppConnectionEvent(type:String, messageName:String , args:Array = null)
		{
			super(type, bubbles, cancelable);
			this.messageName = messageName;
			this.args = args;
		}
		
		/**
		 * 相关联的应用程序ID
		 */
		public var appID:String;
		
		/**
		 * 发送结果
		 */
		public var result:Boolean = true;
		
		/**
		 * 消息名称
		 */
		public var messageName:String;
		
		/**
		 * 消息的参数
		 */
		public var args:Array;
		
	}
}