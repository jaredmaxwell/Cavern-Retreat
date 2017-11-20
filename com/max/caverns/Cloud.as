package com.max.caverns {
	import org.flixel.*;

	public class Cloud extends FlxSprite {
		
		[Embed(source="../../../data/cloud.png")] private var ImgCloud:Class;
		[Embed(source="../../../data/bigCloud.png")] private var ImgBigCloud:Class;
		
		protected var playerRef:Player;
		public var condensation:Number;
		public var droplets:FlxGroup;
		
		public function Cloud(player:Player) {
			playerRef = player;
			
			var img:Class = ImgCloud;
			if (Math.random() > .5) {
				this.condensation = Math.random()*90+10;
				img = ImgBigCloud;
			}
			
			super(player.x+180+ Math.random()*400,-Math.random()*150+1,img);
			
			droplets = new FlxGroup();
			
			this.velocity.x = -Math.random()*100+10;
			this.drag = new FlxPoint(0, 600);
			this.collideBottom = false;
		}
		
		override public function update():void {
			super.update();
			
			if (x - playerRef.x < -320) {
				x = playerRef.x+320 + Math.random()*100;
				y = -Math.random()*150+1;
				
				
				if (Math.random() > .5) {
					this.condensation = Math.random()*90+10;
				}
			}
			
			if (condensation > 20) {
				rain();
			}
		}
		
		public function rain():void {
			if (this.onScreen()) {
				condensation--;
				
				droplets.add(FlxG.state.add(new Droplet(x+Math.random()*this.width,y+this.height)));
			}
		}
	}
}