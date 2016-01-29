package main.panels.directionView
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import egret.components.Group;
	import egret.ui.components.Window;

	public class LoaderPanel extends Window
	{
		public function LoaderPanel(url:String)
		{
			this.width = 500;
			this.height = 400;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete); 
			loader.load(new URLRequest(url));
		}
		
		private function loadComplete(e:Event):void {
			var swf:* = (e.currentTarget as LoaderInfo).content;
			var panel:Group = swf.panel;
			this.addElement(panel);
			panel.percentHeight = 100;
			panel.percentWidth = 100;
			this.title = swf.title;
			this.width = swf.panelWidth;
			this.height = swf.panelHeight;
		}
	}
}