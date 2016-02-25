package view
{
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.ReaderBase;

	public class ViewReader extends ReaderBase
	{
		private var toolBar:ViewEditerToolBar;
		private var editer:ViewEditePanel;
		
		public function ViewReader()
		{
			toolBar = new ViewEditerToolBar();
			this.addElement(toolBar);
			toolBar.percentWidth = 100;
			toolBar.height = 24;
			toolBar.dataProvider=new XMLList(
				'<node icon="assets/component/Label.png" id="Label" tooltip="标签"/>'
				+ '<node icon="assets/component/TextInput.png" id="TextInput" tooltip="输入框"/>'
				+ '<node  type="spliter"/>'
				+ '<node icon="assets/component/Image.png" id="Image" tooltip="图片"/>'
				+ '<node  type="spliter"/>'
				+ '<node icon="assets/component/Button.png" id="Button" tooltip="按钮"/>'
				+ '<node  type="spliter"/>'
			);
			
			this.editer = new ViewEditePanel();
			this.editer.percentWidth = 100;
			this.addElement(this.editer);
			this.editer.top = 24;
			this.editer.bottom = 0;
		}
		
		override public function showData(d:DirectionDataBase):void {
			super.showData(d);
			this.title = d.desc==""?d.name:d.desc;
			this.icon = d.fileIcon;
			var viewData:ViewData = d as ViewData;
			//			trace(ToolData.getInstance().project.getResURL(d.url));
		}
	}
}