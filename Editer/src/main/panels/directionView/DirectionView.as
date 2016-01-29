package main.panels.directionView
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.ui.components.TabPanel;
	import egret.ui.components.Tree;
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.gameProject.path.PathData;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	import main.panels.components.DirectionTreeCollection;

	public class DirectionView extends TabPanel
	{
		private var bg:Group;
		
		public function DirectionView()
		{
			this.title = "项目目录";
			this.percentWidth = this.percentHeight = 100;
			
			EventMgr.ist.addEventListener(ProjectEvent.SHOW_PROJECT,onShowProject);
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
		
		private function onShowProject(e:ProjectEvent):void {
			ToolData.getInstance().saveConfigValue("project",e.project.url);
			bg.visible = false;
		}
		
		private function onLoadProject(e:MouseEvent):void {
			FileUtil.browseForOpen(selectProjectFile,1,[new FileFilter("GameEditer项目","*.json")],"加载GameEditer项目","");
		}
		
		private function selectProjectFile(file:File):void {
			trace(file.url);
		}
		
		private function initDirection():void {
			data.removeAll();
			var paths:Vector.<PathData> = ToolData.getInstance().project.paths;
			for(var i:int = 0; i < paths.length; i++) {
				var path:PathData = paths[i];
				data.addFile(path.name,path.nameDesc,path.url,"direction");
			}
		}
	}
}