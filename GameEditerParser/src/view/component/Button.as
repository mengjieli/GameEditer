package view.component
{
	public class Button extends ComponentBase
	{
		
		public function Button()
		{
		}
		
		override public function decodeByStyle(styleData:Object,styleURL:String):void {
			this.styleData = styleData;
			this.show.source = styleData.up;
		}
	}
}