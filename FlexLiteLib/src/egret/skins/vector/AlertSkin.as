package egret.skins.vector
{
	import flash.text.TextFormatAlign;
	
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Label;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	
	/**
	 * Alert默认皮肤
	 * @author dom
	 */
	public class AlertSkin extends TitleWindowSkin
	{
		/**
		 * 构造函数
		 */		
		public function AlertSkin()
		{
			super();
			this.minHeight = 100;
			this.minWidth = 170;
			this.maxWidth = 310;
		}
		
		/**
		 * [SkinPart]文本内容显示对象
		 */		
		public var contentDisplay:Label;
		/**
		 * [SkinPart]第一个按钮，通常是"确定"。
		 */		
		public var firstButton:Button;
		/**
		 * [SkinPart]第二个按钮，通常是"取消"。
		 */		
		public var secondButton:Button;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			contentDisplay = new Label;
			contentDisplay.top = 30;
			contentDisplay.left = 1;
			contentDisplay.right = 1;
			contentDisplay.bottom = 36;
			contentDisplay.verticalAlign = VerticalAlign.MIDDLE;
			contentDisplay.textAlign = TextFormatAlign.CENTER;
			contentDisplay.padding = 10;
			contentDisplay.selectable = true;
			addElementAt(contentDisplay,0);
			
			var hGroup:Group = new Group;
			hGroup.bottom = 10;
			hGroup.horizontalCenter = 0;
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.horizontalAlign = HorizontalAlign.CENTER;
			layout.gap = 10;
			layout.paddingLeft = layout.paddingRight = 20;
			hGroup.layout = layout;
			addElement(hGroup);
			
			firstButton = new Button();
			firstButton.label = "确定";
			hGroup.addElement(firstButton);
			secondButton = new Button();
			secondButton.label = "取消";
			hGroup.addElement(secondButton);
		}
	}
}