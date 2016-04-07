package view.attributesEditer.attributes
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	
	import egret.components.Label;
	import egret.ui.components.TextInput;
	
	import main.data.parsers.ReaderBase;
	import main.data.parsers.command.AttributeEXE;
	
	import view.component.data.LabelData;
	import view.events.ComponentAttributeEvent;

	public class TextAttribute extends AttributeBase
	{
		public function TextAttribute(data:LabelData,reader:ReaderBase)
		{
			super("文字信息",reader);
			
			var label:Label = new Label();
			label.text = "内容:";
			label.y = 25;
			this.addElement(label);
			
			var textTxt:TextInput = new TextInput();
			textTxt.left = 35;
			textTxt.right = 5;
			textTxt.height = 20;
			textTxt.y = 25;
			this.addElement(textTxt);
			textTxt.text = data.text;
			textTxt.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void {
				if(e.keyCode == 13) {
					var val:* = data.text;
					data.text = textTxt.text;
					if(val != data.text) {
						reader.pushCommand(new AttributeEXE(data,"text",val));
					}
				}
			});
			textTxt.addEventListener(FocusEvent.FOCUS_OUT,function(e:Event):void {
				var val:* = data.text;
				data.text = textTxt.text;
				if(val != data.text) {
					reader.pushCommand(new AttributeEXE(data,"text",val));
				}
			});
			var textFunc:Function = function(e:ComponentAttributeEvent):void {
				textTxt.text = data.text;
			}
			data.addEventListener("text",textFunc);
//			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
//				data.removeEventListener("text",textFunc);
//			});
			
			this.height = 50;
		}
	}
}