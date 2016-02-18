package uistyle.button
{
	import main.data.directionData.DirectionDataBase;
	
	import uistyle.StyleReaderBase;

	public class ButtonStyleReader extends StyleReaderBase
	{
		public function ButtonStyleReader()
		{
		}
		
		override public function showData(d:DirectionDataBase):void {
			super.showData(d);
			this.title = d.desc==""?d.name:d.desc;
			this.icon = d.fileIcon;
			var btnData:ButtonStyleData = d as ButtonStyleData;
			this.listData.removeAll();
			this.listData.addItem(btnData.up);
			this.listData.addItem(btnData.down);
			this.listData.addItem(btnData.disabled);
			//			trace(ToolData.getInstance().project.getResURL(d.url));
		}
	}
}