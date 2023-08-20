
int doit(void) 
{
    int x[20];
    register int i;
    for(i = 0; i < 20; i++)
        x[i] = i;
    return i; 
}

int main(void) {
    doit();
    return 0;
}