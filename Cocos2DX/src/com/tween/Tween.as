package com.tween
{
	import com.jc.ui.utils.EnterFrame;

	public class Tween
	{
		public var owner:*;
		public var dur:Number;
		public var parmas:Array;
		public var endComplete:Function;
		
		//parmas : [{val:5,to:10,update:function}]
		public function Tween(owner:*,dur:Number,parmas:Array,endComplete:Function=null)
		{
			this.owner = owner;
			this.dur = dur;
			this.parmas = parmas;
			this.endComplete = endComplete;
			
			var info:Object;
			for(var i:int = 0; i < parmas.length; i++)
			{
				info = parmas[i];
				if(info.add == null) info.add = (info.to - info.val)/dur;
			}
			
			EnterFrame.add(update,this);
		}
		
		public function update(delate:Number):void
		{
			if(delate > this.dur) delate = this.dur;
			this.dur -= delate;
			var info;
			for(var i = 0; i < this.parmas.length; i++)
			{
				info = this.parmas[i];
				if(info.hasOwnProperty("addV"))
				{
					if(info.hasOwnProperty("addMax") && ((info.addV < 0 && info.add + info.addV*delate < info.addMax) || (info.addV > 0 && info.add + info.addV*delate > info.addMax)))
					{
						info.val += ((info.add + info.addMax)/2)*delate;
						info.add = info.addMax;
					}
					else
					{
						info.val += ((info.add + info.add + info.addV*delate)/2)*delate;
						info.add += info.addV*delate;
					}
				}
				else
				{
					info.val += info.add*delate;
				}
				info.update.apply(this.owner,[info.val]);
			}
			if(this.dur == 0)	//end
			{
				if(this.endComplete != null) this.endComplete.apply(this.owner);
				EnterFrame.del(this.update,this);
			}
		}
		
		
		public function gc():void
		{
			EnterFrame.del(update,this);
		}
	}
}