package model;

import haxe.EnumFlags;

typedef Roles = EnumFlags<Role>;

enum Role {
    Learner;
    Teacher;
    Administrator;
    Editor;
}
