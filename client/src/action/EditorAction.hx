package action;

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
}
