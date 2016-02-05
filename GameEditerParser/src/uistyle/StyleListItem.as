package uistyle
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.components.Label;
	import egret.components.supportClasses.ItemRenderer;
	
	import main.data.ToolData;

	public class StyleListItem extends ItemRenderer
	{
		public function StyleListItem()
		{
		}
		
		public var nameTxt:Label;
		public var image:AcceptImage;
		
		override public function set data(value:Object):void {
			super.data = value;
			this.height = value.height||120;
			nameTxt.text = value.name;
			if(value.url) {
				image.source = ToolData.getInstance().project.getResURL(value.url);
			}
			image.showMaxWidth = 200;
			image.showMaxHeight = this.height - 20; 
		}
		
		private function onImageChange(e:Event):void {
			var d:StyleImageData = this.data as StyleImageData;
			if(d) {
				d.url = ToolData.getInstance().project.getResDirectionURL(image.url);
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance) {
				case image:
					image.addEventListener(Event.CHANGE,onImageChange);
					break;
			}
		}
	}
}