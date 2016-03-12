package flower.display
{
	public class Bitmap extends DisplayObject
	{
		public function Bitmap()
		{
			var cls:* = System.Bitmap["class"];
			_show = new cls();
		}
	}
}