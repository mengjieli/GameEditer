package view.component
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import egret.components.Group;
	import egret.components.UIAsset;
	import egret.events.UIEvent;
	
	import view.component.data.ComponentData;
	import view.events.ComponentAttributeEvent;

	public class ComponentBase extends egret.components.Group
	{
		private var show:UIAsset;
		protected var styleData:Object;
		protected var _data:ComponentData;
		
		public function ComponentBase(data:ComponentData)
		{
			_data = data;
			
			show = new UIAsset();
			this.show.source = "assets/componentCustom/Group/bg.png";
			this.show.scale9Grid = new Rectangle(1,1,8,8);
			this.addElement(show);
			this.show.width = data.width;
			this.show.height = data.height;
			show.alpha = this.data.selected?1:0.1;
			
			this.x = data.x;
			this.y = data.y;
			
			
			this.data.addEventListener("x",onPropertyChange);
			this.data.addEventListener("y",onPropertyChange);
			this.data.addEventListener("width",onPropertyChange);
			this.data.addEventListener("height",onPropertyChange);
			this.data.addEventListener("visible",onPropertyChange);
			this.data.addEventListener("selected",onPropertyChange);
			
			this.addEventListener(UIEvent.CREATION_COMPLETE,onComplete);
		}
		
		private function onComplete(e:UIEvent):void {
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemove);
		}
		
		public function decodeByStyle(style:Object,styleURL:String):void {
			
		}
		
		public function get data():ComponentData {
			return this._data;
		}
		
		public function onPropertyChange(e:ComponentAttributeEvent):void {
			switch(e.type) {
				case "x": this.x = e.value; break;
				case "y": this.y = e.value; break;
				case "width": this.show.width = e.value; break;
				case "height": this.show.height = e.value; break;
				case "visible": this.visible = e.value; break;
				case "selected": show.alpha = e.value?1:0.1; break;
			}
		}
		
		private function onRemove(e:Event):void {
			this.dispose();
		}
		
		public function dispose():void {
			this.data.removeEventListener("x",onPropertyChange);
			this.data.removeEventListener("y",onPropertyChange);
			this.data.removeEventListener("visible",onPropertyChange);
			this.data.removeEventListener("selected",onPropertyChange);
		}
	}
}