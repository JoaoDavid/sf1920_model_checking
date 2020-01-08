byte request = 0;
active proctype Server1() {
    endserver1:
    do
    :: request == 1 -> printf("service 1\n"); request = 0
    od
}

active proctype Server2() {
    endserver2:
    do
    :: request == 2 -> printf("service 2\n"); request = 0
    od
}

active proctype Client() {
    request = 1;
    request == 0;
    request = 2;
    request == 0;
}