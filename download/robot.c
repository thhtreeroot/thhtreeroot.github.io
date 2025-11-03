#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <stdint.h>
#include <unistd.h>

#define COUNT 100

void timeout(int sig) {
    puts("\nTime's up, toooooooooooo slow!");
    exit(0);
}

void initial() {
    alarm(30);
    signal(SIGALRM, timeout);
    setbuf(stdin, NULL);
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);
    srand(time(0));
}

int main() {
    initial();
    printf("Welcome to flag faucet, please answer the following %d questions to verify you are robot.\n", COUNT);
    for (int i = 0; i < COUNT; i++) {
        uint64_t a = rand(), b = rand(), ans;
        printf("Q%d: %lu * %lu = ", i, a, b);
        scanf("%lu", &ans);
        if (ans != a * b) {
            puts("Incorrect, try harder.");
            return 0;
        }
        printf("Correct, %d questions left.\n", COUNT - i - 1);
    }
    puts("Good job! Here is your shell, find flag on your own.");
    system("/bin/sh");
    return 0;
}