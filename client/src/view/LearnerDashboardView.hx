package view;

import utils.DateUtils;
import utils.StringUtils;
import haxe.ds.StringMap;
import messages.TagMessage;
import codeforces.Codeforces;
import messages.ExerciseMessage;
import messages.TrainingMessage;
import messages.AttemptMessage;
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

        var showSpinner =
            if (props.resultsRefreshing) jsx('<span className="uk-margin-left" data-uk-spinner=""></span>')
            else null;

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
                        $showSpinner
                    </div>
                    <ul data-uk-accordion=${true} className="trainings">$trainings</ul>
                </div>
            ');
        } else {
            return jsx('<LoadingView description="Тренировки"/>');
        }
    }

    function renderTraining(t: TrainingMessage) {
        var exercises = [ for (e in t.exercises) if(e != null) renderExercise(e) else null];
        return jsx('
                <li key=${t.id} className="traning">
                    <a className="uk-accordion-title" href="#">
                        <span className="uk-margin-right">${t.name}</span>
                        <span className="uk-label uk-margin-right">
                            ${t.assignment.metaTraining.length} ${StringUtils.getTaskStringFor(t.assignment.metaTraining.length)}
                        </span>
                        ${DateUtils.toString(t.assignment.startDate)} - ${DateUtils.toString(t.assignment.finishDate)}
                    </a>
                    <div className="uk-accordion-content uk-margin-left-small">
                        <ul data-uk-accordion="multiple: true">
                            $exercises
                        </ul>
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

        var attempt = if(exercise.attempts != null) {
            var a = [for (a in exercise.attempts)
                jsx('
                    <div className="uk-margin-small-bottom" key=${a.id}>
                        <a className="uk-link-text" href=${"http://codeforces.com/contest/"+ exercise.task.codeforcesContestId +"/submission/"+a.vendorId} target="_blank">
                            <span className="uk-label uk-text-capitalize uk-margin-small-left">
                                Посылка: ${a.vendorId} - ${DateUtils.toStringWithTime(a.datetime)}
                            </span>
                            <span className=${"uk-label uk-margin-small-left " + if(a.solved)"uk-label-success"else"uk-label-danger"}>
                                ${if(a.solved) "Решено" else "Ошибка"}
                            </span>
                        </a>
                    </div>
                ')
            ];
            jsx('
                <div className="attempts uk-margin-remove-top uk-accordion-content">
                    <div className="uk-margin-small-left uk-margin-small-bottom">
                        <Link to=$problemUrl target="_blank" className="uk-link-text ">
                            Перейти к условию задачи
                        </Link>
                    </div>
                    $a
                </div>
            ');
        }
        else {
            jsx('
                <div className="attempts uk-accordion-content uk-margin-remove-top">
                    <div className="uk-margin-small-left">
                        <Link to=$problemUrl target="_blank" className="uk-link-text uk-margin-small-left">
                            Перейти к условию задачи
                        </Link>
                    <div className="uk-margin-small-left">
                </div>
            ');
        }

        return jsx('
            <li key=${Std.string(exercise.id)} className="uk-margin-small-left">
                <a className="uk-accordion-title uk-margin-small-bottom" href="#">
                    <span className="uk-margin-small-right">${exercise.task.name}</span>
                    <span className=${"uk-label" + labelStyle}>${Std.string(exercise.task.level)}</span>
                    $solvedMark
                    <span className="tags uk-text-meta uk-margin-small-left">$tags</span>
                </a>
                $attempt
            </li>
        ');
    }

}
