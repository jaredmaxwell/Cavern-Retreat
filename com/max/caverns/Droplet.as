package com.max.caverns {
	import com.max.caverns.*;
	import com.max.caverns.state.*;
	
	import org.flixel.*;
	
	public class Droplet extends FlxSprite {
		
		[Embed(source="../../../data/droplet.png")] private var ImgDroplet:Class;
		
		public function Droplet(x:Number, y:Number) {
			
			super(x,y,ImgDroplet);
			acceleration.y = 420;
			maxVelocity.y = 130;
			
		}
		
		override public function update():void {
			super.update();
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void {
			if (Contact is CavernBlock) {
				var block:CavernBlock = CavernBlock(Contact);
				block.dropletHit(this);
				this.visible = false;
				this.exists = false;
			} else if (Contact is Pool) {
				var pool:Pool = Pool(Contact);
				pool.dropletHit(this);
				this.visible = false;
				this.exists = false;
			}
		}
		
		public function createPool():void {
			var x:int = this.x - this.x%8;
			var y:int = this.y - this.y%8;
			trace(x + ' ' + y);
			
			PlayStateScroll(FlxG.state).addPool(new Pool(x, y, 1));
		}
	}
}