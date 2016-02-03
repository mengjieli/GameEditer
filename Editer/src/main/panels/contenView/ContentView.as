package main.panels.contenView
{
	import egret.events.CloseEvent;
	import egret.ui.components.Alert;
	import egret.ui.components.TabGroup;
	import egret.ui.components.TabPanel;
	
	import main.data.ToolData;
	import main.data.parsers.ReaderBase;
	import main.events.DirectionEvent;
	import main.events.EventMgr;
	import main.events.ToolEvent;
	import main.ui.DefinePanel;

	public class ContentView extends TabGroup
	{
		public function ContentView()
		{
			this.skinName = ContentTabGroupSkin;
			EventMgr.ist.addEventListener(DirectionEvent.SHOW_FILE,onShowFile);
			EventMgr.ist.addEventListener(ToolEvent.START,onStart);
		}
		
		private var init:Boolean = false;
		
		protected override function createChildren():void
		{
			super.createChildren();
			onStart();
		}
		
		private function onStart(e:ToolEvent=null):void {
			var panels:Array = ToolData.getInstance().getConfigValue("initPanel","coderui");
			for(var i:int = 0; i < panels.length; i++) {
				var panelClass:Class = ToolData.getInstance().getPanel(panels[i].name);
				if(panelClass) {
					var panel:DefinePanel = new panelClass();
					this.addElement(panel);
					init = true;
				}
			}
		}
		
		private function onShowFile(e:DirectionEvent):void {
			if(e.file.reader) {
				if(e.file.reader.parent == null) {
					this.addElement(e.file.reader);
				}
				this.selectedPanel = e.file.reader;
				e.file.reader.showData(e.file);
			}
		}
		
		public function closePanel(panel:TabPanel):void {
			var _this:ContentView = this;
			if((panel as ReaderBase).changeFlag) {
				Alert.show(panel.title + " 的内容还没有保存，是否直接关闭?","提示",null,function(e:CloseEvent):void{
					if(e.detail == Alert.FIRST_BUTTON) {
						//			var selectPanel:ITabPanel = this.selectedPanel;
						for(var i:int = 0; i < _this.numElements; i++) {
							if(_this.getElementAt(i) == panel) {
								_this.onClosePanel(i);
								break;
							}
						}
						//			this.selectedPanel = selectPanel;
					}
				},"确定","取消");
			} else {
				//			var selectPanel:ITabPanel = this.selectedPanel;
				for(var i:int = 0; i < this.numElements; i++) {
					if(this.getElementAt(i) == panel) {
						this.onClosePanel(i);
						break;
					}
				}
				//			this.selectedPanel = selectPanel;
			}
		}
	}
}