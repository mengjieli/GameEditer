package view.attributesEditer.attributes
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import egret.collections.ArrayCollection;
	import egret.components.DropDownList;
	import egret.components.Label;
	import egret.events.UIEvent;
	import egret.ui.components.TextInput;
	
	import extend.ui.Input;
	
	import main.data.parsers.ReaderBase;
	
	import view.component.data.ComponentData;
	import view.component.data.ImageData;
	import view.events.ComponentAttributeEvent;

	public class PositionAttribute extends AttributeBase
	{
		private var topAlgin:DropDownList;
		private var bottomAlgin:DropDownList;
		private var leftAlgin:DropDownList;
		private var rightAlgin:DropDownList;
		private var topTxt:TextInput;
		private var bottomTxt:TextInput;
		private var leftTxt:TextInput;
		private var rightTxt:TextInput;
		private var data:ComponentData;
		private var showAlgin:Boolean;
		
		public function PositionAttribute(data:ComponentData,reader:ReaderBase,showAlgin:Boolean=true)
		{
			super("位置尺寸",reader);
			this.data = data;
			this.showAlgin = showAlgin;
			
			this.addEventListener(UIEvent.CREATION_COMPLETE,onComplete,this);
			
			this.height = 100;
			if(!showAlgin) {
				return;
			}
			this.height = 200;
		}
		
		private function onComplete(e:UIEvent):void {
			
			this.removeEventListener(UIEvent.CREATION_COMPLETE,onComplete,this);
			
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
				if(data is ImageData) {
					(data as ImageData).setWidth(int(widthTxt.text));
				} else {
					data.width = int(widthTxt.text);
				}
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
				if(data is ImageData) {
					(data as ImageData).setHeight(int(heightTxt.text));
				} else {
					data.height = int(heightTxt.text);
				}
			});
			var heightFunc:Function = function(e:ComponentAttributeEvent):void {
				heightTxt.text = data.height + "";
			}
			data.addEventListener("height",heightFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("height",heightFunc);
			});
			this.height = 75;
			if(!showAlgin) {
				return;
			}
			
			var setSizeFunc:Function = function(e:ComponentAttributeEvent):void {
				if(data.sizeSet) {
					widthTxt.textColor = 0xffffff;
					widthTxt.editable = true;
					heightTxt.textColor = 0xffffff;
					heightTxt.editable = true;
				} else {
					widthTxt.textColor = 0x595959;
					widthTxt.editable = false;
					heightTxt.textColor = 0x595959;
					heightTxt.editable = false;
				}
			}
			data.addEventListener("sizeSet",setSizeFunc);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				data.removeEventListener("sizeSet",setSizeFunc);
			});
			
			
			label = new Label();
			label.text = "scaleX:";
			label.y = 75;
			this.addElement(label);
			var scaleXTxt:TextInput = new TextInput();
			scaleXTxt.width = 80;
			scaleXTxt.height = 20;
			scaleXTxt.x = 55;
			scaleXTxt.y = 75;
			this.addElement(scaleXTxt);
			scaleXTxt.text = data.scaleX + "";
			scaleXTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.scaleX = Number(scaleXTxt.text);
			});
			var scaleXFunc:Function = function(e:ComponentAttributeEvent):void {
				scaleXTxt.text = data.scaleX + "";
			}
			data.addEventListener("scaleX",scaleXFunc);
			
			label = new Label();
			label.text = "scaleY:";
			label.x = 150;
			label.y = 75;
			this.addElement(label);
			var scaleYTxt:TextInput = new TextInput();
			scaleYTxt.width = 80;
			scaleYTxt.height = 20;
			scaleYTxt.x = 205;
			scaleYTxt.y = 75;
			this.addElement(scaleYTxt);
			scaleYTxt.text = data.scaleY + "";
			scaleYTxt.addEventListener(Event.CHANGE,function(e:Event):void {
				data.scaleY = Number(scaleYTxt.text);
			});
			var scaleYFunc:Function = function(e:ComponentAttributeEvent):void {
				scaleYTxt.text = data.scaleY + "";
			}
			data.addEventListener("scaleY",scaleYFunc);
			
			
			var algins:Array = ["top","bottom","left","right"];
			var topAlginChange:Function = function(e:UIEvent):void {
				data.topAlgin = _this.topAlgin.selectedItem.value;
			}
			var leftAlginChange:Function = function(e:UIEvent):void {
				data.leftAlgin = _this.leftAlgin.selectedItem.value;
			}
			var rightAlginChange:Function = function(e:UIEvent):void {
				data.rightAlgin = _this.rightAlgin.selectedItem.value;
			}
			var bottomAlginChange:Function = function(e:UIEvent):void {
				data.bottomAlgin = _this.bottomAlgin.selectedItem.value;
			}
			var alginChangeFuncs:Array = [topAlginChange,bottomAlginChange,leftAlginChange,rightAlginChange];
			
			var leftChange:Function = function(e:Event):void {
				data.left = int(_this.leftTxt.text);
			}
			var rightChange:Function = function(e:Event):void {
				data.right = int(_this.rightTxt.text);
			}
			var topChange:Function = function(e:Event):void {
				data.top = int(_this.topTxt.text);
			}
			var bottomChange:Function = function(e:Event):void {
				data.bottom = int(_this.bottomTxt.text);
			}
			var changes:Array = [topChange,bottomChange,leftChange,rightChange];
			
			var leftChange2:Function = function(e:ComponentAttributeEvent):void {
				_this.leftTxt.text = data.left + "";
			}
			var rightChange2:Function = function(e:ComponentAttributeEvent):void {
				_this.rightTxt.text = data.right + "";
			}
			var topChange2:Function = function(e:ComponentAttributeEvent):void {
				_this.topTxt.text = data.top + "";
			}
			var bottomChange2:Function = function(e:ComponentAttributeEvent):void {
				_this.bottomTxt.text = data.bottom + "";
			}
			var changes2:Array = [topChange2,bottomChange2,leftChange2,rightChange2];
			
			for(var i:int = 0; i < algins.length; i++) {
				label = new Label();
				if(algins[i] == "top") label.text = "顶部对齐:";
				if(algins[i] == "bottom") label.text = "底部对齐:";
				if(algins[i] == "left") label.text = "左边对齐:";
				if(algins[i] == "right") label.text = "右边对齐:";
				label.x = 0;
				label.y = 100 + i*25;
				this.addElement(label);
				
				this[algins[i] + "Algin"] = new DropDownList();
				this[algins[i] + "Algin"].x = 60;
				this[algins[i] + "Algin"].y = 100 + i*25;
				this[algins[i] + "Algin"].width = 90;
				var d:ArrayCollection = new ArrayCollection();
				if(algins[i] == "top" || algins[i] == "bottom") {
					d.addItem({label:"无",value:""});
					d.addItem({label:"对齐顶部",value:"top"});
					d.addItem({label:"对齐底部",value:"bottom"});
				} else if(algins[i] == "left" || algins[i] == "right") {
					d.addItem({label:"无",value:""});
					d.addItem({label:"对齐左边",value:"left"});
					d.addItem({label:"对齐右边",value:"right"});
				}
				this[algins[i] + "Algin"].dataProvider = d;
				this.addElement(this[algins[i] + "Algin"]);
				for(var j:int = 0; j < d.length; j++) {
					if(d.getItemAt(j).value == data[algins[i] + "Algin"]) {
						this[algins[i] + "Algin"].selectedIndex = j;
					}
				}
				var _this:* = this;
				this[algins[i] + "Algin"].addEventListener(UIEvent.VALUE_COMMIT,alginChangeFuncs[i]);
				
				this[algins[i] + "Txt"] = new TextInput();
				this[algins[i] + "Txt"].width = 95;
				this[algins[i] + "Txt"].height = 20;
				this[algins[i] + "Txt"].x = 180;
				this[algins[i] + "Txt"].y = 100 + i*25;
				this.addElement(this[algins[i] + "Txt"]);
				this[algins[i] + "Txt"].text = data[algins[i]] + "";
				this[algins[i] + "Txt"].restrict = "- 0-9";
				this[algins[i] + "Txt"].addEventListener(Event.CHANGE,changes[i]);
				data.addEventListener(algins[i],changes2[i]);
			}
			this.addEventListener(Event.REMOVED_FROM_STAGE,function(e:Event):void {
				_this.topAlgin.removeEventListener(UIEvent.VALUE_COMMIT,topAlginChange);
				_this.bottomAlgin.removeEventListener(UIEvent.VALUE_COMMIT,bottomAlginChange);
				_this.leftAlgin.removeEventListener(UIEvent.VALUE_COMMIT,leftAlginChange);
				_this.rightAlgin.removeEventListener(UIEvent.VALUE_COMMIT,rightAlginChange);
				data.removeEventListener("left",leftChange2);
				data.removeEventListener("right",rightChange2);
				data.removeEventListener("top",topChange2);
				data.removeEventListener("bottom",bottomChange2);
			});
			
			this.height = 200;
		}
	}
}