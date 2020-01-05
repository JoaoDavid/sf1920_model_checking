#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3



chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, int, chan , chan};
mtype = { printReq, page , location};
mtype = { idle, printing }; 


ltl no_page_mix_up {always eventually clientSentReq == clientSentPage}
int clientSentReq;
int clientSentPage;
//active [NUM_OF_PRINTERS] proctype printer() {
proctype printer() {
  mtype state = idle;
  mtype msgType;
  int numPages;
  chan recvChan;
  chan clientListenChan;  
  
  end:
  do
  :: request ? msgType, clientSentReq, numPages, recvChan, clientListenChan ->
          clientListenChan ! location(_pid)
          printf("Printer %d received print request of %d pages\n", _pid, numPages);
          state = printing;
          int currPage;
          do
          :: currPage < numPages ->
                  recvChan ? msgType, clientSentPage, currPage;
                  printf("Printing page %d/%d\n", currPage, numPages);
                  //assert(clientSentReq == clientSentPage)
          :: currPage == numPages ->
                  //changing printer's state to idle
                  state = idle;
                  break
          od       
  od
}


bool served = false; //ghost variable, has the client been served?
ltl absence_of_starvation {eventually served}
//active [NUM_OF_CLIENTS] proctype client(int docLen) {
proctype client(int docLen) {  
  //channel where the pages will be sent
  chan sendPages  = [1] of { mtype, int, int };
  //channel where the printer's name will be received
  chan recvPrinterName  = [1] of { mtype, int };
  served = false; //ghost variable
  //Sending print request
  request ! printReq(_pid, docLen, sendPages, recvPrinterName);
  int printerName;
  //Sending document's pages one by one
  int currPage = 0;
  do
  :: currPage < docLen -> currPage++; sendPages ! page(_pid, currPage)
  :: else -> break
  od;
  //Receiving the printer's name (pid)
  recvPrinterName ? _, printerName;
  //served -> served = true;
  served = true; //ghost variable
  printf("Client %d may pick printouts from printer number %d\n", _pid, printerName);  
}



init {
  run client(5);
  run client(7);
  run client(3);
  run printer();
  run printer()
}