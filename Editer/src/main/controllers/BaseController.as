package main.controllers
{
	import egret.ui.components.Application;

	/**
	 *控制器基类 
	 * @author Grayness
	 */	
	public class BaseController
	{
		public function BaseController()
		{
		}
		private var _applacation:Application;
		public function start(app:Application):void
		{
			_applacation=app;
		}
		public function get appLication():Application
		{
			return _applacation;
		}
	}
}