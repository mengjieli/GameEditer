package main.model.errorTipModel
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	import egret.components.Group;
	import egret.components.Label;

	public class TipModel extends Group 
	{
		private var list:Vector.<Label> = new Vector.<Label>();
		
		public function TipModel()
		{
			ist = this;
			
			this.percentWidth = 100;
			this.percentHeight = 100;
		}
		
		public function show(tip:String,color:uint):void {
			var y:Number = 100;
			if(list.length) {
				y = list[list.length-1].y + 25;
			}
			var label:Label = new Label();
			label.horizontalCenter = 0;
			label.y = y;
			label.text = tip;
			label.textColor = color;
			label.bold = true;
			label.filters = [new GlowFilter(0,1,4,4)];
			label.size = 14;
			this.addElement(label);
			list.push(label);
			var start:Number = (new Date()).time;
			var _this:TipModel = this;
			var func:Function = function(e:Event):void{
				var now:Number = (new Date()).time;
				if(now - start < 500) {
					label.alpha = (now - start)/500;
				} 
				else if(now - start < 3000) {
					
				} else if(now - start < 3500) {
					label.alpha = 1 - (now - start - 3000)/500;
				} else {
					label.removeEventListener(Event.ENTER_FRAME,func);
					_this.removeElement(label);
					for(var i:Number = 0; i < list.length;i++) {
						if(list[i] == label) {
							list.splice(i,1);
							break;
						}
					}
				}
			};
			label.addEventListener(Event.ENTER_FRAME,func);
		}
		
		private static var ist:TipModel;
		public static function show(tip:String,color:uint=0x12e719):void {
			ist.show(tip,color);
		}
	}
}