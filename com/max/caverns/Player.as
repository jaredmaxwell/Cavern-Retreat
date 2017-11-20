package com.max.caverns {
	import com.max.caverns.state.PlayStateScroll;
	
	import org.flixel.*;

	public class Player extends FlxSprite {
		
		[Embed(source="../../../data/miner.png")] private var ImgMiner:Class;
		[Embed(source="../../../data/jump.mp3")] private var SndJump:Class;
		[Embed(source="../../../data/death.mp3")] private var SndDeath:Class;
		
		private var _jumpPower:int;
		private var _pickAxe:PickAxe;
		private var _up:Boolean;
		private var _down:Boolean;
		
		private var _axeCounter:Number;
		private var _drowningTimer:Number;
		private var _drownRegen:Number;
		private var _drownText:OutlineText;
		private var _usedDoubleJump:Boolean;
		private var _isHovering:Boolean;
		
		public function Player(X:int,Y:int, pickAxe:PickAxe) {
			
			super(X,Y);
			this.loadGraphic(ImgMiner, true, true);
			
			_axeCounter = 0;
			_drowningTimer = -1;
			_drownText = new OutlineText(0,0,40,"0");
			_drownText.visible = true;
			_drownRegen = 5;
			_usedDoubleJump = false;
			
			_drownText.addChildren();
			FlxG.state.add(_drownText);
			
			//bounding box tweaks
			width = 6;
			height = 7;
			offset.x = 1;
			offset.y = 1;
			
			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 420;
			_jumpPower = 130;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;
			
			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 0], 12);
			addAnimation("jump", [4]);
			addAnimation("idle_up", [5]);
			addAnimation("run_up", [6, 7, 8, 5], 12);
			addAnimation("jump_up", [9]);
			addAnimation("jump_down", [10]);
			
			_pickAxe = pickAxe;
			
			play('idle');
		}
		
		override public function update():void {		
			if (_drownRegen > 4) {
				_drowningTimer = -1;
				_drownText.setVisible(false);
			} else {
				_drownRegen += FlxG.elapsed;
			}
			
			if (_drownText.visible == true)	{
				_drownText.xPos = x-2;
				_drownText.yPos = y-12;
				_drownText.setText(Math.round(_drowningTimer).toString());
			}
			
			if (!visible)
				return;
			
			//MOVEMENT
			acceleration.x = 0;
			if (_axeCounter < 0) {
				if(FlxG.keys.LEFT) {
					facing = LEFT;
					acceleration.x -= drag.x;
				} else if(FlxG.keys.RIGHT) {
					facing = RIGHT;
					acceleration.x += drag.x;
				}
				
				if(FlxG.keys.justPressed("A") && (!velocity.y || (PlayStateScroll.canDoubleJump && !_usedDoubleJump) || PlayStateScroll.canHover)) {
					FlxG.play(SndJump,.3);
					if (velocity.y)	{
						_usedDoubleJump = true;
					} else {
						_usedDoubleJump = false;
					}
					
					velocity.y = -_jumpPower;
					
					if (PlayStateScroll.canHover) {
						_isHovering = true;
					}
				}
			} else {
				_axeCounter -= FlxG.elapsed;
			}
			
			if (FlxG.keys.justReleased("A")) {
				_isHovering = false;
			}
			
			if (_isHovering) {
				velocity.y = -_jumpPower;				
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
			
			if(FlxG.keys.justPressed("B")) {
				var axeXVel:int = 0;
				var axeYVel:int = 0;
				var axeX:int = x;
				var axeY:int = y;
				if(_up) {
					axeY -= _pickAxe.height - 4;
					axeYVel = -1;
					if (facing == FlxG.keys.RIGHT)
						axeXVel = 1;
					else
						axeXVel = -1;
				} else if(_down) {
					axeY += height - 4;
					axeYVel = 1;
					if (facing == FlxG.keys.RIGHT)
						axeXVel = 1;
					else
						axeXVel = -1;
				} else if(facing == RIGHT) {
					axeX += width - 4;
					axeXVel = 1;
				} else {
					axeX -= _pickAxe.width - 4;
					axeXVel = -1;
				}
				_pickAxe.swing(axeX, axeY, axeXVel, axeYVel);
				_axeCounter = .2;
			}
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void {
			if (Contact is Cloud) {
				var cloud:Cloud = Cloud(Contact);
				
				this.velocity.x = cloud.velocity.x*1.15;
				this.velocity.y = 0;
				cloud.acceleration.y = 0;
			}
		}
		
		public function isDrowning():void {
			if (_drowningTimer == -1) {
				_drowningTimer = 4;
				_drownText.setVisible(true);
			}
			
			if (_drowningTimer > 0)	{
				_drowningTimer -= FlxG.elapsed;
				_drownRegen = 0;
			} else {
				this.kill();
			}
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