package uistyle
{
	import egret.collections.ArrayCollection;
	import egret.components.Label;
	import egret.components.List;
	
	import main.data.parsers.ReaderBase;

	public class StyleReaderBase extends ReaderBase
	{
		protected var resourceList:List;
		protected var listData:ArrayCollection;
		
		public function StyleReaderBase()
		{
			var label:Label = new Label();
			label.text = "资源列表";
			label.x = 150;
			label.y = 10;
			this.addElement(label);
			
			resourceList = new List();
			resourceList.x = 30;
			resourceList.top = 50;
			resourceList.bottom = 30;
			resourceList.width = 280;
			resourceList.itemRenderer = StyleListItem;
			resourceList.itemRendererSkinName = StyleListItemSkin;
			listData = new ArrayCollection();
			resourceList.dataProvider = listData;
			this.addElement(resourceList);
		}
	}
}