package
{
	import flash.display.Sprite;
	
	import flower.Engine;
	import flower.res.Res;
	
	[SWF(width="960",height="640")]
	public class Flower extends flash.display.Sprite
	{
		public function Flower()
		{
			if(System.IDE == "flash") {
				System.stage = this["stage"];
				Res.local = false;
				Res.serverURL = "http://localhost:5000/"
			} else {
				Res.local = true;
				Res.localURL = "";
			}
			new Engine();
			Engine.getInstance().showDebugTool();
		}
	}
}