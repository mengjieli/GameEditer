package main.panels.directionView
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.ui.components.TabPanel;
	import egret.ui.components.Tree;
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.data.gameProject.GameProjectData;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	import main.events.ToolEvent;
	import main.panels.components.DirectionTreeCollection;
	import main.panels.netWaitPanel.NetWaitingPanel;

	public class DirectionView extends TabPanel
	{
		private var bg:Group;
		private var project:GameProjectData;
		
		public function DirectionView()
		{
			this.title = "项目目录";
			this.percentWidth = this.percentHeight = 100;
			
			EventMgr.ist.addEventListener(ToolEvent.START,start);
			EventMgr.ist.addEventListener(ProjectEvent.SHOW_PROJECT,onShowProject);
			EventMgr.ist.addEventListener(ProjectEvent.ADD_DIRECTION,onAddDirection);
		}
		
		private var data:DirectionTreeCollection;
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			var tree:Tree = new Tree();
			tree.itemRenderer = DirectionViewItem;
			this.addElement(tree);
			tree.percentWidth = 100;
			tree.percentHeight = 100;
			tree.iconField = "icon";
			this.addElement(tree);
			
			data = new DirectionTreeCollection();
			tree.dataProvider = data;
			
			this.addElement(bg = new Group());
			bg.percentWidth = bg.percentHeight = 100;
			var maskBg:UIAsset;
			maskBg = new UIAsset("assets/alpha.png");
			maskBg.percentWidth = 100;
			maskBg.percentHeight = 100;
			bg.addElement(maskBg);
			var label:Label = new Label();
			label.size = 16;
			label.text = "点击加载项目";
			label.verticalCenter = 0;
			label.horizontalCenter = 0;
			bg.addElement(label);
			
			bg.addEventListener(MouseEvent.CLICK,onLoadProject);
		}
		
		private function start(e:ToolEvent):void {
			var url:String = ToolData.getInstance().getConfigValue("project","ui");
			if(url != "") {
				EventMgr.ist.dispatchEvent(new ProjectEvent(ProjectEvent.LOAD_PROJECT,null,url));
			}
		}
		
		private function onShowProject(e:ProjectEvent):void {
			project = e.project;
			var url:String = e.project.url;
			while(url.charAt(url.length-1) == "/") {
				url = url.slice(0,url.length-1);
			}
			ToolData.getInstance().saveConfigValue("project",url,"ui");
			bg.visible = false;
			data.removeAll();
			var initPath:Vector.<DirectionDataBase> = e.project.getInitPath();
			NetWaitingPanel.show("加载项目资源 ...");
			for(var i:int = 0; i < initPath.length; i++) {
				var dir:DirectionDataBase = initPath[i];
				data.addFile(dir,false);
				if(dir.initLoad) {
					dir.initLoad.call(dir);
				}
			}
			NetWaitingPanel.hide();
		}
		
		private function onAddDirection(e:ProjectEvent):void {
			data.addFile(e.direction);
			data.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,false,false,CollectionEventKind.REFRESH));
		}
		
		private function onLoadProject(e:MouseEvent):void {
			FileUtil.browseForOpen(selectProjectFile,1,[new FileFilter("GameEditer项目","*.json")],"加载GameEditer项目","");
		}
		
		private function selectProjectFile(file:File):void {
			trace(file.url);
		}
	}
}