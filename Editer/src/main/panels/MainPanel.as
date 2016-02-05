package main.panels
{
	import egret.collections.ArrayCollection;
	import egret.components.Group;
	import egret.events.UIEvent;
	import egret.ui.components.DropDownList;
	
	import main.data.ToolData;
	import main.menu.MenuID;
	import main.panels.cehuaPanel.CeHuaPanel;
	import main.panels.components.ClipItemPanel;
	import main.panels.components.StatusBar;
	import main.panels.components.ToolsBar;
	import main.panels.mainlayout.LeftPanel;
	import main.panels.mainlayout.RightPanel;

	public class MainPanel extends Group
	{
		private var container:Group;
		//程序员
		private var coderContainer:Group;
		//策划
		private var cehuContainer:Group;
		private var typeDrop:DropDownList;
		private var toolBar:ToolsBar;
		
		public function MainPanel()
		{
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			toolBar=new ToolsBar();
			toolBar.percentWidth=100;
			toolBar.height=30;
			this.addElement(toolBar);
			
			var drop:DropDownList = new DropDownList();
			typeDrop = drop;
			drop.width = 100;
			drop.y = 3;
			this.addElement(drop);
			drop.addEventListener(UIEvent.VALUE_COMMIT,onTypeChange);
			drop.right = 0;
			var data:ArrayCollection = new ArrayCollection();
			data.addItem({label:"程序员",value:"coder"});
			data.addItem({label:"策划",value:"cehua"});
			data.addItem({label:"美术",value:"artic"});
			drop.dataProvider = data;
			
			container = new Group();
			container.percentWidth = 100;
			container.top = 30;
			container.bottom = 30;
			this.addElement(container);
			
			var stateBar:StatusBar = new StatusBar();
			this.addElement(stateBar);
			stateBar.height = 30;
			stateBar.bottom = 0;
			stateBar.percentWidth = 100;
			
			var value:String = ToolData.getInstance().getConfigValue("editerType");
			if(value) {
				var find:Boolean = false;
				for(var i:Number = 0; i < data.length; i++) {
					var item:Object = data.getItemAt(i);
					if(item.value == value) {
						drop.selectedIndex = i;
						find = true;
						break;
					}
				}
				if(!find) {
					drop.selectedIndex = 0;
				}
			} else {
				drop.selectedIndex = 0;
			}
		}
		
		private function onTypeChange(e:UIEvent):void {
			var type:String = typeDrop.selectedItem.value;
			ToolData.getInstance().saveConfigValue("editerType",type);
			container.removeAllElements();
			toolBar.removeAllElements();
			switch(type) {
				case "coder":
					if(!coderContainer) {
						coderContainer = new Group();
						coderContainer.percentWidth = 100;
						coderContainer.percentHeight = 100;
						
						var clipItemPanel:ClipItemPanel;//横向分割容器
						var statusBar:StatusBar;//状态栏
						
						clipItemPanel=new ClipItemPanel();
						clipItemPanel.top = 0;
						clipItemPanel.bottom = 0;
						clipItemPanel.percentWidth = 100;
						clipItemPanel.addClipItem(new LeftPanel(),new RightPanel());
						coderContainer.addElement(clipItemPanel);
					}
					container.addElement(coderContainer);
					//创建工具栏菜单
					toolBar.dataProvider=new XMLList(
						'<node icon="assets/new.png" id="'+ MenuID.NEW +'" tooltip="新建游戏项目"/>'
						+ '<node  type="spliter"/>'
						+ '<node  icon="assets/ui/button/addAction.png" id="'+MenuID.CONNECT_MOBILE+'"  tooltip="链接游戏客户端"/>'
						+ '<node  type="spliter"/>'
						+ '<node  icon="assets/ui/button/refresh.png" id="'+MenuID.RELOAD_PARSERS+'"  tooltip="重新载入解析器"/>'
						+ '<node  type="spliter"/>'
						+ '<node  icon="assets/help.png" id="'+MenuID.HELP+'"  tooltip="帮助"/>'
					);
					break;
				case "cehua":
					if(!cehuContainer) {
						cehuContainer = new Group();
						cehuContainer.percentHeight = 100;
						cehuContainer.percentWidth = 100;
						
						var cehua:CeHuaPanel = new CeHuaPanel();
						cehua.percentHeight = 100;
						cehua.percentWidth = 100;
						cehuContainer.addElement(cehua);
					}
					container.addElement(cehuContainer);
					//创建工具栏菜单
					toolBar.dataProvider=new XMLList(
						'<node  icon="assets/add.png" id="'+MenuID.CONNECT_MOBILE+'"  tooltip="链接游戏客户端"/>'
						+ '<node  type="spliter"/>'
						+ '<node  icon="assets/help.png" id="'+MenuID.HELP+'"  tooltip="帮助"/>'
					);
					break;
			}
		}
	}
}