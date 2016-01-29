package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	import egret.layouts.VerticalAlign;

	/**
	 * 可折叠窗体的顶部的按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class AccordionButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/accordionBtn/bgNormal.png")]
		private var bgNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordionBtn/bgHover.png")]
		private var bgHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordionBtn/bgDown.png")]
		private var bgDownRes:Class;
		
		[Embed(source="/egret/ui/skins/assets/accordionBtn/iconClose.png")]
		private var iconCloseRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordionBtn/iconClose_r.png")]
		private var iconCloseRes_r:Class;
		
		private var iconCloseSource:BitmapSource = new BitmapSource(iconCloseRes,iconCloseRes_r);
		
		[Embed(source="/egret/ui/skins/assets/accordionBtn/iconOpen.png")]
		private var iconOpenRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordionBtn/iconOpen_r.png")]
		private var iconOpenRes_r:Class;
		
		private var iconOpenSource:BitmapSource = new BitmapSource(iconOpenRes,iconOpenRes_r);
		
		public function AccordionButtonSkin()
		{
			super();
			states = ["up","over","down","disabled","upAndSelected","overAndSelected"
				,"downAndSelected","disabledAndSelected"];
			this.currentState = "up";
		}
		
		private var bg:UIAsset;
		private var icon:UIAsset;
		public var labelDisplay:Label;
		public var iconDisplay:UIAsset;
		private var group:Group;
		override protected function createChildren():void
		{
			super.createChildren();
			
			group = new Group();
			group.height = 23;
			group.minWidth = 20;
			group.top = 1;
			group.left = 0;
			group.right = 0;
			this.addElement(group);
			
			var line:Rect = new Rect();
			line.top = -1;
			line.right = line.left = 1;
			line.bottom = -1;
			line.fillColor = 0x1b2025;
			group.addElement(line);
			
			bg = new UIAsset();
			bg.left = bg.right = bg.top = bg.bottom = 0;
			bg.scale9Grid = new Rectangle(1,1,1,1);
			bg.source = bgNormalRes;
			group.addElement(bg);
			
			icon = new UIAsset();
			icon.source = iconCloseSource;
			group.addElement(icon);
			icon.x = 8;
			icon.verticalCenter = 0;
			
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			iconDisplay.x = 30; 
			group.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.left = 53;
			labelDisplay.right = 10;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.verticalCenter = 0;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			group.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(
				currentState == "up" || 
				currentState == "over" || 
				currentState == "down" || 
				currentState == "disabled")
			{
				icon.source = iconCloseSource;
			}else if(
				currentState == "upAndSelected" || 
				currentState == "overAndSelected" || 
				currentState == "downAndSelected" || 
				currentState == "disabledAndSelected")
			{
				icon.source = iconOpenSource;
			}
			
			if(currentState == "up" || currentState == "disabled" || currentState == "upAndSelected" || currentState == "disabledAndSelected")
			{
				bg.source = bgNormalRes;
			}else if(currentState == "over"|| currentState == "overAndSelected")
			{
				bg.source = bgHoverRes;
			}else if(currentState == "down" || currentState == "downAndSelected")
			{
				bg.source = bgDownRes;
			}
			
			
			if(currentState == "disabled" || currentState == "disabledAndSelected")
			{
				group.alpha = 0.5;
			}else
			{
				group.alpha = 1;
			}
		}
		
		
	}
}