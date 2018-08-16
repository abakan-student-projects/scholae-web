package view.teacher;

import action.TeacherAction;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;

typedef LoadingProps = {
    description: String
}

class LoadingView extends ReactComponentOfProps<LoadingProps> {

    public function new() { super(); }

    override function render() {
        var text = if (null != props.description) '${props.description} загружается...' else 'Загрузка...';
        return jsx('
                <div className="uk-flex uk-flex-middle uk-flex-center">
                    <div><span className="uk-margin-small-right" data-uk-spinner=""></span> $text</div>
                </div>
            ');
    }
}
