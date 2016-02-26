package view.component
{
	import flash.geom.Rectangle;

	public class Group extends ComponentBase
	{
		public function Group()
		{
			this.show.source = "assets/componentCustom/Group/bg.png";
			this.show.scale9Grid = new Rectangle(1,1,8,8);
			this.a_width = 400;
			this.a_height = 300;
		}
	}
}