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
			this.dragType = "image";
		}
		
		
		override public function get dragShow():ImageLoader {
			if(url != "") {
				return new ImageLoader(ToolData.getInstance().project.getResURL(url));
			}
			return null;
		}
	}
}