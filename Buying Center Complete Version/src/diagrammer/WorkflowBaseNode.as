package diagrammer {
	import com.anotherflexdev.diagrammer.BaseNode;
	
	import mx.collections.ArrayCollection;

	public class WorkflowBaseNode extends BaseNode {
		
		[Bindable] public var linkDataProvider:ArrayCollection;
		
		public function WorkflowBaseNode() {
			super();
		}
		
	}
}