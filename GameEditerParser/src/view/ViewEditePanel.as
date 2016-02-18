package view
{
	import egret.components.Group;
	import egret.components.UIAsset;
	import egret.core.BitmapFillMode;
	import egret.events.UIEvent;

	/**
	 * TODO
	 * 编辑界面相关
	 * 1. 自动对齐功能，可以设置自动对齐的像素大小
	 * 2. 在父对象内有居中对齐吸附
	 * 3. 点击某个对象之后就再拖动元素并释放时元素有相交区域就可以放入该元素之中，并且在拖动时有智能提示哪个是 parent (有个透明的 parent 字样的底框标明，并且父对象有描边效果)
	 * 4. 在拖动时下方有提示在面板上的位置，和在父类对象中的位置，以及父对象的名称
	 */
	public class ViewEditePanel extends Group
	{
		private var backGround:UIAsset;
		private var container:Group;
		
		public function ViewEditePanel()
		{
			backGround = new UIAsset();
			backGround.source = "assets/bg/viewBg.png";
			backGround.fillMode = BitmapFillMode.SCALE;
			backGround.percentWidth = 100;
			backGround.percentHeight = 100;
			this.addElement(backGround);
			
			var mask:UIAsset = new UIAsset();
			mask.source = "assets/bg/viewBg.png";
			mask.fillMode = BitmapFillMode.SCALE;
			mask.percentWidth = 100;
			mask.percentHeight = 100;
			this.addElement(mask);
			
			container = new Group();
			this.addElement(container);
			container.mask = mask;
			container.graphics.lineStyle(1,0xffffff);
			container.graphics.moveTo(-5,0);
			container.graphics.lineTo(5,0);
			container.graphics.moveTo(0,-5);
			container.graphics.lineTo(0,5);
			container.graphics.endFill();
			container.x = 100;
			container.y = 100;
			
			this.addEventListener(UIEvent.CREATION_COMPLETE,onCreateComplete);
		}
		
		private function onCreateComplete(e:UIEvent):void {
			container.x = this.width/2;
			container.y = this.height/2;
		}
	}
}