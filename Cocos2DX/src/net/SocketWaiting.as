package net
{
	public class SocketWaiting
	{
		public static const msgs:Object = {
			401:406,
			311:314,
			603:604,
			605:606,
			607:608,
			//魂元
			505:512,
			507:514,
			509:508,
			511:518,
			513:520,
			515:516,
			517:510,
			205:206,
			//登陆
			107:108,
			109:108,
			111:112,
			113:114,
			//场景
			405:406,
			401:406
		};
		
		public static const cds:Object = {
			205:1,
			405:0,
			401:0
		}
		
		public static function getIdByReceive(id):Array
		{
			var list:Array = [];
			for(var o in msgs)
			{
				if(msgs[o] == id)
				{
					list.push(o);
				}
			}
			return list;
		}
	}
}