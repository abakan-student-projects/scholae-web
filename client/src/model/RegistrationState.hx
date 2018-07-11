package model;

typedef RegistrationState = {
    codeforcesId: String,
    email: String,
    password: String,
    registered: Bool,
    redirectPath: String,
    errorMessage: String
//TODO: implement checking codeforces id through the registration process
//    codeforcesName: String,
//    codeforcesAvatar: String,
//    codeforcesIdValid: Bool,
//    codeforcesInfoLoading: Bool
}