package view.teacher;

import Array;
import codeforces.Codeforces;
import messages.ArrayChunk;
import messages.TaskMessage;
import js.moment.Moment;
import js.html.InputElement;
import action.TeacherAction;
import messages.TagMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import utils.DateRangePicker;
import view.CheckboxesView;

import react.ReactUtil.copy;

typedef TeacherNewAssignmentProps = {
    tags: Array<TagMessage>,
    learners: Array<LearnerMessage>,
    possibleTasks: ArrayChunk<TaskMessage>,
    create: Array<Float> -> String -> Int -> Int -> Int -> Array<Float> -> Array<Float> -> Date -> Date -> Void,
    cancel: Void -> Void,
    createAdaptive: String -> Date -> Date -> Int -> Array<Float> -> Void
}

typedef TeacherNewAssignmentRefs = {
    name: InputElement,
    filterInput: InputElement,
    adaptive: InputElement
}

typedef TeacherNewAssignmentState = {
    startDate: Moment,
    finishDate: Moment,
    focusedInput: Dynamic,
    filter: String,
    selectedMode: Float
}

class TeacherNewAssignmentView extends ReactComponentOfPropsAndRefs<TeacherNewAssignmentProps, TeacherNewAssignmentRefs> implements IConnectedComponent {

    var minLevel: Int;
    var maxLevel: Int;
    var tasksCount: Int;
    var tagIds: Array<Float>;
    var learnerIds: Array<Float>;
    var taskIds: Array<Float>;
    var checkboxData: Array<CheckboxData>;

    public function new() {
        super();
        state = {
            startDate: Moment.moment({}),
            finishDate: null,
            filter: "",
            selectedMode: 1
        };
    }

