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
			selctedShow.alpha = this.data.selected?1:0;
			
			editerShow = new UIAsset();
			this.editerShow.source = "assets/bg/editerBg.png";
			this.editerShow.scale9Grid = new Rectangle(1,1,8,8);
			this.addElement(editerShow);
			this.selctedShow.width = this.editerShow.width = Math.abs(data.width*data.scaleX);
			this.selctedShow.scaleX = this.editerShow.scaleX = data.scaleX>=0?1:-1;
			this.selctedShow.height = this.editerShow.height = Math.abs(data.height*data.scaleY);
			this.selctedShow.scaleY = this.editerShow.scaleY = data.scaleY>=0?1:-1;
			editerShow.alpha = this.data.inediter?1:0;
			
			this.addElement(childContainer = new egret.components.Group());
			childContainer.scaleX = this.data.scaleX;
			childContainer.scaleY = this.data.scaleY;
			
			this.x = data.x;
			this.y = data.y;
			
			
			this.data.addEventListener("x",onPropertyChange);
			this.data.addEventListener("y",onPropertyChange);
			this.data.addEventListener("width",onPropertyChange);
			this.data.addEventListener("height",onPropertyChange);
			this.data.addEventListener("scaleX",onPropertyChange);
			this.data.addEventListener("scaleY",onPropertyChange);
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
				case "scaleX":
				case "width": 
					this.selctedShow.width = this.editerShow.width = Math.abs(this.data.width*this.data.scaleX);
					this.selctedShow.scaleX = this.editerShow.scaleX = data.scaleX>=0?1:-1;
					if(e.type == "scaleX") {
						this.childContainer.scaleX = this.data.scaleX;
					}
					break;
				case "scaleY": 
				case "height": this.selctedShow.height = this.editerShow.height = Math.abs(this.data.height*this.data.scaleY); 
					this.selctedShow.scaleY = this.editerShow.scaleY = data.scaleY>=0?1:-1;
					if(e.type == "scaleY") {
						this.childContainer.scaleY = this.data.scaleY;
					}
					break;
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
			this.data.removeEventListener("width",onPropertyChange);
			this.data.removeEventListener("height",onPropertyChange);
			this.data.removeEventListener("scaleX",onPropertyChange);
			this.data.removeEventListener("scaleY",onPropertyChange);
			this.data.removeEventListener("visible",onPropertyChange);
			this.data.removeEventListener("selected",onPropertyChange);
			this.data.removeEventListener("inediter",onPropertyChange);
		}
	}
}