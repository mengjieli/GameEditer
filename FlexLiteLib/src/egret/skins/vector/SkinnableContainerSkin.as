package egret.skins.vector
{
	import egret.components.Group;
	import egret.skins.VectorSkin;
	
	
	/**
	 * SkinnableContainer默认皮肤
	 * @author dom
	 */
	public class SkinnableContainerSkin extends VectorSkin
	{
		public function SkinnableContainerSkin()
		{
			super();
			this.minHeight = 60;
			this.minWidth = 80;
		}
		/**
		 * [SkinPart]
		 */		
		public var contentGroup:Group;
		
		/**
		 * @inheritDoc
		 */
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
		}
	}
}