package main.model.projectModel
{
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.gameProject.GameProjectData;
	import main.events.EventMgr;
	import main.events.ProjectEvent;
	import main.panels.netWaitPanel.NetWaitingPanel;
	
	import utils.FileHelp;

	public class ProjectModel
	{
		public function ProjectModel()
		{
			EventMgr.ist.addEventListener(ProjectEvent.LOAD_PROJECT,onLoadProject);
		}
		
		private var loadProject:GameProjectData;
		private var loadJsons:Vector.<File>;
		private var jsonIndex:int;
		private var nextProgress:int;
		
		private function onLoadProject(e:ProjectEvent):void {
			NetWaitingPanel.show("加载项目 \"" + e.project.name + "\"");
			loadProject = e.project;
			setTimeout(loadProjectConfig,0);
		}
		
		private function loadProjectConfig():void {
			//加载配置文件
			var config:Object = JSON.parse(FileUtil.openAsString(loadProject.url + "GameProject.json"));
			
			//加载 res 下所有json文件
			loadJsons = FileHelp.getFileListWidthEnd(new File(loadProject.res),"json");
			jsonIndex = 0;
			nextProgress =  3 + Math.floor(Math.random()*5);
			setTimeout(loadNextJson,0);
		}
		
		private function loadNextJson():void {
			if(jsonIndex >= loadJsons.length) {
				NetWaitingPanel.hide();
				ToolData.getInstance().showProject(loadProject);
				return;
			}
			var file:File = loadJsons[jsonIndex];
			var newProgress:int = Math.floor((jsonIndex/loadJsons.length)*100);
			jsonIndex++;
			if(newProgress > nextProgress) {
				NetWaitingPanel.show("加载项目 " + Math.floor((jsonIndex/loadJsons.length)*100) + "%",file.url.slice(loadProject.url.length,file.url.length),newProgress);
				nextProgress += 5 + Math.floor(Math.random()*5);
				setTimeout(loadNextJson,0);
			} else {
				loadNextJson();
			}
		}
	}
}