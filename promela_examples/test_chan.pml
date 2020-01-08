

chan request  = [1] of { int, int };
chan pages  = [1] of { int, int };

proctype printer() {
    int docLen;
    int currClient;    
    request ? currClient , docLen;
    int currPage = 0;
    do
    :: currPage <= docLen ->
            pages ?? eval(currClient), _;
            currPage++        
    :: else -> break
    od
}


proctype client(int docLen) {
    int currPage = 0;
    request ! _pid, 4;
    do
    :: currPage <= docLen ->
            pages ! _pid, currPage;
            currPage++        
    :: else -> break
    od
}

init {
  run printer();
  run client(1)
}



