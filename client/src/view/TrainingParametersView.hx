package view;

import model.TeacherState;
import messages.TagMessage;
import messages.LearnerMessage;
import js.Browser;
import js.html.InputElement;
import react.ReactComponent;
import react.ReactMacro.jsx;
import view.CheckboxesView;
import utils.Select;

typedef TrainingParametersProps = {
    tags: Array<TagMessage>,
    onTagsChanged: Array<Float> -> Void,
    ?onChanged: Int -> ?Int -> ?Int -> Void,
    learners: Array<LearnerMessage>,
    onLearnersChanged: Array<Float> -> Void,
    blockMode: Float
}

typedef TrainingParametersRefs = {
    ?minLevel: InputElement,
    ?maxLevel: InputElement,
    tasksCount: InputElement,
    tagsSelect: Dynamic,
    learnersSelect: Dynamic
}

typedef TrainingParametersState = {
    ?minLevel: Int,
    ?maxLevel: Int,
    tasksCount: Int
}

class TrainingParametersView extends ReactComponentOfPropsAndRefs<TrainingParametersProps, TrainingParametersRefs> {

    public function new()
    {
        super();
    }

    function getTagsForSelect() {
        var tags = Lambda.array(Lambda.map(props.tags, function(t) { return { value: t.id, label: if (null != t.russianName) t.russianName else t.name }; }));
        tags.sort(function(x, y) { return if (x.label < y.label) -1 else 1; });
        return tags;
    }
    function getLearnersForSelect(){
        var learners = [];
        if (props.learners != null)
            learners = Lambda.array(Lambda.map(props.learners, function(t){ return { value: t.id, label: t.firstName+" "+t.lastName}; }));
        learners.sort(function(x, y) { return if (x.label < y.label) -1 else 1; });
        return learners;
    }

