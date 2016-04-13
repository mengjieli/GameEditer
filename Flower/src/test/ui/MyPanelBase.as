package test.ui
{
	import flower.events.TouchEvent;
	import flower.tween.Ease;
	import flower.tween.Tween;
	import flower.ui.Group;
	import flower.ui.Image;
	import flower.ui.Label;

	dynamic public class MyPanelBase extends Group
	{
		private var bg:Image;
		private var title:Label;
		
		public function MyPanelBase()
		{
			bg = new Image();
			bg.src = "res/test/panelbg.png";
			bg.percentWidth = 100;
			bg.percentHeight = 100;
//			bg.verticalCenterAlgin = "center";
//			bg.verticalCenter = 100;
			this.addChild(bg);
			
			title = new Label();
			title.text = "标题";
			title.color = 0x00ff00;
			title.x = 100;
			title.horizontalCenterAlgin = "center";
			title.horizontalCenter = 0;
			this.addChild(title);
			
			this.onAdded = function():void {
				Tween.to(this,0.4,{scaleX:1,scaleY:1,x:this.x,y:this.y},Ease.CUBIC_EASE_IN_OUT,{scaleX:0,scaleY:0,x:this.x+this.width/2,y:this.y+this.height/2});
				this.title.text = "谁说这个居中不凶的啊?";
			}
				
			this.addListener(TouchEvent.TOUCH_END,function(e:TouchEvent):void {
				this.title.text = "随机数:" + Math.floor(Math.random()*100000000);
				this.title.x = Math.random()*100;
			},this);
		}
	}
}