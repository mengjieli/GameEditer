package flower
{
	import flower.core.TimeLine;
	import flower.utils.JSON;

	public class Engine
	{
		public function Engine()
		{
			System.start();
			flower.utils.JSON.parser = System.JSON_parser;
			flower.utils.JSON.stringify = System.JSON_stringify
			System.runTimeLine(TimeLine.$run);
		}
	}
}