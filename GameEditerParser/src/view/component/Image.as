package view.component
{
	import egret.components.UIAsset;
	
	import main.data.ToolData;
	
	import view.component.data.ImageData;
	import view.events.ComponentAttributeEvent;

	public class Image extends ComponentBase
	{
		private var image:UIAsset;
		
		public function Image(data:ImageData)
		{
			super(data);
			
			this.selfContainer.addElement(image = new UIAsset(ToolData.getInstance().project.getResURL(data.url)));
			
			if(data.width == 0) this.selctedShow.width = this.editerShow.width = 100;
			if(data.height == 0) this.selctedShow.height = this.editerShow.height = 100;
		}
		
		override public function onPropertyChange(e:ComponentAttributeEvent):void {
			super.onPropertyChange(e);
			switch(e.type) {
				case "url": image.source = ToolData.getInstance().project.getResURL(e.value); break;
			}
			if(data.width == 0) this.selctedShow.width = this.editerShow.width = 100;
			if(data.height == 0) this.selctedShow.height = this.editerShow.height = 100;
		}
	}
}