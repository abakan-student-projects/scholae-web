package view.teacher;

import utils.DateUtils;
import codeforces.Codeforces;
import messages.ExerciseMessage;
import haxe.ds.ArraySort;
import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import redux.react.IConnectedComponent;
import router.Link;

typedef TeacherTrainingProps = {
    group: GroupMessage,
    training: TrainingMessage,
    learner: LearnerMessage,
    tags: StringMap<TagMessage>
}

class TeacherTrainingView extends ReactComponentOfProps<TeacherTrainingProps> implements IConnectedComponent {

    public function new() { super(); }

    override function render() {

        if (null != props.training && null != props.group && null != props.learner) {

            var exercises = [for (e in props.training.exercises) renderExerciseRow(e)];

            return jsx('
                    <div className="training">
                        <div className="uk-margin">
                            <Link to=${"/teacher/group/" + props.group.id}><span data-uk-icon="chevron-left"></span>${props.group.name}</Link>
                        </div>
                        <h2 className="uk-margin-remove-top uk-margin-small-bottom">${props.training.name}</h2>
                        <h3 className="uk-margin-remove">${props.learner.lastName} ${props.learner.firstName}</h3>
                        <div className="exercises uk-margin-small-top">
                            <ul data-uk-accordion="multiple: true">
                                $exercises
                            </ul>
                        </div>
                    </div>
                ');
        } else {
            return jsx('<LoadingView description="Тренировка"/>');
        }
    }

    function renderExerciseRow(exercise: ExerciseMessage) {

        var tags = [];
        for (tag in exercise.task.tagIds) {
            var key = Std.string(tag);
            var t = props.tags.get(key);
            if (t != null) {
                tags.push(jsx('<span key=$key className="uk-margin-small-bottom uk-margin-small-right">${if (null != t.russianName) t.russianName else t.name}</span> '));
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
