package flower.events
{
	public class IOErrorEvent extends Event
	{
		public static const ERROR:String = "error";
		
		public function IOErrorEvent(type:String)
		{
			super(type);
		}
	}
}