package view.teacher;

import model.TeacherState;
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

import react.ReactUtil.copy;

typedef TeacherNewAssignmentProps = {
    tags: Array<TagMessage>,
    learners: Array<LearnerMessage>,
    possibleTasks: ArrayChunk<TaskMessage>,
    create: Array<Float> -> String -> Int -> Int -> Int -> Array<Float> -> Date -> Date -> Void,
    cancel: Void -> Void
}

typedef TeacherNewAssignmentRefs = {
    name: InputElement
}

typedef TeacherNewAssignmentState = {
    startDate: Moment,
    finishDate: Moment,
    focusedInput: Dynamic
}

class TeacherNewAssignmentView extends ReactComponentOfPropsAndRefs<TeacherNewAssignmentProps, TeacherNewAssignmentRefs> implements IConnectedComponent {

    var minLevel: Int;
    var maxLevel: Int;
    var tasksCount: Int;
    var tagIds: Array<Float>;
    var learnerIds: Array<Float>;

    public function new() {
        super();
        state = {
            startDate: Moment.moment({}),
            finishDate: null
        };
    }

    override function render() {
        var possibleTasks =
            if (props.possibleTasks != null)
                [for (t in props.possibleTasks.data) renderTask(t)]
            else [];

        var possibleTasksTotalOrLoading =
            if (props.possibleTasks != null)
                jsx('<span>Общее количество: ${props.possibleTasks.totalLength}</span>')
            else
                jsx('<span data-uk-spinner=""/>');

        return jsx('
            <div className="uk-margin uk-margin-left">
                <h1>Создание нового блока заданий</h1>
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
                        endDateId="EmailActivationScreen-assignment-enddate"
                        endDatePlaceholderText="Дата окончания"
                        onDatesChange=${function(range) { setState(copy(state, { startDate: range.startDate, finishDate: range.endDate })); }}
                        focusedInput=${state.focusedInput}
                        onFocusChange=${function(focusedInput) { setState(copy(state, { focusedInput: focusedInput })); }}
                    />
                </div>

                <div className="uk-grid-divider" data-uk-grid=${true}>
                    <div className="uk-width-expand@m">
                        <TrainingParametersView tags=${props.tags} learners=${props.learners} onTagsChanged=$onTrainingTagsChanged onLearnersChanged=$onTrainingLearnersChanged onChanged=$onTrainingChanged/>
                    </div>
                    <div className="uk-width-1-3@m">
                        <h2>Выбранные задачи</h2>
                        <div className="uk-margin">
                            $possibleTasksTotalOrLoading
                        </div>
                        $possibleTasks
                    </div>
                </div>

                <p className="uk-margin uk-margin-top">
                    <button className="uk-button uk-button-primary uk-margin-right" onClick=$onCreateClicked>Создать</button>
                    <button className="uk-button uk-button-default" onClick=$onCancelClicked>Отмена</button>
                </p>
            </div>
        ');
    }

    function onTrainingTagsChanged(checkedTagIds: Array<Float>) {
        tagIds = checkedTagIds;
        dispatch(TeacherAction.LoadPossibleTasks({
            id: null,
            minLevel: minLevel,
            maxLevel: maxLevel,
            tagIds: tagIds,
            length: tasksCount
        }));
    }

    function onTrainingLearnersChanged(checkedLearnerIds: Array<Float>) {
        learnerIds = checkedLearnerIds;
    }

    function onTrainingChanged(minLevel: Int, maxLevel: Int, tasksCount: Int) {
        this.minLevel = minLevel;
        this.maxLevel = maxLevel;
        this.tasksCount = tasksCount;
        dispatch(TeacherAction.LoadPossibleTasks({
            id: null,
            minLevel: minLevel,
            maxLevel: maxLevel,
            tagIds: tagIds,
            length: tasksCount
        }));
    }

    function onCreateClicked() {
        var startDate: Date = Date.fromTime(state.startDate.utc());
        var finishDate: Date = Date.fromTime(state.finishDate.utc());
        props.create(learnerIds, refs.name.value, minLevel, maxLevel, tasksCount, tagIds,
                new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), 0 , 0, 0),
                new Date(finishDate.getFullYear(), finishDate.getMonth(), finishDate.getDate(), 23 , 59, 59));
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
            <div key=${Std.string(task.id)} className="uk-margin-small">
                <div>
                    <a href=$problemUrl target="_blank">${task.name}</a> <span className=${"uk-label" + labelStyle}>${Std.string(task.level)}</span>
                </div>
            </div>
        ');
    }
}
