package view;

import messages.TagMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import view.CheckboxesView;

typedef TrainingParametersProps = {
    tags: Array<TagMessage>,
    onTagsChanged: Array<Float> -> Void,
    onChanged: Int -> Int -> Int -> Void,
}

typedef TrainingParametersRefs = {
    minLevel: InputElement,
    maxLevel: InputElement,
    tasksCount: InputElement
}

typedef TrainingParametersState = {
    minLevel: Int,
    maxLevel: Int,
    tasksCount: Int
}

class TrainingParametersView extends ReactComponentOfPropsAndRefs<TrainingParametersProps, TrainingParametersRefs> {

    public function new()
    {
        super();
    }

    override function render() {
        var checkboxesData = Lambda.array(Lambda.map(props.tags, function(t) { return { id: t.id, label: t.name }; }));
        return
            jsx('
                <div id="params">
                <h2>Параметры тренировки</h2>
                <div className="uk-margin uk-width-1-4@s">
                    <label>Минимальный уровень: ${state.minLevel}</label>
                    <input className="uk-range uk-margin" type="range" min="1" max="5" step="1" value=${state.minLevel} onChange=$onChange ref="minLevel"/>
                </div>
                <div className="uk-margin uk-width-1-4@s">
                    <label>Максимальный уровень: ${state.maxLevel}</label>
                    <input className="uk-range uk-margin" type="range" min="1" max="5" step="1" value=${state.maxLevel} onChange=$onChange ref="maxLevel"/>
                </div>
                <div className="uk-margin uk-width-1-4@s">
                    <label>Количество задач: ${state.tasksCount}</label>
                    <input className="uk-range uk-margin" type="range" min="1" max="20" step="1" value=${state.tasksCount} onChange=$onChange ref="tasksCount"/>
                </div>
                <div className="uk-margin">
                    <h3>Категории задач</h3>
                    <CheckboxesView data=$checkboxesData onChanged=$onSelectedTagsChanged/>
                </div>
                </div>
            ');
    }

    override function componentWillMount() {
        setState({
            minLevel: 1,
            maxLevel: 5,
            tasksCount: 5
        }, onInputsChanged);
    }

    function onChange(e) {
        var minLevel = Math.min(Std.parseInt(refs.minLevel.value), state.maxLevel);
        var maxLevel = Math.max(Std.parseInt(refs.maxLevel.value), state.minLevel);
        setState({
            minLevel: minLevel,
            maxLevel: maxLevel,
            tasksCount: Std.parseInt(refs.tasksCount.value)
        }, onInputsChanged);
    }

    function onSelectedTagsChanged(tagIds: Array<String>) {
        props.onTagsChanged(Lambda.array(Lambda.map(tagIds, function(id) { return Std.parseFloat(id); })));
    }

    function onInputsChanged() {
        props.onChanged(state.minLevel, state.maxLevel, state.tasksCount);
    }
}
