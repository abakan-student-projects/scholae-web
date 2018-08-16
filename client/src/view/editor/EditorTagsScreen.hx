package view.editor;

import action.EditorAction;
import view.editor.EditorTagsView.EditorTagsProps;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.RouteComponentProps;
import utils.RemoteDataHelper;
import view.editor.EditorTagsView;

using utils.RemoteDataHelper;

class EditorTagsScreen
    extends ReactComponentOfPropsAndState<RouteComponentProps, EditorTagsProps>
    implements IConnectedComponent {

    public function new(props:RouteComponentProps) {
        super(props);
    }

    public override function render(): ReactElement {
        return jsx('<EditorTagsView {...state} dispatch=$dispatch/>');
    }

    function mapState(state: ApplicationState, props: RouteComponentProps): EditorTagsProps {
        RemoteDataHelper.ensureRemoteDataLoaded(state.editor.tags, EditorAction.LoadTags);
        return {
            tags: state.editor.tags.data,
            update: function(tag) { dispatch(EditorAction.UpdateTag(tag)); },
            insert: function(tag) { dispatch(EditorAction.InsertTag(tag)); },
            showNewTagView: state.editor.showNewTagView
        }
    }
}
