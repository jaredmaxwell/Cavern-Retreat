package {
	import com.adamatomic.flixel.FlxGame;
	import com.max.caverns.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class Caverns extends FlxGame
	{
		public function Caverns():void
		{
			super(320,240,Ninjarift,2,0xff000000,true,0xff937011);
			help("Jump", "Swing", "Nothing");
		}
	}
}
