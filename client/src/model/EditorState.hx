package model;

import haxe.ds.StringMap;
import messages.AssignmentMessage;
import messages.AttemptMessage;
import messages.GroupMessage;
import messages.LearnerMessage;
import messages.TagMessage;
import messages.TrainingMessage;
import utils.RemoteData;

typedef EditorState = {
    tags: RemoteData<Array<TagMessage>>
}