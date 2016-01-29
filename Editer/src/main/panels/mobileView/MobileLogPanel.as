package main.panels.mobileView
{
	import flash.events.Event;
	import flash.system.System;
	
	import egret.collections.ArrayCollection;
	import egret.components.EditableText;
	import egret.components.Label;
	import egret.components.List;
	import egret.components.TextArea;
	import egret.layouts.VerticalLayout;
	import egret.tools.menu.MenuID;
	import egret.tools.menu.NativeMenuExtend;
	import egret.tools.menu.NativeMenuItemExtend;
	
	import main.data.ToolData;
	import main.data.events.LogEvent;
	import main.menu.MenuID;
	import main.menu.NativeMenuExtend;
	import main.menu.NativeMenuItemExtend;
	import main.net.MyByteArray;
	import main.panels.components.TextAreaExt;

	public class MobileLogPanel extends ConnectMobileBase
	{
		public function MobileLogPanel()
		{
			this.title = "游戏日志";
			this.tip = "还没有链接游戏客户端，无法查看日志，点击链接";
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
			ToolData.getInstance().log.addEventListener(LogEvent.ADD,onAddLog);
			ToolData.getInstance().log.addEventListener(LogEvent.SHIFT,onShiftLog);
			ToolData.getInstance().log.addEventListener(LogEvent.CLEAR,onClearAll);
		}
		
		private function addToStage(e:Event):void {
			this.checkConnect();
		}
		
		private var logTxt:TextAreaExt;
		protected override function createChildren():void
		{
			super.createChildren();
			
			logTxt = new TextAreaExt();
			logTxt.percentWidth = 100;
			logTxt.max = 300;
			logTxt.percentHeight = 100;
			this.addElement(logTxt);
			
			//为日志面板创建右键菜单
			var menu:main.menu.NativeMenuExtend = new NativeMenuExtend([
				new NativeMenuItemExtend("清空",MenuID.CLEARLOG,false,null,clear),
				new NativeMenuItemExtend("复制",MenuID.COPYLOG,false,null,copyLog)]);
			this.contextMenu = menu;
			
			for(var i:int = 0; i < ToolData.getInstance().log.logs.length; i++) {
				this.logTxt.appendText(ToolData.getInstance().log.logs[i],ToolData.getInstance().log.colors[i]);
			}
		}
		
		private function clear(e:Event):void {
			ToolData.getInstance().log.clearAll();
		}
		
		private function onClearAll(e:Event):void {
			logTxt.clear();
		}
		
		/**
		 * 剪贴板
		 */
		private function copyLog(e:Event):void {
			System.setClipboard(logTxt.text);
		}
		
		private var cacheText:String = "";
		
		private function onAddLog(e:LogEvent):void {
			logTxt.appendText(e.content,e.color);
			logTxt.scrollToEnd();
		}
		
		private function onShiftLog(e:LogEvent):void {
			logTxt.shift();
			logTxt.scrollToEnd();
		}
	}
}