package diagrammer {
	
	import com.anotherflexdev.diagrammer.Link;
	
	import flash.events.MouseEvent;

	public class CustomLink extends Link {
		
		
		public function CustomLink(){
			super();
		}

		override protected function createLinkContextPanel():void {
			this.linkContextPanel = new LinkContextPanel;
			this.linkContextPanel.addEventListener("removeLink", handleRemoveLink);
			this.linkContextPanel.addEventListener("labelLink", handleLabelLink);				
		}
		
		override protected function handleClick(event:MouseEvent):void {
			LinkContextPanel(this.linkContextPanel).dataProvider = WorkflowBaseNode(this.toNode).linkDataProvider;
			super.handleClick(event);
		}
		
		override protected function performArrowDrawing(x1:Number, y1:Number, x2:Number, y2:Number, lineThickness:Number, color:Number, alpha:Number):void {
			this.graphics.lineStyle(lineThickness, color, alpha);
			graphics.beginFill(color, alpha);
			graphics.drawRect(x2-5, y2-5, 10, 10);
			graphics.endFill();
		}
				
	}
}