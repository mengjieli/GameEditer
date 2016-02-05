package dataParser
{
	import egret.components.supportClasses.ItemRenderer;
	
	import extend.ui.Input;

	public class DataListItem extends ItemRenderer
	{
		public function DataListItem()
		{
			this.height = 25;
		}
		
		public var nameTxt:Input;
		public var descTxt:Input;
		public var typeTxt:Input;
		public var typeValueTxt:Input;
		
		override public function set data(value:Object):void {
			super.data = value;
			var d:DataItem = value as DataItem;
			nameTxt.text = d.name;
			descTxt.text = d.desc;
			typeTxt.text = d.type;
			typeValueTxt.text = d.typeValue;
		}
	}
}