package imageParser
{
	import extend.ui.ImageLoader;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;

	public class ImageData extends DirectionDataBase
	{
		
		public function ImageData()
		{
			this.dragFlag = true;
		}
		
		override public function set url(val:String):void {
			super.url = val;
			if(!this.dragShow && url != "") {
				dragShow = new ImageLoader(ToolData.getInstance().project.getResURL(url));
			}
		}
	}
}