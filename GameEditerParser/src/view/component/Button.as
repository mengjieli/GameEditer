package view.component
{
	import view.component.data.ButtonData;

	public class Button extends ComponentBase
	{
		
		public function Button(data:ButtonData)
		{
			super(data);
		}
		
		override public function decodeByStyle(styleData:Object,styleURL:String):void {
			this.styleData = styleData;
//			this.show.source = styleData.up;
		}
	}
}