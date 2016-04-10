package test
{
	import flower.Engine;
	import flower.display.Sprite;
	import flower.events.TouchEvent;
	import flower.tween.Ease;
	import flower.tween.Tween;
	import flower.ui.Button;
	import flower.ui.Group;
	import flower.ui.Image;
	import flower.ui.Label;

	public class TestUI extends Sprite
	{
		public function TestUI()
		{
			Engine.getInstance().addChild(this);
			
			var button:Button = new Button();
			button.onAdded = function():void {
				Tween.to(this,3,{alpha:1,x:300,y:300},Ease.CUBIC_EASE_IN_OUT,{alpha:0});
			}
			this.addChild(button);
			var group:Group = new Group();
			button.addChild(group);
			var image:Image = new Image();
			group.addChild(image);
			image.setStatePropertyValue("source","up","res/test/closeup.png");
			image.setStatePropertyValue("source","down","res/test/closedown.png");
			var label:Label = new Label();
			group.addChild(label);
			label.color = 0xffffff;
			label.size = 15;
			label.x = 5;
			label.y = 5;
			label.text = "未设置任何属性";
			label.setStatePropertyValue("text","up","弹起");
			label.setStatePropertyValue("text","down","按下");
			label.setStatePropertyValue("text","disabled","禁止");
			label.setStatePropertyValue("scaleX","up","1");
			label.setStatePropertyValue("scaleX","down","1.2");
			label.setStatePropertyValue("scaleX","disabled","1");
			label.setStatePropertyValue("scaleY","up","1");
			label.setStatePropertyValue("scaleY","down","1.2");
			label.setStatePropertyValue("scaleY","disabled","1");
			label.setStatePropertyValue("color","up","0xff0000");
			label.setStatePropertyValue("color","disabled","0xaaaaaa");
			
			this.addListener(TouchEvent.TOUCH_END,function(e:TouchEvent):void{
				trace("touch testui");
			},this);
			
			var button2:Button = new Button();
			button2.x = 100;
			button2.onClick = function():void {
				Tween.to(this,0.3,{scaleX:2,scaleY:2},Ease.NONE,{scaleX:1,scaleY:1});
			}
			this.addChild(button2);
			var image:Image = new Image();
			button2.addChild(image);
			image.source = "res/test/closeup.png";
			image.setStatePropertyValue("source","up","res/test/closeup.png");
			image.setStatePropertyValue("source","down","res/test/closedown.png");
			button2.addListener(TouchEvent.TOUCH_END,function(e:TouchEvent):void {
				button.enabled = !button.enabled;
			},this);
			var label:Label = new Label();
			button2.addChild(label);
			label.color = 0xff0000;
			label.size = 18;
			label.x = 5;
			label.y = 5;
			label.text = "未设置任何属性";
			label.setStatePropertyValue("text","up","弹起");
			label.setStatePropertyValue("text","down","按下");
			label.setStatePropertyValue("text","disabled","禁止");
			
//			image = new Image();
//			this.addChild(image);
//			image.x = 100;
//			image.y = 100;
//			image.source = "res/test/closeup.png";
			
//			Tween.to(image,3,{x:500,y:400});
		}
	}
}