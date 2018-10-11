package messages;

import messages.NeercUserMessage;

typedef NeercUserMessage = {
    id: Float,
    lastName: String,
    codeforcesUser: CodeforcesUserMessage,
    university: NeercUniversityMessage
}
