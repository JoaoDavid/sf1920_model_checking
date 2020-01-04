#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3



chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, chan , chan};
mtype = { printReq, page , location};

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
  chan clientListenChan;

  int currPage;
  end:
  do
  :: request ? msgType, numPages, recvChan, clientListenChan ->
          clientListenChan ! location(_pid)
          printf("Printer %d received print request of %d pages\n", _pid, numPages);
          state = printing;
          do
          :: currPage < numPages ->
                  recvChan ? msgType, currPage;
                  printf("Printing page %d/%d\n", currPage, numPages)
          :: currPage == numPages ->
                  state = idle;
                  currPage = 0;
                  break
          od       
  od
}


//active [NUM_OF_CLIENTS] proctype client(int docLen) {
proctype client(int docLen) {
  int currPage = 0;
  //channel where the pages will be sent
  chan sendPages  = [1] of { mtype, int };
  //channel where the printer's name will be received
  chan recvPrinterName  = [1] of { mtype, int };
  //Sending print request
  request ! printReq(docLen, sendPages, recvPrinterName);
  int printerName;
  //Sending document's pages one by one  
  do
  :: currPage < docLen -> currPage++; sendPages ! page(currPage)
  :: else -> break
  od;
  //Receiving the printer's name (pid)
  recvPrinterName ? _, printerName;
  printf("Client %d may pick printouts from printer number %d\n", _pid, printerName)
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

proctype test2() {
  bool is = false;
  end:
  do
  :: is -> printf("test2\n")
  od
}

init {
  run client(5);
  run client(7);
  run client(3);
  run printer();
  run printer();
  run test2()
} 