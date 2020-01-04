#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3



chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, chan };
mtype = { printReq, page };

mtype = { idle, printing }; 
/*active proctype manager() {
  mtype printers[NUM_OF_PRINTERS] = {idle,idle,idle}
  do
  :: printers[0] == idle -> printers[0] = printing; printf("printer num 0 is now priniting\n")
  :: printers[1] == idle -> printers[1] = printing; printf("printer num 1 is now priniting\n")
  :: printers[2] == idle -> printers[2] = printing; printf("printer num 2 is now priniting\n")
  :: else -> printf("finished\n"); break
  od;
  //printf("my manger pid is %d\n", _pid)
}*/

//active [NUM_OF_PRINTERS] proctype printer() {
proctype printer() {
  mtype state = idle;
  mtype msgType;
  int numPages;
  chan recvChan;

  int currPage;
  end:
  do
  :: state == idle -> 
          request ? msgType, numPages, recvChan;
          printf("Printer %d received print request of %d pages\n", _pid, numPages);
          state = printing
  :: state == printing && currPage < numPages ->
          recvChan ? msgType, currPage;
          printf("Printing page %d/%d\n", currPage, numPages)
          //state = (currPage == numPages-> idle : printing) 
  :: currPage == numPages ->
          state = idle;
          currPage = 0
  od
}


//active [NUM_OF_CLIENTS] proctype client(int docLen) {
proctype client(int docLen) {
  int currPage = 0;
  chan sendPages  = [1] of { mtype, int };
  request ! printReq(docLen, sendPages);
  do
  :: currPage < docLen -> currPage++; sendPages ! page(currPage)
  :: else -> break
  od;
  printf("Client %d finished printing %d pages\n", _pid, currPage)
}

/*chan requestTest = [1] of { byte };
active [4] proctype Server() {
  byte client;
  end:
  do
  :: requestTest ? client -> printf("Creceive dlient %d\n", client)
  od
} 

active [2] proctype test() {
  int sfaf = 4;
  requestTest ! _pid
}*/

init {
  run client(5);
  run client(7);
  run client(3);
  run printer()
} 