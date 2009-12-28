package com.max.caverns
{
	import com.adamatomic.flixel.*;
	
	public class CavernBlock extends FlxBlock
	{
		[Embed(source="../../../data/mtnGibs.png")] private var ImgMtnGibs:Class;
		
		public var health:Number;
		public var tileType:String;
		private var _gibs:FlxEmitter;
		
		public function CavernBlock(X:int,Y:int,Width:uint,Height:uint,TileGraphic:Class,Empties:uint=0,health:uint=20) 
		{			
			super(X, Y, Width, Height, TileGraphic, Empties);
			this.health = health;
			tileType = String(TileGraphic);
		}	
		
		virtual public function hurt(Damage:Number):void
		{
			if ((health -= Damage) <= 0)
			{
				kill();
				_gibs = FlxG.state.add(new FlxEmitter(x+width/2,y+height/2,0,0,null,-2,-40,40,-40,30,-720,720,400,0,ImgMtnGibs,10,true)) as FlxEmitter;
				_gibs.reset();
			}
		}
		
		static public function overlapArray(blocks:FlxArray,pickAxe:PickAxe,Collide:Function):void
		{
			var j:uint;
			var block:CavernBlock;
			for(var i:uint = 0; i < blocks.length; i++)
			{
				block = blocks[i];
				if (!block.exists || block.dead) 
					continue;
				if ((pickAxe.exists || !pickAxe.dead) && block.overlaps(pickAxe)) 
					Collide(block,pickAxe);
			}
		}
	}
	
}