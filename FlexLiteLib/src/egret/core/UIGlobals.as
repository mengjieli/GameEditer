package egret.core
{
	import flash.display.Stage;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import egret.components.Skin;
	import egret.components.supportClasses.SkinBasicLayout;
	import egret.layouts.supportClasses.LayoutBase;
	import egret.managers.FocusManager;
	import egret.managers.IFocusManager;
	import egret.managers.ISystemManager;
	import egret.managers.LayoutManager;
	import egret.managers.ScreenDPIManager;
	
	use namespace ns_egret;
	
	/**
	 * 全局静态量
	 * @author dom
	 */
	public class UIGlobals
	{
		/**
		 * 一个全局标志，控制在某些鼠标操作或动画特效播放时，是否开启updateAfterEvent()，开启时能增加平滑的体验感,但是会提高屏幕渲染(Render事件)的频率。默认为true。
		 */		
		public static var useUpdateAfterEvent:Boolean = true;
		/**
		 * 由于一些修改导致预览库和wing中表现不一致的，通过此变量来判断控制。 
		 */
		public static function getForEgret(target:*):Boolean
		{
			var result:Boolean = false;
			if(target is UIComponent)
			{
				result =  UIComponent(target).getStyle("forEgret");
			}
			if(target is LayoutBase)
			{
				if(LayoutBase(target).target)
				{
					result = LayoutBase(target).target.getStyle("forEgret");
				}
			}
			if(target is SkinBasicLayout)
			{
				var skin:Skin = SkinBasicLayout(target).target;
				if(skin.numElements > 0)
				{
					var component:IVisualElement = skin.getElementAt(0);
					if(component is UIComponent)
					{
						result = UIComponent(component).getStyle("forEgret");
					}
				}
			}
			return result;
		}
		
		/**
		 * 是否屏蔽失效验证阶段和callLater方法延迟调用的所有报错。
		 * 建议在发行版中启用，避免因为一处报错引起全局的延迟调用失效。
		 */		
		public static var catchCallLaterExceptions:Boolean = false;
		
		private static var focusMangers:Dictionary = new Dictionary();
		private static var screenDPIMangers:Dictionary = new Dictionary();
		
		/**
		 * 全局第一个舞台引用
		 */
		ns_egret static var stage:Stage;
		
		/**
		 * 已经初始化完成标志
		 */		
		private static var initlized:Boolean = false;


		/**
		 * 初始化管理器
		 */		
		ns_egret static function initlize(firstStage:Stage):void
		{
			if(initlized||!firstStage)
				return;
			stage = firstStage;
			//屏蔽没有监听callLaterError的报错
			stage.addEventListener("callLaterError",function():void{});
			layoutManager = new LayoutManager();
			initlized = true;
		}
		/**
		 * 延迟渲染布局管理器 
		 */		
		ns_egret static var layoutManager:LayoutManager;
		/**
		 * 系统管理器列表
		 */		
		ns_egret static var systemManagers:Array = [];
		
		ns_egret static function addSystemManager(systemManager:ISystemManager):void
		{
			var index:int = systemManagers.indexOf(systemManager);
			if(index==-1)
			{
				systemManagers.push(systemManager);
				addStage(systemManager.stage);
			}
		}
		
		ns_egret static function removeSystemManager(systemManager:ISystemManager):void
		{
			var index:int = systemManagers.indexOf(systemManager);
			if(index!=-1)
				systemManagers.splice(index,1);
		}
		
		/**
		 * 添加舞台的回调函数
		 */		
		ns_egret static var addStageCallBack:Function;
		/**
		 * 移除舞台的回调函数
		 */		
		ns_egret static var removeStageCallBack:Function;
		
		ns_egret static var stages:Array = [];
		/**
		 * 添加舞台对象
		 */
		private static function addStage(stage:Stage):void
		{
			var index:int = stages.indexOf(stage);
			if(index==-1)
			{
				stages.push(stage);
				if(addStageCallBack!=null)
					addStageCallBack(stage);
				var focusManager:IFocusManager;
				try
				{
					var focusClass:Class = Injector.getClass(IFocusManager);
					focusManager = new focusClass();
				}
				catch(e:Error)
				{
					focusManager = new FocusManager();
				}
				focusManager.stage = stage;
				focusMangers[stage] = focusManager;
				var screenDPIManager:ScreenDPIManager = new ScreenDPIManager;
				screenDPIManager.stage = stage;
				screenDPIMangers[stage] = screenDPIManager;
			}
		}
		/**
		 * 移除舞台对象
		 */		
		ns_egret static function removeStage(stage:Stage):void
		{
			var index:int = stages.indexOf(stage);
			if(index!=-1)
			{
				if(removeStageCallBack!=null)
					removeStageCallBack(stage);
				var focusManager:IFocusManager = focusMangers[stage];
				delete focusMangers[stage];
				focusManager.stage = null;
				var screenDPIManager:ScreenDPIManager = screenDPIMangers[stage];
				delete screenDPIMangers[stage];
				screenDPIManager.stage = null;
				stages.splice(index,1);
				if(stages.length>0)
				{
					UIGlobals.stage = stages[0];
				}
			}
		}
	}
}