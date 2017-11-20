package com.max.caverns {
	import org.flixel.*;
	
	public class Pool extends FlxTileblock {
		
		[Embed(source="../../../data/poolLow.png")] private var ImgPoolLow:Class;
		[Embed(source="../../../data/poolMed.png")] private var ImgPoolMed:Class;
		[Embed(source="../../../data/poolHigh.png")] private var ImgPoolHigh:Class;
		
		private var waterAmount:int;
		
		public function Pool(x:int, y:int, waterAmount:int) {			
			super(x, y, 8, 8);
			
			this.waterAmount = waterAmount;
			
			var img:Class = ImgPoolLow;
			if (waterAmount < 7) {
				img = ImgPoolMed;
			} else if (waterAmount < 10) {
				img = ImgPoolHigh;	
			}
			
			this.loadGraphic(img);
		}
		
		public function dropletHit(droplet:Droplet):void {
			waterAmount++;
			
			//if water is > 10 soak neighbor dirt ++ && turn droplet to pool above dirt/pool
			if (waterAmount > 10) {
				waterAmount = 10;
				
				droplet.createPool();
			}
		}
	}
}