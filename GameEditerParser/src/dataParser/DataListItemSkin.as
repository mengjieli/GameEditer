package dataParser
{
	import egret.components.Skin;
	
	import extend.ui.Input;

	public class DataListItemSkin extends Skin
	{
		public function DataListItemSkin()
		{
		}
		
		public var nameTxt:Input;
		public var descTxt:Input;
		public var typeTxt:Input;
		public var typeValueTxt:Input;
		
		override protected function createChildren():void {
			super.createChildren();
			
			nameTxt = new Input();
			nameTxt.border = true;
			nameTxt.backgorund = true;
			nameTxt.width = 150;
			nameTxt.height = 20;
			nameTxt.x = 10;
			nameTxt.verticalCenter = 0;
			nameTxt.textColor = 0;
			this.addElement(nameTxt);
			
			descTxt = new Input();
			descTxt.border = true;
			descTxt.backgorund = true;
			descTxt.width = 150;
			descTxt.height = 20;
			descTxt.x = 180;
			descTxt.verticalCenter = 0;
			descTxt.textColor = 0;
			this.addElement(descTxt);
			
			typeTxt = new Input();
			typeTxt.border = true;
			typeTxt.backgorund = true;
			typeTxt.width = 150;
			typeTxt.height = 20;
			typeTxt.x = 350;
			typeTxt.verticalCenter = 0;
			typeTxt.textColor = 0;
			this.addElement(typeTxt);
			
			typeValueTxt = new Input();
			typeValueTxt.border = true;
			typeValueTxt.backgorund = true;
			typeValueTxt.width = 150;
			typeValueTxt.height = 20;
			typeValueTxt.x = 520;
			typeValueTxt.verticalCenter = 0;
			typeValueTxt.textColor = 0;
			this.addElement(typeValueTxt);
		}
	}
}