    override function render() {
        var checkboxData =
        if (props.possibleTasks != null)
            [for (t in props.possibleTasks.data) {id:Std.string(t.id),label:renderTask(t),checked:false}];
        else [];
        var possibleTasks = jsx('<CheckboxesView data=${checkboxData} onChanged=$onTrainingTasksChanged />');

        var possibleTasksTotalOrLoading =
        if (props.possibleTasks != null)
            jsx('<span>Общее количество: ${props.possibleTasks.totalLength}</span>')
        else
            jsx('<span data-uk-spinner=""/>');
        var trainParametrs: ReactElement = null;
        var selectTasks: ReactElement = jsx('<div></div>');
        if (state.selectedMode == 1) {
            trainParametrs = jsx('<div className="uk-width-expand@m">
                                    <TrainingParametersView tags=${props.tags} learners=${props.learners} onTagsChanged=$onTrainingTagsChanged onLearnersChanged=$onTrainingLearnersChanged onChanged=$onTrainingChanged blockMode=${1}/>
                                </div>');
            selectTasks = jsx('<div className="uk-width-1-3@m">
                                    <h2>Выбранные задачи</h2>
                                    <div className="uk-margin">
                                        $possibleTasksTotalOrLoading
                                    </div>
                                    <h2>Поиск задач</h2>
                                        <input type="text" placeholder="Поиск" className="uk-input uk-form-width-large uk-margin" value=${state.filter} ref="filterInput" onChange=$onFilterInputChanged />
                                    $possibleTasks
                                </div>');

        } else if (state.selectedMode == 2) {
            trainParametrs = jsx('
                                <div className="uk-width-expand@m">
                                    <TrainingParametersView tags=${props.tags} learners=${props.learners} onTagsChanged=$onTrainingTagsChanged onLearnersChanged=$onTrainingLearnersChanged onChanged=$onTaskCountChange blockMode=${2}/>
                                </div>');
        }
        return jsx('
            <div className="uk-margin uk-margin-left">
                <h1>Создание нового блока заданий</h1>
                <input type="checkbox" ref="adaptive" onChange=$changeMode/> Адаптивный режим
                <div className="uk-margin">
                    <input className="uk-input" type="text" placeholder="Название" ref="name"/>
                </div>

                <div className="uk-margin">
                    <div className="uk-margin-small">
                        <label>Сроки выполнения:</label>
                    </div>
                    <DateRangePicker
                        displayFormat="LL"
                        startDate=${state.startDate}
                        startDateId="new-assignment-startdate"
                        startDatePlaceholderText="Дата начала"
                        endDate=${state.finishDate}
                        endDateId="new-assignment-enddate"
                        endDatePlaceholderText="Дата окончания"
                        onDatesChange=${function(range) { setState(copy(state, { startDate: range.startDate, finishDate: range.endDate })); }}
                        focusedInput=${state.focusedInput}
                        onFocusChange=${function(focusedInput) { setState(copy(state, { focusedInput: focusedInput })); }}
                    />
                </div>

                <div className="uk-grid-divider" data-uk-grid=${true}>
                    $trainParametrs
                    $selectTasks
                </div>

                <p className="uk-margin uk-margin-top">
                    <button className="uk-button uk-button-primary uk-margin-right" onClick=$onCreateClicked>Создать</button>
                    <button className="uk-button uk-button-default" onClick=$onCancelClicked>Отмена</button>
                </p>
            </div>
        ');
    }

    function changeMode() {
        if (refs.adaptive.checked == true) {
            setState(copy(state, {selectedMode: 2}));
        } else {
            setState(copy(state, {selectedMode: 1}));
        }
    }

    function onFilterInputChanged(){
        setState(copy(state, { filter: refs.filterInput.value }));
        dispatch(TeacherAction.LoadPossibleTasks({
            id: null,
            minLevel: minLevel,
            maxLevel: maxLevel,
            tagIds: tagIds,
            taskIds: taskIds,
            length: tasksCount
        }, refs.filterInput.value));
    }

    function onTrainingTasksChanged(changedTaskIds: Array<String>){
        taskIds = [for (t in changedTaskIds) Std.parseFloat(t)];
    }

    function onTrainingTagsChanged(checkedTagIds: Array<Float>) {
        if (refs.adaptive.checked != true) {
            tagIds = checkedTagIds;
            dispatch(TeacherAction.LoadPossibleTasks({
                id: null,
                minLevel: minLevel,
                maxLevel: maxLevel,
                tagIds: tagIds,
                taskIds: null,
                length: tasksCount
            }, refs.filterInput.value));
        }
    }

    function onTrainingLearnersChanged(checkedLearnerIds: Array<Float>) {
        learnerIds = checkedLearnerIds;
    }

    function onTaskCountChange(tasksCount: Int) {
        this.tasksCount = tasksCount;
    }

    function onTrainingChanged(minLevel: Int, maxLevel: Int, tasksCount: Int) {
        if (refs.adaptive.checked != true) {
            this.minLevel = minLevel;
            this.maxLevel = maxLevel;
            this.tasksCount = tasksCount;
            dispatch(TeacherAction.LoadPossibleTasks({
                id: null,
                minLevel: minLevel,
                maxLevel: maxLevel,
                tagIds: tagIds,
                taskIds: taskIds,
                length: tasksCount
            }, refs.filterInput.value));
        }
    }

    function onCreateClicked() {
        var startDate: Date = Date.fromTime(state.startDate.utc());
        var finishDate: Date = Date.fromTime(state.finishDate.utc());
        if (state.selectedMode == 1) {
            props.create(learnerIds, refs.name.value, minLevel, maxLevel, tasksCount, tagIds, taskIds,
            new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), 0 , 0, 0),
            new Date(finishDate.getFullYear(), finishDate.getMonth(), finishDate.getDate(), 23 , 59, 59));
        } else {
            props.createAdaptive(refs.name.value,
            new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), 0 , 0, 0),
            new Date(finishDate.getFullYear(), finishDate.getMonth(), finishDate.getDate(), 23 , 59, 59),
            tasksCount,learnerIds);
        }
    }

    function onCancelClicked() {
        props.cancel();
    }

    function renderTask(task: TaskMessage) {

        var problemUrl =
        if (task.isGymTask)
            Codeforces.getGymProblemUrl(task.codeforcesContestId, task.codeforcesIndex)
        else
            Codeforces.getProblemUrl(task.codeforcesContestId, task.codeforcesIndex);

        var labelStyle = switch(task.level) {
            case 1: " uk-label-success";
            case 3: " uk-label-warning";
            case 4 | 5: " uk-label-danger";
            default : "";
        };

        return jsx('
                <span>
                    <a href=$problemUrl target="_blank">${task.name}</a> <span className=${"uk-label" + labelStyle}>${Std.string(task.level)}</span>
                </span>
        ');
    }
}
