package messages;

import messages.NeercUserMessage;

typedef NeercUserMessage = {
    id: Float,
    lastName: String,
    codeforcesUsersId: Float,
    universityId: Float,
    codeforcesUser: CodeforcesUserMessage,
    university: NeercUniversityMessage
}
