/**
 * Reliable Software
 * Department of Informatics
 * Faculty of Sciences
 * University of Lisbon
 * January 09, 2020
 * João David n49448
 *
 * Printing system using Mdel Checking
 */
#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2 
#define PRINTING_CHANNEL_CAPACITY 3


//channel used to send requests
chan request = [PRINTING_CHANNEL_CAPACITY] of { mtype, int, int, chan , chan};
//types of messages
mtype = { printReq, page , location};


//active [NUM_OF_PRINTERS] proctype printer() {
proctype printer() {
  mtype msgType;
  int numPages;
  chan recvChan;
  chan clientListenChan;  
  int clientSentReq; //ghost variable
  int clientSentPage; //ghost variable
  end:
  do
  //printer is iddle
  :: request ? msgType, clientSentReq, numPages, recvChan, clientListenChan ->
          //printer accepted print request from client 'clientSentReq'
          clientListenChan ! location(_pid);
          printf("Printer number %d received print request of %d pages\n", _pid, numPages);          
          int currPage = 0
          //printer will enter printing mode
          do          
          :: currPage < numPages ->
                  recvChan ? msgType, clientSentPage, currPage; //receiving page one by one
                  printf("Printer number %d printing page %d/%d\n", _pid, currPage, numPages);
                  //Mutual exclusion and no page mix-up properties
                  //change from == to != in the following assert statement in order to violate the properties
                  assert(clientSentReq == clientSentPage)
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


/*
HOW TO CHANGE THE NUMBER OF PRINTERS AND CLIENTS

Change the values in the #define statements at the top of the file
and then make sure that the number of run client(x) statements is equal to NUM_OF_CLIENTS
and the number of run printer() statements is equal to NUM_OF_PRINTERS
*/
init {
  run client(5);
  run client(7);
  run printer();
  run printer()
}
