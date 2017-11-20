package com.max.caverns {
	import org.flixel.*;
	
	public class CavernBlock extends FlxTileblock {
		
		[Embed(source="../../../data/mtnGibs.png")] private var ImgMtnGibs:Class;
		
		public var tileType:String;
		private var _gibs:FlxEmitter;
		private var waterAmount:int;
		
		public function CavernBlock(x:int,y:int,width:uint,height:uint,tileGraphic:Class,empties:uint=0,health:uint=20) {			
			super(x, y, width, height);
			this.loadGraphic(tileGraphic, empties);
			this.health = health;
			tileType = String(tileGraphic);
		}	
		
		override public function hurt(Damage:Number):void {
			if ((health -= Damage) <= 0) {
				kill();
				_gibs = new FlxEmitter(x+width/2,y+height/2);
				_gibs.setYSpeed(-2,-1);
				_gibs.setXSpeed(-10,10);
				_gibs.setRotation(-360,360);
				_gibs.gravity = 100;
				_gibs.createSprites(ImgMtnGibs,3,16);
				FlxG.state.add(_gibs);
				_gibs.start(true);
			}
		}
		
		public function dropletHit(droplet:Droplet):void {
			waterAmount++;
			
			//if water is > 10 soak neighbor dirt ++ && turn droplet to pool above dirt
			if (waterAmount > 10) {
				waterAmount = 10;
				
				droplet.createPool();
			}
		}
	}
}