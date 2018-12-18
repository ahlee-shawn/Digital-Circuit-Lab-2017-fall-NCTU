#include <iostream>
#include <cstdio>
using namespace std;

int f[1024] = { };
int g[64] = { };
//int c[960];

int main(void)
{
    int x, y, k, sum, max_sum = 0, max_pos = 0;
    int i, j, input;
    cout << "Please input f[] :";
    for(i = 0; i < 1024; i++)
    {
        scanf("%x", &input);
        f[i] = input;
    }
    cout << "Please input g[] :";
    for(i = 0; i < 64; i++)
    {
        scanf("%x", &input);
        g[i] = input;
    }
    for (x = 0; x < 1024 - 64; x++)
    {
        sum = 0;
        for (k = 0; k < 64; k++)
        {
            sum += f[k+x] * g[k];
        }
        //c[x] = sum;
        if (sum > max_sum)
        {
            max_sum = sum;
            max_pos = x;
        }
    }
    //printf("Done\n");
    //printf("%d\n",f[0]);
    printf("Max value = %06x\n",max_sum);
    printf("Max location = %03x\n",max_pos);
}
