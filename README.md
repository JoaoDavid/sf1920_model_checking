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


--------------- how to change channel's capacity and number of printers/clients -------------
At the top of the source file there are 3 define statements
representing the number of printers, clients and channel size respectively


-------------- no_page_mix_up and mutual_exclusion --------------------

Within the source file directory, execute the following commands:
spin -a PrintingSystem.pml
gcc -O2 -DSAFETY -o pan pan.c
pan

(-DSAFETY disables -a,-l,-f, because they are used to check liveness properties, and we pretend to check for SAFETY properties)

This two properties can be checked with the same assertion, written in the proctype printer:
assert(clientSentReq == clientSentPage)

When a printer pops a print request from the common shared asynchronous channel, it enters in printing mode. 
Only one printer can read that request, because the channel's read/write operations are atomic.
The request contains the number of pages to be printed, and since the pages must be sent one by one, 
the printer process has a do loop that will iterate as many times as the number of pages stated in the request.
In order to guarantee that the printer is not printing pages from different clients at the same time, 
the pages that are being sent to the printer must be from the same client that sent the print request, 
until all the pages are printed (client is served), and the printer becomes idle again. 
Thus the asserition previously mentioned must be true everytime a new page is received by the printer.

This also proves that the property no page mix-up holds, since each printer only prints pages from the request currently being processed

If the property is violated, the following message will show up
pan: assertion violated (<bool expression>) (at depth _)
Since this is a safety property (something good eventually happens)
a counterexample consists of one state where the formula is false.
In this case, it would be when the client that sent the page was not the same that sent the request to

If the property holds, the message simply won't be printed



------------------------ absence_of_starvation-------------------------

Within the source file directory, execute the following commands:
spin -a PrintingSystem.pml
gcc -O2 -o pan pan.c
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

In order to intentionally violate this property, just uncomment the code block inside proctype client
do
:: false -> skip
od;
This prevents the process from progressing further



