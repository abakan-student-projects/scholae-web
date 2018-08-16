package model;

import messages.ArrayChunk;
import messages.TaskMessage;
import messages.TagMessage;
import utils.RemoteData;

typedef EditorState = {
    tags: RemoteData<Array<TagMessage>>,
    tasks: RemoteData<ArrayChunk<TaskMessage>>,
    tasksFilter: String,
    tasksActiveChunkIndex: Int,
    tasksChunkSize: Int
}