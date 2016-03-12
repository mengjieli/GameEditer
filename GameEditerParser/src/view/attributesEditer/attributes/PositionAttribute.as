package view.attributesEditer.attributes
{
	import flash.events.Event;
	
	import egret.components.Label;
	import egret.ui.components.TextInput;
	
	import view.component.data.ComponentData;
	import view.events.ComponentAttributeEvent;

	public class PositionAttribute extends AttributeBase
	{
		
		public function PositionAttribute(data:ComponentData)
		{
			super("位置尺寸");
			
			var label:Label = new Label();
			label.text = "X:";
			label.y = 25;
			this.addElement(label);
			
			
			var xTxt:TextInput = new TextInput();
			xTxt.width = 100;
			xTxt.height = 20;
			xTxt.x = 35;
			xTxt.y = 25;
			this.addElement(xTxt);
			xTxt.text = data.x + "";
			xTxt.restrict = "- 0-9";
			xTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.x = int(xTxt.text);
			});
			var xFunc:Function = function(e:ComponentAttributeEvent):void {
				xTxt.text = data.x + "";
			}
			data.addEventListener("x",xFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("x",xFunc);
			});
			
			
			label = new Label();
			label.text = "Y:";
			label.x = 150;
			label.y = 25;
			this.addElement(label);
			
			
			var yTxt:TextInput = new TextInput();
			yTxt.width = 100;
			yTxt.height = 20;
			yTxt.x = 185;
			yTxt.y = 25;
			this.addElement(yTxt);
			yTxt.text = data.y + "";
			yTxt.restrict = "- 0-9";
			yTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.y = int(yTxt.text);
			});
			var yFunc:Function = function(e:ComponentAttributeEvent):void {
				yTxt.text = data.y + "";
			}
			data.addEventListener("y",yFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("y",yFunc);
			});
			
			
			label = new Label();
			label.text = "宽:";
			label.y = 50;
			this.addElement(label);
			
			
			var widthTxt:TextInput = new TextInput();
			widthTxt.width = 100;
			widthTxt.height = 20;
			widthTxt.x = 35;
			widthTxt.y = 50;
			this.addElement(widthTxt);
			if(data.sizeSet == false) {
				widthTxt.textColor = 0x595959;
				widthTxt.editable = false;
			}
			widthTxt.text = data.width + "";
			widthTxt.restrict = "0-9";
			widthTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.width = int(widthTxt.text);
			});
			var widthFunc:Function = function(e:ComponentAttributeEvent):void {
				widthTxt.text = data.width + "";
			}
			data.addEventListener("width",widthFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("width",widthFunc);
			});
			
			
			label = new Label();
			label.text = "高:";
			label.x = 150;
			label.y = 50;
			this.addElement(label);
			
			
			var heightTxt:TextInput = new TextInput();
			heightTxt.width = 100;
			heightTxt.height = 20;
			heightTxt.x = 185;
			heightTxt.y = 50;
			this.addElement(heightTxt);
			if(data.sizeSet == false) {
				heightTxt.textColor = 0x595959;
				heightTxt.editable = false;
			}
			heightTxt.text = data.height + "";
			heightTxt.restrict = "- 0-9";
			heightTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.height = int(heightTxt.text);
			});
			var heightFunc:Function = function(e:ComponentAttributeEvent):void {
				heightTxt.text = data.height + "";
			}
			data.addEventListener("height",heightFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("height",heightFunc);
			});
			
			this.height = 75;
		}
	}
}