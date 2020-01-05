#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3



chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, chan , chan};
mtype = { printReq, page , location};
mtype = { idle, printing }; 


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



init {
  run client(5);
  run client(7);
  run client(3);
  run printer();
  run printer()
} 