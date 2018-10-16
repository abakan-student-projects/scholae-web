package messages;

class MessagesHelper {
    public static inline function successResponse(result: Dynamic): ResponseMessage {
        return { status: ResponseStatus.OK, result: result };
    }

    public static inline function failResponse(errorMessage: String): ResponseMessage {
        return { status: ResponseStatus.Error, result: null, message: errorMessage };
    }
}
