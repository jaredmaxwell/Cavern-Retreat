package com.max.caverns
{
	import com.adamatomic.flixel.FlxButton;
	import com.adamatomic.flixel.FlxG;
	import com.adamatomic.flixel.FlxSprite;
	import com.adamatomic.flixel.FlxState;
	import com.adamatomic.flixel.FlxText;
	
	public class UpgradeState extends FlxState
	{
		[Embed(source="../../../data/cursor.png")] private var ImgCursor:Class;
		[Embed(source="../../../data/backgroundcavernblock.png")] private var ImgBackground:Class;

		private var _scoreText:FlxText;
		
		private var _darkest:uint = 0xff000000;
		private var _dark:uint = 0xff222222;
		private var _light:uint = 0xffcccccc;
		private var _lightest:uint = 0xffffffff;
		
		private var _lanternCostText:FlxText;
		private var _pickaxeCostText:FlxText;
		private var _doubleJumpCostText:FlxText;
		private var _hoverCostText:FlxText;
		
		override public function UpgradeState() 
		{
			trace(FlxG.scores[2]);
			trace(FlxG.score);
			trace(FlxG.scores[1]);
			FlxG.scores[1] = FlxG.score - FlxG.scores[2];
			
			this.add(new CavernBlock(0,0,320,240,ImgBackground));
			FlxG.setCursor(ImgCursor);
			
			this.add(new FlxText(0,0, 200, 50, "Upgrades", _lightest, null, 24, "center"));
			
			_scoreText = this.add(new FlxText(0, 40, 320, 50, "TOTAL SCORE: " + FlxG.score + "  AVAILABLE GOLD: " + FlxG.scores[1], _lightest, null, 8)) as FlxText;
				
			//Bullet speed button
			this.add(new FlxSprite(null,30,70,false,false,106,19,_darkest));//border
			this.add(new FlxButton(31,71,new FlxSprite(null,0,0,false,false,104,15,_dark),onBulletSpeed,new FlxSprite(null,0,0,false,false,104,15,_light),new FlxText(4,1,100,10,"Lantern Size",_light),new FlxText(4,1,100,10,"Lantern Size",_darkest)));
			_lanternCostText = this.add(new FlxText(0,71,30,20,"200",_lightest)) as FlxText;
			
			updateBulletSpeedBar();
			
			//Jump power button
			this.add(new FlxSprite(null,30,90,false,false,106,19,_darkest));//border
			this.add(new FlxButton(31, 91, new FlxSprite(null, 0, 0, false, false, 104, 15, _dark), onJumpPower, new FlxSprite(null, 0, 0, false, false, 104, 15, _light), new FlxText(4, 1, 100, 10, "Pickaxe Power", _light), new FlxText(4, 1, 100, 10, "Pickaxe Power", _darkest)));
			_pickaxeCostText = this.add(new FlxText(0,91,30,20,"200",_lightest)) as FlxText;
			
			updateJumpPowerBar();
			
			//Charge Speed button
			this.add(new FlxSprite(null,30,110,false,false,106,19,_darkest));//border
			this.add(new FlxButton(31, 111, new FlxSprite(null, 0, 0, false, false, 104, 15, _dark), onChargeSpeed, new FlxSprite(null, 0, 0, false, false, 104, 15, _light), new FlxText(4, 1, 100, 10, "Double Jump", _light), new FlxText(4, 1, 100, 10, "Double Jump", _darkest)));
			_doubleJumpCostText = this.add(new FlxText(0,111,30,20,"100",_lightest)) as FlxText;
			
			updateChargeSpeedBar();
			
			//Charge Speed button
			this.add(new FlxSprite(null,30,130,false,false,106,19,_darkest));//border
			this.add(new FlxButton(31, 131, new FlxSprite(null, 0, 0, false, false, 104, 15, _dark), onHoverPack, new FlxSprite(null, 0, 0, false, false, 104, 15, _light), new FlxText(4, 1, 100, 10, "Hover Pack", _light), new FlxText(4, 1, 100, 10, "Hover Pack", _darkest)));
			_hoverCostText = this.add(new FlxText(0,131,30,20,"400",_lightest)) as FlxText;
			
			updateHoverPackBar();
			
			//Continue button
			this.add(new FlxSprite(null,FlxG.width-120,FlxG.height-20,false,false,106,19,_darkest));//border
			this.add(new FlxButton(FlxG.width-119,FlxG.height-19,new FlxSprite(null,0,0,false,false,104,15,_dark),onContinue,new FlxSprite(null,0,0,false,false,104,15,_light),new FlxText(15,1,100,10,"Continue",_light),new FlxText(15,1,100,10,"Continue",_lightest)));
		}
		
		override public function update():void 
		{
			super.update();
		}
		
		private function onBulletSpeed():void 
		{
			if (PlayState.shadowSize < 2 && FlxG.scores[1] - (PlayState.shadowSize+1)*200 >= 0)
			{
				FlxG.scores[1] -= (PlayState.shadowSize+1)*200;
				FlxG.scores[2] += (PlayState.shadowSize+1)*200;
				
				PlayState.shadowSize++;	
				
				updateBulletSpeedBar();
				_scoreText.setText("TOTAL SCORE: " + FlxG.score + "  AVAILABLE GOLD: " + FlxG.scores[1]);
			}
			else
			{
				//Can't do that you have maxed out!
			}
		}
		
		private function onJumpPower():void 
		{
			if (PlayState.pickAxeLvl < 2 && FlxG.scores[1] - (PlayState.pickAxeLvl+1)*200 >= 0)
			{
				FlxG.scores[1] -= (PlayState.pickAxeLvl+1)*200;
				FlxG.scores[2] += (PlayState.pickAxeLvl+1)*200;
				
				PlayState.pickAxeLvl++;
				
				updateJumpPowerBar();
				_scoreText.setText("TOTAL SCORE: " + FlxG.score + "  AVAILABLE GOLD: " + FlxG.scores[1]);
			}
		}
		
		private function onChargeSpeed():void 
		{
			if (!PlayState.canDoubleJump && FlxG.scores[1] - 100 >= 0)
			{
				FlxG.scores[1] -= 100;
				FlxG.scores[2] += 100;
				
				PlayState.canDoubleJump = true;				
				
				updateChargeSpeedBar();
				_scoreText.setText("TOTAL SCORE: " + FlxG.score + "  AVAILABLE GOLD: " + FlxG.scores[1]);
			}
		}
		
		private function onHoverPack():void 
		{
			if (!PlayState.canHover && FlxG.scores[1] - 400 >= 0)
			{
				FlxG.scores[1] -= 400;
				FlxG.scores[2] += 400;
				
				PlayState.canHover = true;				
				
				updateHoverPackBar();
				_scoreText.setText("TOTAL SCORE: " + FlxG.score + "  AVAILABLE GOLD: " + FlxG.scores[1]);
			}
		}
		
		private function onContinue():void 
		{
			FlxG.fade(0xff000000,1,onFade);
		}
		
		private function onFade():void 
		{
			FlxG.switchState(PlayState);
		}
		
		private function updateBulletSpeedBar():void 
		{
			var maxed:Boolean = false;
			
			//Stat progression bar
			this.add(new FlxSprite(null, 140, 70, false, false, 15, 19, _darkest));
			if (PlayState.shadowSize+1 == 1)
				this.add(new FlxSprite(null, 141, 71, false, false, 13, 15, _light));
			else
				this.add(new FlxSprite(null, 141, 71, false, false, 13, 15, _dark));
				
			this.add(new FlxSprite(null, 160, 70, false, false, 15, 19, _darkest));
			if (PlayState.shadowSize+1 == 2)
				this.add(new FlxSprite(null, 161, 71, false, false, 13, 15, _light));
			else
				this.add(new FlxSprite(null, 161, 71, false, false, 13, 15, _dark));
				
			this.add(new FlxSprite(null, 180, 70, false, false, 15, 19, _darkest));
			if (PlayState.shadowSize+1 == 3)
			{
				this.add(new FlxSprite(null, 181, 71, false, false, 13, 15, _light));
				_lanternCostText.setText("MAX");
				maxed = true;
			}
			else
				this.add(new FlxSprite(null, 181, 71, false, false, 13, 15, _dark));
				
			if (!maxed)
				_lanternCostText.setText(String((PlayState.shadowSize+1)*200));
		}
		
		private function updateJumpPowerBar():void 
		{
			var maxed:Boolean = false;
			
			//Stat progression bar
			this.add(new FlxSprite(null, 140, 90, false, false, 15, 19, _darkest));
			if (PlayState.pickAxeLvl+1 == 1)
				this.add(new FlxSprite(null, 141, 91, false, false, 13, 15, _light));
			else
				this.add(new FlxSprite(null, 141, 91, false, false, 13, 15, _dark));
				
			this.add(new FlxSprite(null, 160, 90, false, false, 15, 19, _darkest));
			if (PlayState.pickAxeLvl+1 == 2)
				this.add(new FlxSprite(null, 161, 91, false, false, 13, 15, _light));
			else
				this.add(new FlxSprite(null, 161, 91, false, false, 13, 15, _dark));
				
			this.add(new FlxSprite(null, 180, 90, false, false, 15, 19, _darkest));
			if (PlayState.pickAxeLvl+1 == 3)
			{
				this.add(new FlxSprite(null, 181, 91, false, false, 13, 15, _light));
				_pickaxeCostText.setText("MAX");
				maxed = true;
			}
			else
				this.add(new FlxSprite(null, 181, 91, false, false, 13, 15, _dark));
				
			if (!maxed)
				_pickaxeCostText.setText(String((PlayState.pickAxeLvl+1)*200));
		}
		
		private function updateChargeSpeedBar():void 
		{
			//Stat progression bar
			this.add(new FlxSprite(null, 140, 110, false, false, 15, 19, _darkest));
			if (PlayState.canDoubleJump)
			{
				this.add(new FlxSprite(null, 141, 111, false, false, 13, 15, _light));
				_doubleJumpCostText.setText("MAX");
			}
			else
				this.add(new FlxSprite(null, 141, 111, false, false, 13, 15, _dark));
		}
		
		private function updateHoverPackBar():void 
		{
			//Stat progression bar
			this.add(new FlxSprite(null, 140, 130, false, false, 15, 19, _darkest));
			if (PlayState.canHover)
			{
				this.add(new FlxSprite(null, 141, 131, false, false, 13, 15, _light));
				_hoverCostText.setText("MAX");
			}
			else
				this.add(new FlxSprite(null, 141, 131, false, false, 13, 15, _dark));
		}
	}
	
}