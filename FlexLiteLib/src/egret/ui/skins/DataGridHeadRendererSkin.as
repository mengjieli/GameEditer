package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	
	/**
	 * 数据表格的表头皮肤
	 * @author 雷羽佳
	 */
	public class DataGridHeadRendererSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/arrow_down.png")]
		private var downRes:Class;
		[Embed(source="/egret/ui/skins/assets/arrow_down_r.png")]
		private var downRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/arrow_up.png")]
		private var upRes:Class;
		[Embed(source="/egret/ui/skins/assets/arrow_up_r.png")]
		private var upRes_r:Class;
		
		public function DataGridHeadRendererSkin()
		{
			super();
			this.states = ["up","over","down"]
		}
	
		private var rect1:Rect;
		private var line1:Rect;
		public var labelDisplayGroup:Group;
		public var sortIndicatorGroup:Group;
		public var sortDown:UIAsset;
		public var sortUp:UIAsset;
		public var labelDisplay:Label;
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			rect1 = new Rect();
			rect1.left = rect1.right = rect1.bottom = rect1.top = 0;
			rect1.fillColor = 0x34414c;
			this.addElement(rect1);
			
			var line:Rect = new Rect();
			line.y = 0;
			line.left = 0;
			line.right = 0;
			line.height = 1;
			line.fillColor = 0x1b2025;
			this.addElement(line);
			
			line1 = new Rect();
			line1.y = 0;
			line1.left = line.right = 0;
			line1.height = 1;
			line1.fillColor = 0x1b2025;
			this.addElement(line1);
			
			line = new Rect();
			line.bottom = line.left = line.right = 0;
			line.height = 1;
			line.fillColor = 0x1b2025;
			this.addElement(line);
			
			var hGroup:Group = new Group();
			var hl:HorizontalLayout = new HorizontalLayout();
			hl.gap = 2;
			hl.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = hl;
			hGroup.left = hGroup.right = 7;
			hGroup.percentHeight = 100;
			this.addElement(hGroup);
			
			labelDisplayGroup = new Group();
			labelDisplayGroup.percentWidth = 100;
			hGroup.addElement(labelDisplayGroup);
			
			labelDisplay = new Label();
			labelDisplay.left = 0;
			labelDisplay.right = 0;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplayGroup.addElement(labelDisplay);
			
			sortIndicatorGroup = new Group();
			sortIndicatorGroup.includeInLayout = false;
			hGroup.addElement(sortIndicatorGroup);
			
			sortDown = new UIAsset();
			sortDown.source = new BitmapSource(downRes,downRes_r);
			sortDown.includeInLayout = false;
			sortDown.visible = false;
			sortIndicatorGroup.addElement(sortDown);
			
			sortUp = new UIAsset();
			sortUp.source = new BitmapSource(upRes,upRes_r);
			sortUp.includeInLayout = false;
			sortUp.visible = false;
			sortIndicatorGroup.addElement(sortUp);
			
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up")
			{
				rect1.fillColor = 0x34414c;
				line1.visible = true;
			}else if(currentState == "over")
			{
				rect1.fillColor = 0x3b4853;
				line1.visible = true;
			}else if(currentState == "down")
			{
				rect1.fillColor = 0x1e2329;
				line1.visible = false;
			}
		}
	}
}