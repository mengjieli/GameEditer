package view.attributesEditer.attributes
{
	import flash.events.Event;
	
	import egret.components.Label;
	import egret.ui.components.TextInput;
	
	import view.component.data.LabelData;
	import view.events.ComponentAttributeEvent;

	public class TextAttribute extends AttributeBase
	{
		public function TextAttribute(data:LabelData)
		{
			super("文字信息");
			
			var label:Label = new Label();
			label.text = "内容:";
			label.y = 25;
			this.addElement(label);
			
			var textTxt:TextInput = new TextInput();
			textTxt.width = 200;
			textTxt.height = 20;
			textTxt.x = 35;
			textTxt.y = 25;
			this.addElement(textTxt);
			textTxt.text = data.text;
			textTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.text = textTxt.text;
			});
			var textFunc:Function = function(e:ComponentAttributeEvent):void {
				textTxt.text = data.text;
			}
			data.addEventListener("text",textFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("text",textFunc);
			});
			
			this.height = 50;
		}
	}
}