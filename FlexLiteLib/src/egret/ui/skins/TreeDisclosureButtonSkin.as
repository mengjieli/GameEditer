package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 *
	 * @author 雷羽佳
	 */
	public class TreeDisclosureButtonSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/accordion_close.png")]
		private var closeRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordion_close_r.png")]
		private var closeRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/accordion_open.png")]
		private var openRes:Class;
		[Embed(source="/egret/ui/skins/assets/accordion_open_r.png")]
		private var openRes_r:Class;
		
		public function TreeDisclosureButtonSkin()
		{
			states = ["up","over","down","disabled","upAndSelected","overAndSelected"
				,"downAndSelected","disabledAndSelected"];
			this.currentState = "up";
		}
		
		private var group:Group;
		private var ui1:UIAsset;
		private var ui2:UIAsset;
		
		override protected function createChildren():void
		{
			super.createChildren();
			group = new Group();
			group.percentHeight = 100;
			group.width = 15;
			this.addElement(group);
			
			ui1 = new UIAsset();
			ui1.source = new BitmapSource(closeRes,closeRes_r);
			ui1.horizontalCenter = 0;
			ui1.verticalCenter = 0;
			group.addElement(ui1);
			
			ui2 = new UIAsset();
			ui2.source = new BitmapSource(openRes,openRes_r);
			ui2.horizontalCenter = 0;
			ui2.verticalCenter = 0;
			group.addElement(ui2);
			
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "disabledStates" || currentState=="disabled")
			{
				group.alpha = 0.5;
			}else
			{
				group.alpha = 1;	
			}
			
			if(currentState == "up" || currentState == "over" || currentState == "down" || currentState == "disabled")
			{
				ui1.visible = true;
				ui2.visible = false;
			}else
			{
				ui1.visible = false;
				ui2.visible = true;
			}
			
		}
	}
}