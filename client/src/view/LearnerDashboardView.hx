package view;

import utils.DateUtils;
import utils.StringUtils;
import haxe.ds.StringMap;
import messages.TagMessage;
import codeforces.Codeforces;
import messages.ExerciseMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import js.Browser;
import view.teacher.LoadingView;
import router.Link;

typedef LearnerDashboardViewProps = {
    trainings: Array<TrainingMessage>,
    tags: StringMap<TagMessage>,
    resultsRefreshing: Bool,
    refreshResults: Void -> Void
}

class LearnerDashboardView extends ReactComponentOfProps<LearnerDashboardViewProps> {

    public function new() {
        super();
    }

    override function render() {
        var refreshResultsButton =
            if (props.resultsRefreshing) jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" disabled="true">Обновить результаты</button>')
            else jsx('<button className="uk-button uk-button-default uk-margin uk-width-1-1" onClick=${props.refreshResults}>Обновить результаты</button>');

        if (null != props.trainings && null != props.tags) {
            var trainings = [ for (t in props.trainings) renderTraining(t)];
            return jsx('
                <div id="teacher-group">
                    <div className="uk-flex uk-flex-middle uk-margin">
                        <h2 className="uk-margin-remove">Список заданий</h2>
                        <button className="uk-icon-button uk-button-default uk-margin-left" type="button" data-uk-icon="more"></button>
                        <div data-uk-dropdown="pos: bottom-left">
                            <ul className="uk-nav uk-dropdown-nav">
                                <li>
                                    <Link className="uk-button uk-button-default uk-margin uk-width-1-1" to="/learner/signup">Записаться на новый курс</Link>
                                </li>
                                <li>
                                    $refreshResultsButton
                                </li>
                            </ul>
                        </div>
                    </div>
                    <ul data-uk-accordion=${true} className="trainings">$trainings</ul>
                </div>
            ');
        } else {
            return jsx('<LoadingView description="Тренировки"/>');
        }
    }

    function renderTraining(t: TrainingMessage) {
        var exercises = [ for (e in t.exercises) renderExercise(e)];
        return jsx('
                <li key=${t.id} className="traning">
                    <a className="uk-accordion-title" href="#">
                        <span className="uk-margin-right">${t.name}</span>
                        <span className="uk-label uk-margin-right">
                            ${t.assignment.metaTraining.length} ${StringUtils.getTaskStringFor(t.assignment.metaTraining.length)}
                        </span>
                        ${DateUtils.toString(t.assignment.startDate)} - ${DateUtils.toString(t.assignment.finishDate)}
                    </a>
                    <div className="uk-accordion-content">
                            $exercises
                    </div>
                </li>
            ');
    }

    function renderExercise(exercise: ExerciseMessage) {

        var tags = [];
        for (tag in exercise.task.tagIds) {
            var key = Std.string(tag);
            var t = props.tags.get(key);
            if (t != null) {
                tags.push(jsx('<span key=$key className="uk-margin-small-bottom uk-margin-small-right">${t.name}</span> '));
            }
        }
        var problemUrl =
        if (exercise.task.isGymTask)
            Codeforces.getGymProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex)
        else
            Codeforces.getProblemUrl(exercise.task.codeforcesContestId, exercise.task.codeforcesIndex);

        var solvedMark = if (exercise.task.isSolved) jsx('<span className="uk-margin-left" data-uk-icon="check"></span>') else jsx('<span></span>');

        var labelStyle = switch(exercise.task.level) {
            case 1: " uk-label-success";
            case 3: " uk-label-warning";
            case 4 | 5: " uk-label-danger";
            default : "";
        };

        return jsx('
            <div key=${Std.string(exercise.id)} className="uk-margin">
                <div>
                    <a href=$problemUrl target="_blank">${exercise.task.name}</a> <span className=${"uk-label" + labelStyle}>${Std.string(exercise.task.level)}</span>
                    $solvedMark
                    <span className="tags uk-margin-left uk-text-meta">$tags</span>
                    </div>
            </div>
        ');
    }

}
