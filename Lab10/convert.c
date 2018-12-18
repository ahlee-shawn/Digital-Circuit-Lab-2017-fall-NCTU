#include <stdio.h>

unsigned char buf[31*30*3];

int main(int argc, char **argv)
{
	int width, height, idx;
	FILE *fp = fopen(argv[1], "rb"),*fout;
	fout = fopen("f5.mem","w+t");
	if (fp == NULL) return 1;
	fgets(buf, sizeof(buf), fp); fgets(buf, sizeof(buf), fp);
	sscanf(buf, "%d %d", &width, &height);
	fgets(buf, sizeof(buf), fp);
	fread(buf, width, height*3, fp); 
	fclose(fp);
	for (idx = 0; idx < width*height; idx++)
	{ 
		fprintf(fout,"%1x%1x%1x\n", buf[3*idx+0]>>4, buf[3*idx+1]>>4, buf[3*idx+2]>>4);
	} 
	return 0;
}

