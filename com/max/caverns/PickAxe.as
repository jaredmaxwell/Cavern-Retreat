package com.max.caverns
{
	import org.flixel.*;

	public class PickAxe extends FlxSprite
	{
		[Embed(source="../../../data/pickaxe.png")] private var ImgPickAxe:Class;
		
		public function PickAxe()
		{
			super(0,0);
			this.loadGraphic(ImgPickAxe, true, true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			exists = false;
			
			addAnimation("right",[0,1,2],10,false);
			addAnimation("left",[3,4,5],10,false);
			addAnimation("rightUp",[6,7,8],10,false);
			addAnimation("leftUp",[9,10,11],10,false);
			addAnimation("leftDown",[12,13,14],10,false);
			addAnimation("rightDown",[15,16,17],10,false);
			addAnimationCallback(doneAnimating);
		}
		
		override public function update():void
		{
			if(dead && finished) exists = false;
			else super.update();
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void { hurt(0); }
		override public function hitRight(Contact:FlxObject, Velocity:Number):void { hurt(0); }
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void { hurt(0); }
		override public function hitTop(Contact:FlxObject, Velocity:Number):void { hurt(0); }
		
		override public function hurt(Damage:Number):void
		{
			if(dead) return;
			dead = true;
		}
		
		public function doneAnimating(name:String, frame:uint, frameIndex:uint):void 
		{			
			if (frame == 2)
			{
				dead = true;
			}
		}
		
		public function swing(X:int, Y:int, velX:int, velY:int):void
		{
			x = X;
			y = Y;		
			
			
			if (velY < 0)
			{
				if (velX > 0)
					play("rightUp",true);
				else
					play("leftUp",true);
			}
			else if (velY > 0)
			{
				if (velX > 0)
					play("rightDown",true);
				else
					play("leftDown",true);
			}
			else if(velX < 0)
				play("left",true);
			else if(velX > 0)
				play("right",true);
				
				
			dead = false;
			exists = true;
			visible = true;
		}
	}
}