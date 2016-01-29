package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.events.UIEvent;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	
	/**
	 * 菜单栏按钮皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class MenuBarItemRendererSkin extends Skin
	{
		public function MenuBarItemRendererSkin()
		{
			super();
			this.states = ["up","down","over"];
		}
		
		public var iconDisplay:UIAsset;
		public var labelDisplay:Label;
		
		private var group:Group;
		public var backUI:Rect;
		
		private var contentGroup:Group;
		override protected function createChildren():void
		{
			super.createChildren();
			
			group = new Group();
			group.top = 0;
			group.bottom = 0;
			this.addElement(group);
			
			backUI = new Rect();
			backUI.top = 0;
			backUI.bottom = 1;
			backUI.left = backUI.right = 0;
			backUI.fillAlpha = 0;
			group.addElement(backUI);
			
			contentGroup = new Group();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
			layout.gap = 0;
			contentGroup.top = contentGroup.bottom = 0;
			contentGroup.layout = layout;
			
			group.addElement(contentGroup);
			
			var space:UIAsset = new UIAsset();
			space.width = 5;
			space.height = 5;
			contentGroup.addElement(space);
				
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			contentGroup.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.percentHeight = 100;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			contentGroup.addElement(labelDisplay);
			space = new UIAsset();
			space.width = 5;
			space.height = 5;
			contentGroup.addElement(space);
			labelDisplay.addEventListener(UIEvent.UPDATE_COMPLETE,updateCompleteHandler);
		}
		
		protected function updateCompleteHandler(event:UIEvent):void
		{
			if(!iconDisplay.source)
			{
				iconDisplay.visible = iconDisplay.includeInLayout = false;
			}else
			{
				iconDisplay.visible = iconDisplay.includeInLayout = true;
			}
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up")
			{
				backUI.fillAlpha = 0;
			}else if(currentState == "over")
			{
				backUI.fillColor = 0x384552;
				backUI.fillAlpha = 1;
			}else if(currentState == "down")
			{
				backUI.fillColor = 0x15191e;
				backUI.fillAlpha = 1;
			}
			
		}
	}
}


