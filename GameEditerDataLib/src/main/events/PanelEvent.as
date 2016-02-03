package main.events
{
	import flash.events.Event;

	public class PanelEvent extends Event
	{
		public static const PANEL:String = "panel";
		
		public var panelName:String;
		public var subType:String;
		public var data:*;
		
		public function PanelEvent(panelName:String,subType:String,data:*=null)
		{
			super(PanelEvent.PANEL);
			this.panelName = panelName;
			this.subType = subType;
			this.data = data;
		}
	}
}