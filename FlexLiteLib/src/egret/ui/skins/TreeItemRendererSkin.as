package egret.ui.skins
{
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.ui.components.AutoToggleButton;
	
	/**
	 * 树的项渲染皮肤
	 * @author 雷羽佳
	 */
	public class TreeItemRendererSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgNormal.png")]
		private var upRes:Class;
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgHover.png")]
		private var overRes:Class;
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgDown.png")]
		private var downRes:Class;
		
		public function TreeItemRendererSkin()
		{
			super();
			this.minHeight = 23;
			this.states = ["up","over","down","disabled"]
		}
		
		private var backUI:UIAsset;
		
		public var contentGroup:Group;
		public var disclosureButton:AutoToggleButton;
		public var iconDisplay:UIAsset;
		public var labelDisplay:Label;
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			backUI = new UIAsset(upRes);
			backUI.left = backUI.right = backUI.top = backUI.bottom = 0;
			backUI.scale9Grid = new Rectangle(1,1,1,1);
			this.addElement(backUI);
			
			contentGroup = new Group();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.paddingLeft = 2;
			layout.gap = 1;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			contentGroup.layout = layout;
			contentGroup.top = 0;
			contentGroup.bottom = 0;
			this.addElement(contentGroup);
			
			
			disclosureButton = new AutoToggleButton();
			disclosureButton.skinName = TreeDisclosureButtonSkin;	
			contentGroup.addElement(disclosureButton);
			
			iconDisplay = new UIAsset();
			contentGroup.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.textAlign = TextFormatAlign.CENTER;
			contentGroup.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			if(currentState == "up" || currentState == "disabled")
			{
				backUI.source = upRes;
			}else if(currentState == "over")
			{
				backUI.source = overRes;
			}else if(currentState == "down")
			{
				backUI.source = downRes;
			}
		}
		
	}
}