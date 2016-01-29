package main.controllers
{
	import flash.display.NativeMenu;
	import flash.events.Event;
	
	import egret.collections.XMLCollection;
	import egret.components.MenuBar;
	import egret.components.UIAsset;
	import egret.events.MenuEvent;
	import egret.ui.components.Application;
	import egret.ui.skins.MenuBarSkin;
	import egret.utils.NativeApplicationMenu;
	import egret.utils.SystemInfo;
	
	import main.menu.MenuID;
	import main.menu.NativeMenuExtend;
	import main.menu.NativeMenuItemExtend;
	
	import res.IconRes;

	/**
	 *菜单控制器 
	 * @author Grayness
	 */	
	public class MenuController extends BaseController
	{
		public function MenuController()
		{
		}
		
		
		public override function start(app:Application):void
		{
			app=app;
			
			var menuBar:MenuBar=new MenuBar();
			menuBar.percentWidth=100;
			
			/*if(app.titleGroup) {
				var icon:UIAsset = new UIAsset(new (IconRes.getInstance().logo16)());
				icon.y = 3;
				icon.x = -4;
				app.titleGroup.addElement(icon);
				
				app.titleGroup.addElement(menuBar);
			}*/
			createMenu(menuBar);
			menuBar.x = 16;
		}
		private function createMenu(menu:MenuBar):void
		{
			if(SystemInfo.isMacOS)
			{
				var rootMenu:NativeMenu=new NativeMenu();
				var subMenu:NativeMenu=new NativeMenuExtend([
					new NativeMenuItemExtend("新建游戏项目",MenuID.NEW,false,null,menuItemClick)
				]);
				rootMenu.addSubmenu(subMenu,"文件");
				
				subMenu=new NativeMenuExtend([
					new NativeMenuItemExtend("删除",MenuID.DELETE,false,null,menuItemClick),
					new NativeMenuItemExtend("浏览输出目录",MenuID.OPENEXPORTPATH,false,null,menuItemClick),
					new NativeMenuItemExtend("",null,true),
					new NativeMenuItemExtend("重新创建",MenuID.RECREATE,false,null,menuItemClick),
					new NativeMenuItemExtend("转换",MenuID.CONVERT,false,null,menuItemClick),
					new NativeMenuItemExtend("运行",MenuID.RUN,false,null,menuItemClick),
					new NativeMenuItemExtend("",null,true),
					new NativeMenuItemExtend("项目属性",MenuID.PROJECTPROPERTY,false,null,menuItemClick),
				]);	
				rootMenu.addSubmenu(subMenu,"编辑");
				NativeApplicationMenu.macMenu = rootMenu;
				NativeApplicationMenu.macMenu.getItemAt(0).submenu.addItemAt(new NativeMenuItemExtend("关于",MenuID.ABOUT,false,null,menuItemClick),0);	
				NativeApplicationMenu.macMenu.getItemAt(0).submenu.addItemAt(new NativeMenuItemExtend("",null,true),1);
			}
			else
			{
				var menuXML:XML=new XML('<root>' +
					'<menu label="文件">'+
					'<item label="新建转换项目" id="'+MenuID.NEW+'" icon="assets/new.png"/>' +
					'</menu>'+
					/*'<menu label="编辑">'+
					'<node label="删除" id="'+MenuID.DELETE+'" icon="assets/run.png"/>' +
					'<node label="浏览输出目录" id="'+MenuID.OPENEXPORTPATH+'" icon="assets/run.png"/>' +
					'<node type="separator"/>' +
					'<node label="重新创建" id="'+MenuID.RECREATE+'" icon="assets/run.png"/>' +
					'<node label="转换" id="'+MenuID.CONVERT+'" icon="assets/run.png"/>' +
					'<node label="运行" id="'+MenuID.RUN+'" icon="assets/run.png"/>' +
					'<node type="separator"/>' +
					'<node label="项目属性" id="'+MenuID.PROJECTPROPERTY+'" icon="assets/run.png"/>' +
					'</menu>'+*/
					'<menu label="帮助">'+
					'<node label="关于" id="'+MenuID.ABOUT+'"/>'+
					'</menu>'+
					'</root>');
				menu.skinName = MenuBarSkin;
				menu.height = 20;
				menu.verticalCenter = 0;
				menu.dataProvider=new XMLCollection(menuXML);
				menu.addEventListener(MenuEvent.ITEM_CLICK,menuItemClick);
			}
		}
		private function menuItemClick(e:Event):void
		{
			if(e is MenuEvent) {
				trace((e as MenuEvent).item.@id.toString());
			}
//			if(e is MenuEvent)
//				sendGlobalMessage(Message.MENUSELECTED,new MenuData((e as MenuEvent).item.@id.toString()));
//			else
//				sendGlobalMessage(Message.MENUSELECTED,new MenuData(e.target.data.toString()));
		}
	}
}