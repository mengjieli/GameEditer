package main.data.parsers
{

	import egret.ui.components.TabPanel;
	
	import main.data.directionData.DirectionDataBase;

	public class ReaderBase extends TabPanel
	{
		protected var _changeFlag:Boolean = false;
		
		public function ReaderBase()
		{
			_data.panel = this;
		}
		
		public function get readerName():String {
			return "";
		}
		
		public function showData(d:DirectionDataBase):void {
			trace("显示内容",d.url);
		}
		
		public function get changeFlag():Boolean {
			return this._changeFlag;
		}
	}
}