#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3



chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, int, chan , chan};
mtype = { printReq, page , location};


int clientSentReq [NUM_OF_PRINTERS];
int clientSentPage [NUM_OF_PRINTERS];
//ltl mutex {always eventually clientSentReq == clientSentPage until numPages == currPage}
//active [NUM_OF_PRINTERS] proctype printer() {
proctype printer() {
  mtype msgType;
  int numPages;
  chan recvChan;
  chan clientListenChan;  
  
  end:
  do
  //printer is iddle
  :: request ? msgType, clientSentReq[_pid % NUM_OF_PRINTERS], numPages, recvChan, clientListenChan ->
          //printer accepted print request from client 'clientSentReq'
          clientListenChan ! location(_pid);
          printf("Printer number %d received print request of %d pages\n", _pid, numPages);          
          int currPage = 0
          do          
          :: currPage < numPages ->
                  recvChan ? msgType, clientSentPage[_pid % NUM_OF_PRINTERS], currPage; //receiving page one by one
                  printf("Printer number %d printing page %d/%d\n", _pid, currPage, numPages);
                  //Mutual exclusion and no page mix-up properties
                  //change from == to != in the following assert in order to violate the properties
                  assert(clientSentReq[_pid % NUM_OF_PRINTERS] == clientSentPage[_pid % NUM_OF_PRINTERS])
          :: currPage == numPages ->
                  //printer finished printing all pages of the document
                  //changing printer's state to idle
                  break
          od       
  od
}


bool served [NUM_OF_CLIENTS]; //ghost variable, has the client been served?
//ltl absence_of_starvation {eventually always served[_pid % NUM_OF_CLIENTS]}
//active [NUM_OF_CLIENTS] proctype client(int docLen) {
proctype client(int docLen) {  
  //channel where the pages will be sent
  chan sendPages  = [1] of { mtype, int, int };
  //channel where the printer's name will be received, so the client may know where to pick the printouts
  chan recvPrinterName  = [1] of { mtype, int };
  served[_pid % NUM_OF_CLIENTS] = false; //ghost variable
  //Sending print request
  request ! printReq(_pid, docLen, sendPages, recvPrinterName);
  int printerName;
  //Sending document's pages one by one
  int currPageSent = 0;
  do
  :: currPageSent < docLen -> currPageSent++; sendPages ! page(_pid, currPageSent)
  :: else -> break
  od;
  //Receiving the printer's name (pid)
  recvPrinterName ? _, printerName;
  //uncomment the following code in order to violate no_deadlock property
  /*do
  :: false -> skip
  od;*/
  served[_pid % NUM_OF_CLIENTS] = true; //ghost variable, comment this line in order to violate ltl absence_of_starvation
  printf("Client %d may pick printouts from printer number %d\n", _pid, printerName);  
}



init {
  run client(5);
  run client(7);
  run printer();
  run printer()
}