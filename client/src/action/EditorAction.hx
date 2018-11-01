package action;

import messages.ArrayChunk;
import messages.TaskMessage;
import messages.AssignmentMessage;
import messages.AttemptMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;

enum EditorAction {

    Clear;

    LoadTags;
    LoadTagsFinished(tags: Array<TagMessage>);

    InsertTag(tag: TagMessage);
    InsertTagFinished(tag: TagMessage);

    UpdateTag(tag: TagMessage);
    UpdateTagFinished(tag: TagMessage);

    LoadTasks(filter: String, offset: Int, limit: Int);
    LoadTasksFinished(tags: ArrayChunk<TaskMessage>);
    SetTasksChunkIndex(index: Int);
    SetTasksFilter(filter: String);

    UpdateTaskTags(taskId: Float, tags: Array<Float>);
    UpdateTaskTagsFinished(task: TaskMessage);

    ShowNewTagView;
    HideNewTagView;
}
