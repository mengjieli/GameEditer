package dataParser
{
	import flash.events.MouseEvent;
	
	import egret.collections.ArrayCollection;
	import egret.components.Label;
	import egret.components.List;
	
	import extend.ui.Input;
	
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ReaderBase;
	

	public class DataReader extends ReaderBase
	{
		private var list:List;
		private var listData:ArrayCollection;
		private var nameLabel:Input;
		private var descLabel:Input;
		private var dir:DataData;
		
		public function DataReader()
		{
			this.addEventListener(MouseEvent.CLICK,click);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			
			var label:Label = new Label();
			label.text = "名称:";
			label.x = 5;
			label.y = 5;
			this.addElement(label);
			
			nameLabel = new Input();
			nameLabel.border = true;
			nameLabel.backgorund = true;
			nameLabel.width = 150;
			nameLabel.height = 20;
			nameLabel.x = 40;
			nameLabel.y = 5;
			nameLabel.textColor = 0;
			this.addElement(nameLabel);
			
			label = new Label();
			label.text = "描述:";
			label.x = 205;
			label.y = 5;
			this.addElement(label);
			
			descLabel = new Input();
			descLabel.border = true;
			descLabel.backgorund = true;
			descLabel.width = 150;
			descLabel.height = 20;
			descLabel.x = 240;
			descLabel.y = 5;
			descLabel.textColor = 0;
			this.addElement(descLabel);
			
			list = new List();
			list.percentWidth = 100;
			list.top = 30;
			list.bottom = 0;
			list.itemRenderer = DataListItem;
			list.itemRendererSkinName = DataListItemSkin;
			listData = new ArrayCollection();
			list.dataProvider = listData;
			this.addElement(list);
			
			if(data) {
				showData(dir);
			}
		}
		
		private function click(e:MouseEvent):void {
			trace("1");
		}
		
		override public function showData(d:DirectionDataBase):void {
			dir = d as DataData;
			if(list) {
				listData.removeAll();
				this.title = d.nameDesc;
				this.icon = d.fileIcon;
				nameLabel.text = dir.dataName;
				descLabel.text = dir.dataDesc;
				for(var i:int = 0; i < dir.members.length; i++) {
					listData.addItem(dir.members[i]);
				}
			}
		}
	}
}