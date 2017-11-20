package com.max.caverns {
	import com.max.caverns.state.PlayStateScroll;
	
	import org.flixel.*;

	public class Player extends FlxSprite {
		
		[Embed(source="../../../data/miner.png")] private var ImgMiner:Class;
		[Embed(source="../../../data/jump.mp3")] private var SndJump:Class;
		[Embed(source="../../../data/death.mp3")] private var SndDeath:Class;
		
		private var _up:Boolean;
		private var _down:Boolean;
		
		public function Player(X:int,Y:int) {
			
			super(X,Y);
			this.loadGraphic(ImgMiner, true, true);
			
			//bounding box tweaks
			width = 6;
			height = 7;
			offset.x = 1;
			offset.y = 1;
			
			//basic player physics
			var runSpeed:uint = 80;
			drag.x = drag.y = runSpeed*8;
			maxVelocity.x = maxVelocity.y = runSpeed;
			
			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 0], 12);
			addAnimation("jump", [4]);
			addAnimation("idle_up", [5]);
			addAnimation("run_up", [6, 7, 8, 5], 12);
			addAnimation("jump_up", [9]);
			addAnimation("jump_down", [10]);
			
			play('idle');
		}
		
		override public function update():void {
			
			if (!visible)
				return;
			
			//MOVEMENT
			acceleration.x = 0;
			
			if (FlxG.mouse.pressed()) {
				// get relative mouse location
				var dx:Number = FlxG.mouse.x - this.x;
				var dy:Number = FlxG.mouse.y - this.y;
				
				// determine realAngle, convert to degrees
				var aRadians:Number = Math.atan2(dy,dx);
				var aDegrees:Number = 360*(aRadians/(2*Math.PI));
				
				// To update the X/Y
				velocity.x += Math.cos(aRadians) * 80;
				velocity.y += Math.sin(aRadians) * 80;
			}
			
			//AIMING
			_up = false;
			_down = false;
			if(FlxG.keys.UP) _up = true;
			else if(FlxG.keys.DOWN) _down = true;
			
			//ANIMATION
			if(velocity.y != 0) {
				if(_up) play("jump_up");
				else if(_down) play("jump_down");
				else play("jump");
			} else if(velocity.x == 0) {
				if(_up) play("idle_up");
				else play("idle");
			} else {
				if(_up) play("run_up");
				else play("run");
			}
				
			//UPDATE POSITION AND ANIMATION
			super.update();
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void {
			
		}
		
		override public function kill():void {
			if (visible) {
				FlxG.play(SndDeath);
				visible = false;
				FlxG.quake.start(0.005,0.35);
				FlxG.flash.start(0xffd8eba2, 0.35);
			}
		}
	}
}