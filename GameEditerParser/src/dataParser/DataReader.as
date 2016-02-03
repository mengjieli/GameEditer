package dataParser
{
	import egret.components.List;
	
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ReaderBase;
	
	import utils.FileHelp;

	public class DataReader extends ReaderBase
	{
		public function DataReader()
		{
		}
		
		private var list:List = new List();
		
		override public function showData(d:DirectionDataBase):void {
			this.title = FileHelp.getURLName(d.url);
			this.icon = d.fileIcon;
		}
	}
}