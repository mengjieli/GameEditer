package egret.ui.skins
{
	import flash.text.TextFormatAlign;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.ns_egret;
	import egret.layouts.VerticalAlign;
	
	use namespace ns_egret;
	
	/**
	 * ItemRenderer默认皮肤
	 * @author dom
	 */
	public class DefaultItemRendererSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgNormal.png")]
		private var upRes:Class;
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgHover.png")]
		private var overRes:Class;
		[Embed(source="/egret/ui/skins/assets/itemRenderer/bgDown.png")]
		private var downRes:Class;
		
		public function DefaultItemRendererSkin()
		{
			super();
			states = ["up","over","down","disabled"];
			this.height = 23;
			this.minHeight = 23;
			this.minWidth = 23;
		}
		
		protected var group:Group;
		public var labelDisplay:Label;

		protected var backUI:UIAsset;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			group = new Group();
			group.left = group.right = group.bottom = group.top = 0;
			this.addElement(group);
			
			backUI = new UIAsset();
			backUI.left = backUI.right = backUI.top = backUI.bottom = 0;
			backUI.source = upRes;
			group.addElement(backUI);
			
			labelDisplay = new Label();
			labelDisplay.textAlign = TextFormatAlign.LEFT;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.left = 5;
			labelDisplay.right = 5;
			labelDisplay.verticalCenter = 0;
			group.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			group.alpha = 1;
			switch(currentState)
			{
				case "up":
				{
					backUI.source = upRes;
					break;
				}
				case "over":
				{
					backUI.source = overRes;
					break;
				}
				case "down":
				{
					backUI.source = downRes;
					break;
				}
				case "disabled":
				{
					backUI.source = upRes;
					group.alpha = 0.5;
					break;
				}
			}
		}
	}
}


