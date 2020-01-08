bool wantP, wantQ;
active proctype P() {
    do
    :: wantP = true;
        do
        :: wantQ ->
            wantP = false;
            wantP = true
        :: else -> break
        od;
        wantP = false
    od
}

active proctype Q() {
    do
    :: wantQ = true;
        do
        :: wantP ->
            wantQ = false;
            wantQ = true
        :: else -> break
        od;
        wantQ = false
    od
}