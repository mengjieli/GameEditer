package view
{
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ReaderBase;
	
	import view.attributesEditer.ComponentAttributeEditerPanel;

	public class ViewReader extends ReaderBase
	{
		private var toolBar:ViewEditerToolBar;
		private var editer:ViewEditePanel;
		private  var attribute:ComponentAttributeEditerPanel;
		
		public function ViewReader()
		{
			toolBar = new ViewEditerToolBar();
			this.addElement(toolBar);
			this.toolBar.left = 0;
			this.toolBar.right = 300;
			toolBar.height = 24;
			toolBar.dataProvider=new XMLList(
				'<node icon="assets/component/Label.png" id="Label" tooltip="标签"/>'
//				+ '<node icon="assets/component/TextInput.png" id="TextInput" tooltip="输入框"/>'
				+ '<node  type="spliter"/>'
				+ '<node icon="assets/component/Image.png" id="Image" tooltip="图片"/>'
				+ '<node  type="spliter"/>'
//				+ '<node icon="assets/component/Button.png" id="Button" tooltip="按钮"/>'
				+ '<node  type="spliter"/>'
				+ '<node icon="assets/component/Group.png" id="Group" tooltip="容器"/>'
				+ '<node  type="spliter"/>'
			);
			
			this.editer = new ViewEditePanel();
			this.editer.left = 0;
			this.editer.right = 300;
			this.editer.top = 24;
			this.editer.bottom = 0;
			this.addElement(this.editer);
			
			this.attribute = new ComponentAttributeEditerPanel();
			this.attribute.width = 300;
			this.attribute.right = 0;
			this.attribute.top = 0;
			this.attribute.bottom = 0;
			this.addElement(this.attribute);
		}
		
		override public function showData(d:DirectionDataBase):void {
			super.showData(d);
			this.title = d.desc==""?d.name:d.desc;
			this.icon = d.fileIcon;
			var viewData:ViewData = d as ViewData;
			this.editer.showView(viewData);
			//			trace(ToolData.getInstance().project.getResURL(d.url));
		}
	}
}