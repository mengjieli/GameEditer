package main.controllers
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import egret.events.CloseEvent;
	import egret.events.IndexChangeEvent;
	import egret.ui.components.Alert;
	import egret.ui.components.Application;
	
	import main.menu.MenuID;
	import main.panels.MainPanel;

	/**
	 *主面板控制器 
	 * @author Grayness
	 */	
	public class MainViewController extends BaseController
	{
		public function MainViewController()
		{
		}
		
		private var mainView:MainPanel;
		
		public override function start(app:Application):void
		{
			super.start(app);
//			app.percentWidth = 100;
//			app.percentHeight = 100;
			mainView=new MainPanel();
			mainView.percentWidth=mainView.percentHeight=100;
			app.addElement(mainView);
			/*
			mainView.clipItemPanel.addClipItem(ProjectItem.getInstance(),TransItem.getInstance());
			
			ProjectItem.getInstance().dataList.dataProvider=GlobalData.projects;
			if(GlobalData.projects.length)
			{
				ProjectItem.getInstance().dataList.selectedIndex = 0;
				GlobalData.currentProject = GlobalData.projects[0];
			}
			
			//为项目列表创建右键菜单
			var menu:NativeMenuExtend=new NativeMenuExtend([
				new NativeMenuItemExtend("删除",MenuID.DELETE,false,null,projectlistmenuclick),
				new NativeMenuItemExtend("浏览输出目录",MenuID.OPENEXPORTPATH,false,null,projectlistmenuclick),
				new NativeMenuItemExtend("",null,true),
				new NativeMenuItemExtend("项目属性",MenuID.PROJECTPROPERTY,false,null,projectlistmenuclick)]);
			ProjectItem.getInstance().dataList.contextMenu=menu;
			//为项目列表创建事件
			ProjectItem.getInstance().dataList.addEventListener(IndexChangeEvent.CHANGE,projectDataListEvent);
			//注册全局事件
			registGlobalMessage(Message.MENUSELECTED,messageCallBack);
			registGlobalMessage(Message.CREATEPROJECT,messageCallBack);
			registGlobalMessage(Message.CREATEPROJECT_COMPLETE,messageCallBack);
			registGlobalMessage(Message.BUILD_COMPLETE,messageCallBack);
			registGlobalMessage(Message.CREATEPROJECT_ERROR,messageCallBack);
			registGlobalMessage(Message.LOG,messageCallBack);
			registGlobalMessage(Message.CLEAR_LOG,messageCallBack);
			registGlobalMessage(Message.COMPLETE_TRANSLATE,messageCallBack);
			
			GlobalData.main = this;*/
		}
		
		
//		private function projectDataListEvent(e:IndexChangeEvent):void
//		{
//			GlobalData.currentProject=ProjectItem.getInstance().dataList.selectedItem as ProjectModel;
//		}
//		private function projectlistmenuclick(e:Event):void
//		{
//			sendGlobalMessage(Message.MENUSELECTED,new MenuData(e.currentTarget.data.toString()));
//		}
//		/**
//		 * 全局消息处理
//		 */		
//		private function messageCallBack(e:Message):void
//		{
//			switch(e.type)
//			{
//				case Message.MENUSELECTED:
//					var data:MenuData=e.data as MenuData;
//					doForMenu(data.menuId);
//					break;
//				case Message.CREATEPROJECT:
//					ProjectItem.getInstance().dataList.selectedItem = GlobalData.currentProject;
//					mainView.statusBar.showMessage("正在执行...",true);
//					GlobalData.currentProject.startTask();
//					break;
//				case Message.BUILD_COMPLETE:
//					mainView.statusBar.showMessage(null); 
//					break;
//				case Message.CREATEPROJECT_COMPLETE:
//					mainView.statusBar.showMessage(null); 
//					break;
//				case Message.CREATEPROJECT_ERROR:
//					mainView.statusBar.showMessage(null); 
//					break ;
//				case Message.LOG:
//					LogItem.getInstance().appendText(e.data.toString());
//					break;
//				case Message.CLEAR_LOG:
//					LogItem.getInstance().clear();
//					break;
//				case Message.COMPLETE_TRANSLATE:
//					TransItem.getInstance().completeTranslate(e.data as String);
//					break;
//			}
//		}
//		/**
//		 *对菜单的处理 
//		 * @param menuid 菜单ID
//		 */		
//		private function doForMenu(menuid:String):void
//		{
//			switch(menuid)
//			{
//				case MenuID.NEW:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后创建","提示");
//						return;
//					}
//					new CreateProject().open();
//					break;
//				case MenuID.CONVERT:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后再试","提示");
//						return;
//					}
//					if(GlobalData.currentProject)
//					{
//						GlobalData.currentProject.startTask(3);
//						mainView.statusBar.showMessage("正在执行...",true);
//					}
//					break;
//				case MenuID.BUILD:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后再试","提示");
//						return;
//					}
//					if(GlobalData.currentProject)
//					{
//						GlobalData.currentProject.startTask(4);
//						mainView.statusBar.showMessage("正在执行...",true);
//					}
//					break;
//				case MenuID.RECREATE:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后再试","提示");
//						return;
//					}
//					if(GlobalData.currentProject)
//						sendGlobalMessage(Message.CREATEPROJECT,null);
//					break;
//				case MenuID.DELETE:
//					if(!GlobalData.currentProject)
//						return ;
//					if(GlobalData.currentWorkingProject&&GlobalData.currentProject==GlobalData.currentWorkingProject)
//					{
//						Alert.show("此项目正在执行任务...\r\n确定要删除吗?","提示",null,function(e:CloseEvent):void
//						{
//							if(e.detail==Alert.FIRST_BUTTON)
//							{
//								var index:int=GlobalData.projects.getItemIndex(GlobalData.currentProject);
//								GlobalData.projects.removeItemAt(index);
//								GlobalData.currentProject=null;
//								GlobalData.currentWorkingProject.stop();
//								mainView.statusBar.showMessage(null);
//							}
//						},"确定","取消");
//					}
//					else
//					{
//						GlobalData.currentProject.stop();
//						GlobalData.currentProject=null;
//						var index:int=GlobalData.projects.getItemIndex(ProjectItem.getInstance().dataList.selectedItem);
//						if(index!=-1)
//							GlobalData.projects.removeItemAt(index);
//					}
//					break;
//				case MenuID.OPENEXPORTPATH:
//					var selected:ProjectModel=ProjectItem.getInstance().dataList.selectedItem;
//					if(selected)
//					{
//						var file:File=new File(selected.exportURL);
//						file.openWithDefaultApplication();
//					}
//					break;
//				case MenuID.RUN:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后再试","提示");
//						return;
//					}
//					if(GlobalData.currentProject)
//						GlobalData.currentProject.run();
//					break;
//				case MenuID.STOP_RUN:
//					if(GlobalData.currentWorkingProject)
//					{
//						Alert.show("正在执行任务，请稍后再试","提示");
//						return;
//					}
//					if(GlobalData.currentProject)
//						GlobalData.currentProject.stop();
//					break;
//				case MenuID.PROJECTPROPERTY:
//					if(GlobalData.currentProject)
//					{
////						var property:ProjectProperty=new ProjectProperty();
////						property.project=GlobalData.currentProject;
////						property.open();
//					}
//					break ;
//				case MenuID.CLEARLOG:
//					LogItem.getInstance().clear();
//					break;
//			}
//		}
	}
}