    override function render() {
        var tags = getTagsForSelect();
        var learners = getLearnersForSelect();
        return
            if (props.blockMode == 1)
                jsx('
                <div id="params" className="uk-margin">
                    <h2>Параметры тренировки</h2>
                    <div className="uk-margin uk-width-1-2">
                        <label>Минимальный уровень: ${state.minLevel}</label>
                        <input className="uk-range uk-margin" type="range" min="1" max="5" step="1" value=${state.minLevel} onChange=$onChange ref="minLevel"/>
                    </div>
                    <div className="uk-margin uk-width-1-2">
                        <label>Максимальный уровень: ${state.maxLevel}</label>
                        <input className="uk-range uk-margin" type="range" min="1" max="5" step="1" value=${state.maxLevel} onChange=$onChange ref="maxLevel"/>
                    </div>
                    <div className="uk-margin uk-width-1-2">
                        <label>Количество задач: ${state.tasksCount}</label>
                        <input className="uk-range uk-margin" type="range" min="1" max="20" step="1" value=${state.tasksCount} onChange=$onChange ref="tasksCount"/>
                    </div>
                    <div className="uk-margin">
                        <h3>Категории задач</h3>
                        <div className="uk-margin">
                            <button className="uk-button uk-button-default uk-button-small  uk-margin-small-right" onClick=$selectAllTags>Выбрать все</button>
                            <button className="uk-button uk-button-default uk-button-small" onClick=$deselectAllTags>Исключить все</button>
                        </div>
                        <Select
                            isMulti=${true}
                            isLoading=${tags == null || tags.length <= 0}
                            options=$tags
                            onChange=$onSelectedTagsChanged
                            placeholder="Выберите категории..."
                            ref="tagsSelect"/>
                        <h3>Ученики</h3>
                        <div className="uk-margin">
                            <button className="uk-button uk-button-default uk-button-small  uk-margin-small-right" onClick=$selectAllLearners>Выбрать все</button>
                            <button className="uk-button uk-button-default uk-button-small" onClick=$deselectAllLearners>Исключить все</button>
                        </div>
                        <Select
                            isMulti=${true}
                            isLoading=${learners == null || learners.length <= 0}
                            options=$learners
                            onChange=$onSelectedLearnersChanged
                            placeholder="Выберите учеников..."
                            ref="learnersSelect"/>
                    </div>
                </div>
            '); else if (props.blockMode == 2) jsx ('
                <div id="params2" className="uk-margin">
                    <h2>Параметры тренировки</h2>
                    <div className="uk-margin uk-width-1-2@s">
                        <label>Количество задач: ${state.tasksCount}</label>
                        <input className="uk-range uk-margin" type="range" min="1" max="20" step="1" value=${state.tasksCount} onChange=$onChange ref="tasksCount"/>
                    </div>
                    <h3>Ученики</h3>
                    <div className="uk-margin">
                        <button className="uk-button uk-button-default uk-button-small  uk-margin-small-right" onClick=$selectAllLearners>Выбрать все</button>
                        <button className="uk-button uk-button-default uk-button-small" onClick=$deselectAllLearners>Исключить все</button>
                    </div>
                    <Select
                        isMulti=${true}
                        isLoading=${learners == null || learners.length <= 0}
                        options=$learners
                        onChange=$onSelectedLearnersChanged
                        placeholder="Выберите учеников..."
                        ref="learnersSelect"/>
                </div>'); else jsx('<div></div>');
    }

    override function componentWillMount() {
        setState({
            minLevel: 1,
            maxLevel: 5,
            tasksCount: 5
        }, onInputsChanged);
    }

    function onChange(e) {
        if (props.blockMode != 2) {
            var minLevel = Math.min(Std.parseInt(refs.minLevel.value), state.maxLevel);
            var maxLevel = Math.max(Std.parseInt(refs.maxLevel.value), state.minLevel);
            setState({
                minLevel: minLevel,
                maxLevel: maxLevel,
                tasksCount: Std.parseInt(refs.tasksCount.value)
            }, onInputsChanged);
        } else {
            setState({
                minLevel: null,
                maxLevel: null,
                tasksCount: Std.parseInt(refs.tasksCount.value)
            }, onInputsChanged);
        }
    }

    function onInputsChanged() {
        if (props.blockMode != 2) {
            props.onChanged(state.minLevel, state.maxLevel, state.tasksCount);
        } else {
            props.onChanged(state.tasksCount);
        }

    }

    function onSelectedTagsChanged(tags) {

        props.onTagsChanged(if (tags != null) Lambda.array(Lambda.map(tags, function(t) { return Std.parseFloat(t.value); })) else []);
        trace(tags);
    }

    function selectAllTags() {
        trace(refs.tagsSelect);
        refs.tagsSelect.setState(
            react.ReactUtil.copy(refs.tagsSelect.state, { value: getTagsForSelect() }),
            function() { onSelectedTagsChanged(refs.tagsSelect.state.value); });
    }

    function deselectAllTags() {
        refs.tagsSelect.setState(
            react.ReactUtil.copy(refs.tagsSelect.state, { value: null }),
            function() { onSelectedTagsChanged(refs.tagsSelect.state.value); });
    }

    function onSelectedLearnersChanged(learners) {
        props.onLearnersChanged(if (learners != null) Lambda.array(Lambda.map(learners, function(t) { return t.value; })) else []);
        trace(learners);
    }

    function selectAllLearners() {
        trace(refs.learnersSelect);
        refs.learnersSelect.setState(
            react.ReactUtil.copy(refs.learnersSelect.state, { value: getLearnersForSelect() }),
            function() { onSelectedLearnersChanged(refs.learnersSelect.state.value); });
    }

    function deselectAllLearners() {
        refs.learnersSelect.setState(
            react.ReactUtil.copy(refs.learnersSelect.state, { value: null }),
            function() { onSelectedLearnersChanged(refs.learnersSelect.state.value); });
    }
}
