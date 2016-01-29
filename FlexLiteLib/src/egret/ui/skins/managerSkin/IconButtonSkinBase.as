package egret.ui.skins.managerSkin
{
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * 图标按钮基类 
	 * @author dom
	 */	
	public class IconButtonSkinBase extends Skin
	{
		private var back:UIAsset;
		
		public function IconButtonSkinBase()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			back = new UIAsset();
			back.horizontalCenter = 0;
			back.verticalCenter = 0;
			addElement(back);
			var rect:Rect = new Rect();
			rect.fillAlpha = 0;
			rect.percentHeight = rect.percentWidth = 100;
			addElement(rect);
		}
		
		override protected function commitCurrentState():void
		{
			back.alpha = 1;
			switch(currentState)
			{
				case "up":
					back.source = this["upSkinName"];
					break;
				case "over":
					back.source = this["overSkinName"];
					break;
				case "down":
					back.source = this["downSkinName"];
					break;
				case "disabled":
					if(this["disabledSkinName"])
						back.source = this["disabledSkinName"];
					else
						back.alpha = 0.6;
					break;
			}
		}
	}
}


