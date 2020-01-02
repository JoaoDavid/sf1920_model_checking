active proctype P() {
    int value = 123;
    int reversed = (value % 10) * 100 + ((value / 10) % 10) * 10 + (value / 100);
    printf("value = %d, reversed = %d\n", value, reversed)
}
//spin rev.pml
//outputs
//value = 123, reversed = 321