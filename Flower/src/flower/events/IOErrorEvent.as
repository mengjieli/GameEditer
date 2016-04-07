package flower.events
{
	public class IOErrorEvent extends Event
	{
		public static const ERROR:String = "error";
		
		public var message:String;
		
		public function IOErrorEvent(type:String,message:String)
		{
			super(type);
		}
	}
}