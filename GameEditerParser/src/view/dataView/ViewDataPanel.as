package view.dataView
{
	import egret.collections.ArrayCollection;
	import egret.components.List;
	import egret.events.ListEvent;
	import egret.events.UIEvent;
	import egret.ui.components.DropDownList;
	import egret.ui.components.TabPanel;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	
	import view.ViewData;

	public class ViewDataPanel extends TabPanel
	{
		private var viewData:ViewData;
		private var dataView:DropDownList;
		private var list:ArrayCollection;
		private var memberView:List;
		private var memberList:ArrayCollection;
		private var dataList:Vector.<DirectionDataBase> = new Vector.<DirectionDataBase>();
		private var tipName:Vector.<String> = new Vector.<String>();
		
		public function ViewDataPanel()
		{
			this.title = "视图数据";
			
			dataView = new DropDownList();
			dataView.percentWidth = 100;
			this.addElement(dataView);
			dataView.addEventListener(UIEvent.VALUE_COMMIT,onDataChange);
			
			memberView = new List();
			memberView.itemRenderer = ViewDataItem;
			this.addElement(memberView);
			memberView.top = 25;
			memberView.bottom = 0;
			memberView.percentWidth = 100;
			memberList = new ArrayCollection();
			memberView.dataProvider = memberList;
			memberView.addEventListener(egret.events.ListEvent.ITEM_CLICK,onClickItem);
			
			list = new ArrayCollection();
			dataView.dataProvider = list;
			
		}
		
		private function onDataSourceChange():void {
			var d:Vector.<DirectionDataBase> = ToolData.getInstance().project.getAllTypeOfRes("Data");
			memberList.removeAll();
			list.addItem({label:"无数据",data:null});
			for(var i:int = 0; i < d.length; i++) {
				if(d[i].url == viewData.panel.data) {
					dataView.selectedIndex = i;
					showData(d[i]);
				}
				list.addItem({label:d[i].nameDesc,data:d[i]});
			}
			if( dataView.selectedIndex == -1) {
				dataView.selectedIndex = 0;
			}
		}
		
		public function showView(d:ViewData):void {
			this.viewData = d;
			this.onDataSourceChange();
		}
		
		private function onDataChange(e:UIEvent):void {
			var item:* = this.dataView.selectedItem.data;
			if(item == null) {
				memberList.removeAll();
				this.viewData.panel.data = "";
				dataList = new Vector.<DirectionDataBase>();
				tipName = new Vector.<String>();
			} else {
				dataList = new Vector.<DirectionDataBase>();
				tipName = new Vector.<String>();
				this.viewData.panel.data =  item.url;
				showData(item);
			}
		}
		
		private function showData(d:*):void {
			memberList.removeAll();
			var tipBefore:String = "data.";
			for(var i:int = 0; i < tipName.length; i++) {
				tipBefore += tipName[i] + ".";
			}
			if(dataList.length) {
				var tip:String = "";
				for(var i:int = 0; i < dataList.length; i++) {
					tip += dataList[i].dataName + (i<dataList.length-1?".":"");
				}
				memberList.addItem({label:"返回上一级:" + dataList[dataList.length-1].nameDesc,back:true,link:getLinkData(dataList[dataList.length-1].name),toolTip:tip});
			}
			for(var i:int = 0; i < d.members.length; i++) {
				var type:String = d.members[i].type;
				memberList.addItem({label:d.members[i].nameDesc,link:getLinkData(type),toolTip:tipBefore + d.members[i].name,name:d.members[i].name});
			}
			dataList.push(d);
		}
		
		private function onClickItem(e:ListEvent):void {
			var item:Object = e.item;
			if(item.link) {
				if(item.back) {
					dataList.pop();
					dataList.pop();
					tipName.pop();
				} else {
					tipName.push(item.name);
				}
				showData(item.link);
			}
		}
		
		private function getLinkData(name:String):DirectionDataBase {
			for(var i:int = 0; i < list.length; i++) {
				if(list[i].data && list[i].data.dataName == name) {
					return list[i].data;
				}
			}
			return null;
		}
	}
}