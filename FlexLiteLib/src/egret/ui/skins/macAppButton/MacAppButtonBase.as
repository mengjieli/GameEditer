package egret.ui.skins.macAppButton
{
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 * win窗体的按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class MacAppButtonBase extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonDisabled.png")]
		private var disableRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonDisabled_r.png")]
		private var disableRes_r:Class;
		
		protected var disableSource:Object = new BitmapSource(disableRes,disableRes_r);
		
		protected var upSource:Object;
		protected var overSource:Object;
		protected var downSource:Object;
		
		private var ui1:UIAsset;
		private var ui2:UIAsset;
		private var ui3:UIAsset;
		private var ui4:UIAsset;
		public function MacAppButtonBase()
		{
			super();
			this.states = ["up","over","down","disabled"];
			
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			this.width=34; 
			this.height=26;
			
			ui1 = new UIAsset()
			ui1.source = upSource;
			this.addElement(ui1);
			
			ui2 = new UIAsset()
			ui2.source = overSource;
			this.addElement(ui2);
			
			ui3 = new UIAsset()
			ui3.source = downSource;
			this.addElement(ui3);
			
			ui4 = new UIAsset()
			ui4.source = disableSource;
			this.addElement(ui4);
		}
		
		override protected function commitCurrentState():void
		{
			switch(currentState)
			{
				case "up":
				{
					ui1.visible = true;
					ui2.visible = false;
					ui3.visible = false;
					ui4.visible = false;
					break;
				}
				case "over":
				{
					ui1.visible = false;
					ui2.visible = true;
					ui3.visible = false;
					ui4.visible = false;
					break;
				}
				case "down":
				{
					ui1.visible = false;
					ui2.visible = false;
					ui3.visible = true;
					ui4.visible = false;
					break;
				}
				case "disabled":
				{
					ui1.visible = false;
					ui2.visible = false;
					ui3.visible = false;
					ui4.visible = true;
					break;
				}	
				default:
				{
					break;
				}
			}
		}
	}
}


