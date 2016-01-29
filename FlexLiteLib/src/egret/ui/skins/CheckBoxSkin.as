package egret.ui.skins
{
	import flash.text.TextFormatAlign;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	import egret.layouts.VerticalAlign;
	
	/**
	 * 复选框皮肤
	 * @author 雷羽佳
	 */
	public class CheckBoxSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/unSelectNormal.png")]
		private var unSelectedNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/unSelectNormal_r.png")]
		private var unSelectedNormalRes_r:Class;
		
		private var unSelectedNormalSource:BitmapSource = new BitmapSource(unSelectedNormalRes,unSelectedNormalRes_r);
		
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/unSelectHover.png")]
		private var unSelectedHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/unSelectHover_r.png")]
		private var unSelectedHoverRes_r:Class;
		
		private var unSelectedHoverSource:BitmapSource = new BitmapSource(unSelectedHoverRes,unSelectedHoverRes_r);
		
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/selectNormal.png")]
		private var selectedNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/selectNormal_r.png")]
		private var selectedNormalRes_r:Class;
		
		private var selectedNormalSource:BitmapSource = new BitmapSource(selectedNormalRes,selectedNormalRes_r);
		
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/selectHover.png")]
		private var selectedHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/checkBoxBtn/selectHover_r.png")]
		private var selectedHoverRes_r:Class;
		
		private var selectedHoverSource:BitmapSource = new BitmapSource(selectedHoverRes,selectedHoverRes_r);
		
		public function CheckBoxSkin()
		{
			super();
			this.states = ["up","over","down","disabled","upAndSelected","overAndSelected","downAndSelected","disabledAndSelected"];
		}
		
		private var icon:UIAsset;
		public var labelDisplay:Label;
		private var gorup:Group;
		override protected function createChildren():void
		{
			super.createChildren();
			gorup = new Group();
			this.addElement(gorup);
			
			icon = new UIAsset();
			icon.verticalCenter = 0;
			gorup.addElement(icon);

			labelDisplay = new Label();
			labelDisplay.textAlign = TextFormatAlign.LEFT;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.left = 18;
			labelDisplay.right = 0;
			labelDisplay.verticalCenter = 0;
			gorup.addElement(labelDisplay);	
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up" || currentState == "disabled")
			{
				icon.source = unSelectedNormalSource;
			}else if(currentState == "over" || currentState == "down")
			{
				icon.source = unSelectedHoverSource;
			}else if(currentState == "upAndSelected" || currentState == "disabledAndSelected")
			{
				icon.source = selectedNormalSource;
			}else if(currentState == "downAndSelected" || currentState == "overAndSelected" )
			{
				icon.source = selectedHoverSource;
			}
			if(currentState == "disabled" || currentState == "disabledAndSelected")
			{
				gorup.alpha = 0.5;
			}else
			{
				gorup.alpha = 1;
			}
			
		}
	}
}