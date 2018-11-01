package model;

import messages.LearnerMessage;
import messages.ArrayChunk;
import messages.TaskMessage;
import messages.TagMessage;
import utils.RemoteData;

typedef EditorState = {
    tags: RemoteData<Array<TagMessage>>,
    showNewTagView: Bool,
    tasks: RemoteData<ArrayChunk<TaskMessage>>,
    tasksFilter: String,
    tasksActiveChunkIndex: Int,
    tasksChunkSize: Int,
}