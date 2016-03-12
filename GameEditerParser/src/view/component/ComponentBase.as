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
		protected var selctedShow:UIAsset;
		protected var editerShow:UIAsset;
		protected var styleData:Object;
		protected var bgContainer:egret.components.Group;
		protected var selfContainer:egret.components.Group;
		protected var childContainer:egret.components.Group;
		protected var _data:ComponentData;
		
		public function ComponentBase(data:ComponentData)
		{
			_data = data;
			
			this.addElement(bgContainer = new egret.components.Group());
			this.addElement(selfContainer = new egret.components.Group());
			
			selctedShow = new UIAsset();
			this.selctedShow.source = "assets/bg/selectBg.png";
			this.selctedShow.scale9Grid = new Rectangle(1,1,8,8);
			this.addElement(selctedShow);
			this.selctedShow.width = data.width;
			this.selctedShow.height = data.height;
			selctedShow.alpha = this.data.selected?1:0;
			
			editerShow = new UIAsset();
			this.editerShow.source = "assets/bg/editerBg.png";
			this.editerShow.scale9Grid = new Rectangle(1,1,8,8);
			this.addElement(editerShow);
			this.editerShow.width = data.width;
			this.editerShow.height = data.height;
			editerShow.alpha = this.data.inediter?1:0;
			
			this.addElement(childContainer = new egret.components.Group());
			
			this.x = data.x;
			this.y = data.y;
			
			
			this.data.addEventListener("x",onPropertyChange);
			this.data.addEventListener("y",onPropertyChange);
			this.data.addEventListener("width",onPropertyChange);
			this.data.addEventListener("height",onPropertyChange);
			this.data.addEventListener("visible",onPropertyChange);
			this.data.addEventListener("selected",onPropertyChange);
			this.data.addEventListener("inediter",onPropertyChange);
			
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
				case "width": this.selctedShow.width = this.editerShow.width = e.value; break;
				case "height": this.selctedShow.height = this.editerShow.height = e.value; break;
				case "visible": this.visible = e.value; break;
				case "selected": this.selctedShow.alpha = e.value?1:0; break;
				case "inediter": editerShow.alpha = e.value?1:0;break;
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