package
{
	import game.datas.client.configs.roler.RolerConfig;
	import game.datas.client.configs.tables.MapMonsterTable;
	import game.datas.client.configs.tables.MapTable;
	import game.datas.client.configs.tables.MonsterTable;
	import game.maps.rolers.RolerState;

	public class CheckMonsterAction
	{
		public function CheckMonsterAction()
		{
			var mid:int;
			for(var i:int = 0; i < MapMonsterTable.table_data.length; i++)
			{
				if(i == 22)
					trace("?");
				if(MapTable.getData(MapMonsterTable.table_data[i][2]) == null) continue;
				if(MapMonsterTable.table_data[i][3] != 1) continue;
				mid = MapMonsterTable.table_data[i][1];
				if(MonsterTable.getData(mid) == null)
				{
					trace("怪物表中没有此怪：" + mid);
				}
				mid = MonsterTable.getData(mid).imageId;
				if(RolerConfig.getActionCfg(mid,RolerState.Stand,1) == null)
				{
					trace("缺少站立动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.Run,1) == null)
				{
					trace("缺少跑步动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.Attack,1) == null)
				{
					trace("缺少攻击动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.Hurt,1) == null)
				{
					trace("缺少受伤动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.Die,1) == null)
				{
					trace("缺少死亡动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.HurtFly,1) == null)
				{
					trace("缺少击飞动作：" + mid);
				}
				if(RolerConfig.getActionCfg(mid,RolerState.HurtLie,1) == null)
				{
					trace("缺少倒地动作：" + mid);
				}
			}
		}
	}
}