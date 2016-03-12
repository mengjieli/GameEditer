package linshi
{
	public class PlayerProperty
	{
		public var minAttack = 0;
		public var maxAttack = 0;
		public var minMagicAttack = 0;
		public var maxMagicAttack = 0;
		public var defense = 0;
		public var magicDefense = 0;
		public var hit = 0;
		public var dodge = 0;
		public var crit = 0;
		public var toughness = 0;
		public var move = 0;
		public var attackSpeed = 0;
		public var hp = 0;
		public var mp = 0;
		public var maxHp = 0;
		public var maxMp = 0;
		public var moveSpeed = 0;
		public var aggressivity = 0;//攻击力 侵略性
		public var forceValue = 0;//战斗力
		
		public function PlayerProperty()
		{
			
		}
		
		
		public function receive(forceValue, atrrTypeInfos)
		{
			var len:int = atrrTypeInfos.length;
			for (var i = 0; i < len; i++)
			{
				var info = atrrTypeInfos[i];
				var value = info.value;
				switch (info.attr_type)
				{
					case attributeNameEnum.AT_MAX_HP:
						this.maxHp = value;
						break;
					case attributeNameEnum.AT_HP:
						this.hp = value;
						break;
					case attributeNameEnum.AT_MAX_MP:
						this.maxMp = value;
						break;
					case attributeNameEnum.AT_MP:
						this.mp = value;
						break;
					case attributeNameEnum.AT_MAX_PHYSICAL_ATTACK:
						this.maxAttack = value;
						break;
					case attributeNameEnum.AT_MIN_PHYSICAL_ATTACK:
						this.minAttack = value;
						break;
					case attributeNameEnum.AT_MAX_MAGIC_ATTACK:
						this.maxMagicAttack = value;
						break;
					case attributeNameEnum.AT_MIN_MAGIC_ATTACK:
						this.minMagicAttack = value;
						break;
					case attributeNameEnum.AT_DEFENCE:
						this.defense = value;
						break;
					case attributeNameEnum.AT_HIT:
						this.hit = value;
						break;
					case attributeNameEnum.AT_MAGIC_DEFENCE:
						this.magicDefense = value;
						break;
					case attributeNameEnum.AT_DODEG:
						this.dodge = value;
						break;
					case attributeNameEnum.AT_CRIT:
						this.crit = value;
						break;
					case attributeNameEnum.AT_TOUGHNESS:
						this.toughness = value;
						break;
					case attributeNameEnum.AT_MOVE_SPEED:
						this.moveSpeed = value;
						break;
					case attributeNameEnum.AT_AGGRESSIVITY:
						this.aggressivity = value;
						break;
					case attributeNameEnum.AT_ATTACK_SPEED:
						this.attackSpeed = value;
						break;
				}
			}
			this.forceValue = forceValue;
		}
		
		private const attributeNameEnum =
			{
				AT_MAX_HP:1,
				AT_HP:2,
				AT_MAX_MP:3,
				AT_MP:4,
				AT_MAX_PHYSICAL_ATTACK:5,
				AT_MIN_PHYSICAL_ATTACK:6,
				AT_MAX_MAGIC_ATTACK:7,
				AT_MIN_MAGIC_ATTACK:8,
				AT_DEFENCE:9,
				AT_HIT:10,
				AT_MAGIC_DEFENCE:11,
				AT_DODEG:12,
				AT_CRIT:13,
				AT_TOUGHNESS:14,
				AT_MOVE_SPEED:15,
				AT_AGGRESSIVITY:16,
				AT_ATTACK_SPEED:17
			}
	}
}