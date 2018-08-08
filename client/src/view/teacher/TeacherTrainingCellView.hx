package view.teacher;

import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import react.ReactComponent;
import react.ReactMacro.jsx;
import utils.StringUtils;
import router.Link;

typedef TeacherTrainingCellProps = {
    assignment: AssignmentMessage,
    group: GroupMessage,
    training: TrainingMessage,
    tags: StringMap<TagMessage>
}

class TeacherTrainingCellView extends ReactComponentOfProps<TeacherTrainingCellProps> {

    public function new() { super(); }

    override function render() {
        var t = props.training;

        return if (t != null && Lambda.count(props.tags) > 0) {
            var minLevel = Lambda.fold(t.exercises, function(e, r) { return Std.int(Math.min(e.task.level, r)); }, 999);
            var maxLevel = Lambda.fold(t.exercises, function(e, r) { return Std.int(Math.max(e.task.level, r)); }, 0);
            var solved = Lambda.count(t.exercises, function(e) { return e.task.isSolved; });
            var tagIds: StringMap<Bool> = new StringMap<Bool>();
            for (e in t.exercises) {
                for (tagId in e.task.tagIds) {
                    tagIds.set(Std.string(tagId), true);
                }
            }
            var tags = [for (tag in tagIds.keys()) jsx('<span key=$tag className="uk-margin-small-bottom uk-margin-small-right">${props.tags.get(tag).name} </span> ')];
            var suffix = if (t.exercises.length == 1) "и" else "";
            jsx('
                <td key=${props.assignment.id}>
                    <Link className="uk-link-text" to="${'/teacher/group/' + props.group.id + '/training/' + t.id }">
                        <progress className="uk-progress" value=$solved max=${t.exercises.length}></progress>
                        <div className="uk-margin-small uk-text-meta">Сложность: $minLevel..$maxLevel</div>
                        <div className="uk-text-meta">Категории: $tags</div>
                    </Link>
                </td>
            ');
        } else {
            jsx('<td key=${props.assignment.id}></td>');
        }
    }
}
