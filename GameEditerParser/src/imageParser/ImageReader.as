package imageParser
{
	import extend.ui.ImageLoader;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ReaderBase;

	public class ImageReader extends ReaderBase
	{
		private var image:ImageLoader;
		
		public function ImageReader()
		{
		}
		
		override public function showData(d:DirectionDataBase):void {
			this.title = d.desc==""?d.name:d.desc;
			this.icon = d.fileIcon;
			if(!image) {
				image = new ImageLoader();
				this.addElement(image);
			}
			image.source = ToolData.getInstance().project.getResURL(d.url);
			image.horizontalCenter = 0;
			image.verticalCenter = 0;
//			trace(ToolData.getInstance().project.getResURL(d.url));
		}
	}
}