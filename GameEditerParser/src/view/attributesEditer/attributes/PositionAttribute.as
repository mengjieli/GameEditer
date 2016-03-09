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
			super("位置");
			
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
			
			this.height = 50;
		}
	}
}