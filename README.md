# sf1920_assignment3

spin -a PrintingSystem.pml
gcc -O2 -o pan pan.c
./pan -a -f -N <ltl's name, ex: absence_of_starvation>


/*
absence_of_starvation

Within the source file directory, execute the following commands:
spin -a PrintingSystem.pml
gcc -O2 -o pan pan.c
pan -a -f -N absence_of_starvation

(-a enables search for acceptance cyles)
(-f enables fairness mode)

If the property was violated, the following message will show up
pan: acceptance cycle (at depth _)
Since this is a liveness property (something good eventually happens)
a counter example is an inﬁnite computation in which something good never happens, in this case, the client is never served

If the property holds, the message pan: acceptance cycle (at depth _) will not be shown

In order to intentionally violate this property, comment the line of code:
served[_pid % NUM_OF_CLIENTS] = true;
This line of code states the client has been served, after he has sent all the pages to the printer that accepted his request. If commented, simulates the client never being served (starvation)
*/

/*
no_deadlock

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

In order to intentionally violate this property, just uncomment the code block
do
:: false -> skip
od;
This prevents the process from progressing further



*/