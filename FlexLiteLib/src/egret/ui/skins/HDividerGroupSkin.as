package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Skin;
	
	/**
	 * @author xzper
	 */
	public class HDividerGroupSkin extends Skin
	{
		public function HDividerGroupSkin()
		{
			super();
		}
		
		public var dividerLine:Class = DividerLine;
		public var contentGroup:Group;
		public var dividerGroup:Group;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			contentGroup = new Group();
			contentGroup.top = 0;
			contentGroup.left = 0;
			contentGroup.right = 0;
			contentGroup.bottom = 0;
			contentGroup.clipAndEnableScrolling = true;
			addElement(contentGroup);
			
			dividerGroup = new Group();
			dividerGroup.top = 0;
			dividerGroup.left = 0;
			dividerGroup.right = 0;
			dividerGroup.bottom = 0;
			dividerGroup.clipAndEnableScrolling = true;
			addElement(dividerGroup);
		}
		
	}
}
import egret.components.Rect;

class DividerLine extends Rect
{
	public function DividerLine()
	{
		super();
		this.percentHeight = 100;
		this.width = 2;
		this.fillColor = 0x374552;
	}
}