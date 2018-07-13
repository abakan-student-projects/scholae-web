package messages;

typedef ResponseMessage = {
    status: ResponseStatus,
    result: Dynamic,
    ?message: String
}
