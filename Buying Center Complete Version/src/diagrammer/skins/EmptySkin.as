package diagrammer.skins
{	
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;
	
	public class EmptySkin extends ProgrammaticSkin
	{
		public function EmptySkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			var g:Graphics = graphics;
			g.clear();
			
		}
		
	}
}