package main.controllers
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import egret.tools.GlobalData;
	import egret.tools.model.ProjectModel;
	import egret.ui.components.Application;

	/**
	 *程序控制器 
	 * @author Grayness
	 */	
	public class SystemController extends BaseController
	{
		public function SystemController()
		{
		}
		public override function start(app:Application):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("projects.xml");
			/*if(file.exists)
			{
				var fs:FileStream=new FileStream();
				fs.open(file,FileMode.READ);
				var xmlString:String=fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				var xml:XML=new XML(xmlString);
				for each(var item:XML in xml.children())
				{
					var project:ProjectModel=new ProjectModel();
					project.name = item.@name.toString();
					project.exportURL = item.@exportURL.toString();
					project.type = item.@type.toString();
					project.srcURL = item.@srcURL.toString();
					project.startURL = item.@startURL.toString();
					project.resURL = item.@resURL.toString();
					GlobalData.projects.addItem(project);
				}
			}*/
			app.addEventListener(Event.CLOSE,appClose);
		}
		private function appClose(e:Event):void
		{
//			if(GlobalData.currentWorkingProject)
//				GlobalData.currentWorkingProject.stop();
//			if(GlobalData.currentRuningProject)
//				GlobalData.currentRuningProject.stop();
			var config:String="<PROJECT>\r\n";
//			for each(var item:ProjectModel in GlobalData.projects)
//			{
//				config+=item.toConfig()+"\r\n";
//			}
			config+="</PROJECT>";
			var file:File=File.applicationStorageDirectory.resolvePath("projects.xml");
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.WRITE);
			fs.writeUTFBytes(config);
			fs.close();
		}
	}
}