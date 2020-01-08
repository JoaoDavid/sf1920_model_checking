/**
 * Reliable Software
 * Department of Informatics
 * Faculty of Sciences
 * University of Lisbon
 * January 08, 2020
 * João David n49448
 *
 * Model checking of a printing system
 */
#define NUM_OF_PRINTERS 3
#define NUM_OF_CLIENTS 2
#define PRINTING_CHANNEL_CAPACITY 3


//channel used to send requests
chan request = [PRINTING_CHANNEL_CAPACITY] of { int, int, chan , chan};

proctype printer() {
  int numPages;
  chan recvChan;
  chan replyChan;  
  int clientSentReq; //ghost variable
  int clientSentPage; //ghost variable  
  endprinter: //comment this statement in order to violate deadlock property
  do
  //printer is iddle
  :: request ? clientSentReq, numPages, recvChan, replyChan ->
          //printer accepted print request from client 'clientSentReq'
          replyChan ! _pid;
          printf("Printer number %d received print request of %d pages\n", _pid, numPages);          
          int currPage = 0
          //printer will enter printing mode
          do          
          :: currPage < numPages ->
                  recvChan ? clientSentPage, currPage; //receiving page one by one
                  printf("Printer number %d printing page %d/%d\n", _pid, currPage, numPages);                  
                  //change from == to != in the following assert statement in order to violate the propery
                  assert(clientSentReq == clientSentPage) //no page mix-up property
          :: currPage == numPages ->
                  recvChan ? _, _; //confirm end of print
                  //printer finished printing all pages of the document
                  //changing printer's state to idle
                  break
          od       
  od
}

int printerServing [NUM_OF_PRINTERS]; //ghost variable
bool served [NUM_OF_CLIENTS]; //ghost variable, has the client been served?
//ltl absence_of_starvation {eventually always served[_pid % NUM_OF_CLIENTS]}
proctype client(int docLen) {  
  //channel where the pages will be sent
  chan sendPages  = [1] of { int, int };
  //channel where the printer's name will be received, so the client may know where to pick the printouts
  chan recvPrinterName  = [1] of { int };
  served[_pid % NUM_OF_CLIENTS] = false; //ghost variable
  //Sending print request
  request ! _pid, docLen, sendPages, recvPrinterName;
  int printerName;
  //Receiving the printer's name (pid)
  recvPrinterName ? printerName; //printerName is the printer that accepted the request
  
  //Sending document's pages one by one
  int currPageSent = 0;
  do
  :: currPageSent < docLen ->
        printerServing[printerName % NUM_OF_PRINTERS]++; //ghost variable, printer at index printerName % NUM_OF_PRINTERS is serving a client
        //sending pages to printer        
        currPageSent++;
        sendPages ! _pid, currPageSent;
        //only one client can send pages to a printer at a time
        assert (printerServing[printerName % NUM_OF_PRINTERS] <= 1) //mutual exclusion property
        printerServing[printerName % NUM_OF_PRINTERS]--; //ghost variable, printer stoped serving the client   
  :: else ->
        sendPages ! _pid, currPageSent; //confirm end of print
        break
  od;
  
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
  run client(5);
  run printer();
  run printer()
}

/*
--------------- how to change channel's capacity  -------------
At the top of the source file there is the statement #define PRINTING_CHANNEL_CAPACITY 3
representing channel size, just change that number in order to change its size


-------------- no_page_mix_up --------------------

Within the source file directory, execute the following commands:
(make sure the ltl formulas are commented)
spin -a PrintingSystem.pml
gcc -O2 -DSAFETY -o pan pan.c
pan

(-DSAFETY disables -a,-l,-f, because they are used to check liveness properties, and we pretend to check for SAFETY properties)

The property can be checked with following assertion inside proctype printer:
assert(clientSentReq == clientSentPage)

When a printer pops a print request from the common shared asynchronous channel, it enters in printing mode. 
Only one printer can read that request, because the channel's read/write operations are atomic.
The request contains the number of pages to be printed, and since the pages must be sent one by one, 
the printer process has a do loop that will iterate as many times as the number of pages stated in the request.
In order to guarantee that the printer is not mixing up pages from different clients, 
the pages that are being sent to the printer must be from the same client that sent the print request, 
until all the pages are printed (client is served), and the printer becomes idle again. 
Thus the asserition previously mentioned must be true everytime a new page is received by the printer.


If the property is violated, the following message will show up
pan: assertion violated (<bool expression>) (at depth _)
Since this is a safety property (something good eventually happens)
a counterexample consists of one state where the formula is false.
In this case, it would be when the client that sent the page was not the same that sent the request to

If the property holds, the message simply won't be printed



-------------- mutual_exclusion --------------------
Within the source file directory, execute the following commands:
(make sure the ltl formulas are commented)
spin -a PrintingSystem.pml
gcc -O2 -DSAFETY -o pan pan.c
pan

(-DSAFETY disables -a,-l,-f, because they are used to check liveness properties, and we pretend to check for SAFETY properties)

The property can be checked with following assertion inside proctype printer:
assert (printerServing[printerName % NUM_OF_PRINTERS] <= 1)
This means that, from the moment a client receives the first message sent by the printer that accepted his request
until the last message, that specific printer is only being sent pages at max from one client

If the property is violated, the following message will show up
pan: assertion violated (<bool expression>) (at depth _)
Since this is a safety property (something good eventually happens)
a counterexample consists of one state where the formula is false.
In this case, it would be when two clients are sending pages to the same printer at the same time

If the property holds, the message simply won't be printed


------------------------ absence_of_starvation-------------------------

Within the source file directory, execute the following commands:
(make sure the ltl formulas are UNcommented)
spin -a PrintingSystem.pml
gcc -O2 -DNFAIR=3 -o pan pan.c
pan -a -f -N absence_of_starvation

(-a enables search for acceptance cyles)
(-f enables fairness mode)

If the property was violated, the following message will show up
pan: acceptance cycle (at depth _)
Since this is a liveness property (something good eventually happens)
a counter example is an inﬁnite computation in which something good never happens, 
in this case, the client is never served

If the property holds, the message pan: acceptance cycle (at depth _) will not be shown

In order to intentionally violate this property, comment the line of code, present in proctype client:
served[_pid % NUM_OF_CLIENTS] = true;
This line of code states the client has been served, after he has sent all the pages to the printer that accepted his request. 
If commented, simulates the client never being served (starvation)



------------------------------ no_deadlock -----------------------------------

Within the source file directory, execute the following commands:
(make sure the ltl formulas are commented)
spin -a PrintingSystem.pml
gcc -O2 -DSAFETY -o pan pan.c
pan

(-DSAFETY disables -a,-l,-f, because they are used to check liveness properties)

This property is automatically verified by spin, no need to use custom ltl
If the property was violated, the following message will show up
pan: invalid end state (at depth _)
Since this is a safety property (something good eventually happens)
a counterexample consists of one state where the formula is false.

If there is no deadlock in the model, the message pan: invalid end state (at depth _) will not be shown

In order to intentionally violate this property, just comment the code block inside proctype printer
endprinter:
*/