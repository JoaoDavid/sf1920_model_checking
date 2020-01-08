bool wantP = false, wantQ = false;
bool csp = false, csq = false;
//ltl mutex {always !(csp && csq)}
//ltl absence_of_starvation {eventually csp}
active proctype P() {
    do
    :: wantP = true;
        !wantQ;
        csp = true;
        //cirtical section
        csp = false;
        wantP = false;
    od
}

active proctype Q() {
    do
    :: wantQ = true;
        !wantP;
        csq = true;
        //cirtical section
        csq = false;
        wantQ = false;
    od
}