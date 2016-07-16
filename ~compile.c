/*************************************************************************
    > File Name: compile.c
    > Author: chendi
    > Mail: trendy@xiyoulinux.org
    > Created Time: 2015年11月20日 星期五 15时17分35秒
 ************************************************************************/

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<sys/types.h>
#include<regex.h>

int errornum=0;
char error[10][1024];

void push_error(line)
{
	sprintf(error[errornum++],"第%d行有错误",line);
}

int StrToInt(char *str)
{
	int value  = 0;
	int sign   = 1;
	int result = 0;
	if(NULL == str)
	{
		return -1;
	}
	if('-' == *str)
	{
		sign = -1;
		str++;
	}
	while(*str)
	{
		value = value * 10 + *str - '0';
		str++;
	}
	result = sign * value;
	return result;
}

char dataseg[10][40];
int dsp=0;
char codeseg[100][40];
int csp=0;


int enter_ds(char *str)
{
	strcpy(dataseg[dsp],str);
	dsp++;
}
int enter_cs(char *str)
{
	strcpy(codeseg[csp],str);
	csp++;
}



void _add(char *num1,char *num2,char *obj)
{
	char code[40];
	enter_cs("xor ax,ax");
	sprintf(code,"mov al,%s",num1);
	enter_cs(code);
	sprintf(code,"mov bl,%s",num2);
	enter_cs(code);
	enter_cs("add ax,bx");
	sprintf(code,"mov %s,al",obj);
	enter_cs(code);
}

void _sub(char *num1,char *num2,char *obj)
{
	char code[40];
	enter_cs("xor ax,ax");
	sprintf(code,"mov al,%s",num1);
	enter_cs(code);
	sprintf(code,"mov bl,%s",num2);
	enter_cs(code);
	enter_cs("sub ax,bx");
	sprintf(code,"mov %s,al",obj);
	enter_cs(code);
}

void _div(char *num1,char *num2,char *obj)
{
	char code[40];
	enter_cs("xor ax,ax");
	sprintf(code,"mov al,%s",num1);
	enter_cs(code);
	sprintf(code,"mov bl,%s",num2);
	enter_cs(code);
	enter_cs("div bl");
	sprintf(code,"mov %s,al",obj);
	enter_cs(code);
}

void _mul(char *num1,char *num2,char *obj)
{
	char code[40];
	enter_cs("xor ax,ax");
	sprintf(code,"mov al,%s",num1);
	enter_cs(code);
	sprintf(code,"mov bl,%s",num2);
	enter_cs(code);
	enter_cs("mul bl");
	sprintf(code,"mov %s,al",obj);
	enter_cs(code);
}

int stack_in(char *str,char stack[][8],int num)
{
	int i;
	for(i=0;i<num;i++)
	{
		if(strcmp(str,stack[i])==0)
			return 1;
	}
	return 0;
}

void print_str(char *str)
{
	char code[40];
	sprintf(code,"buf db '%s$'",str);
	enter_ds(code);
	enter_cs("lea dx,buf");
	enter_cs("mov ah,9");
	enter_cs("INT 21H");
}



void print_result(char *var)
{
	char code[40];
	enter_cs("xor ax,ax");
	sprintf(code,"mov al,%s",var);
	enter_cs(code);
	enter_cs("mov bl,10");
	enter_cs("div bl");
	enter_cs("mov bh,ah");
	enter_cs("mov dl,al");
	enter_cs("add dl,30h");
	enter_cs("mov ah,2");
	enter_cs("int 21h");
	enter_cs("mov dl,bh");
	enter_cs("add dl,30h");
	enter_cs("mov ah,2");
	enter_cs("int 21h");
}

void write_file(char *obj)
{
	FILE *fp;
	int i;
	if((fp=fopen(obj,"wt"))==NULL)
	{
		printf("创建目标文件失败\n");
	}
	for(i=0;i<dsp;i++)
	{
		fprintf(fp,"%s\n",dataseg[i]);
	}
	for(i=0;i<csp;i++)
	{
		fprintf(fp,"%s\n",codeseg[i]);
	}
	fclose(fp);
}

int main(int argc,char* argv[])
{
	
	char str[1024][1024];
	int line=0;
	char var_char[10][8];
	int charp=0;
	char var_int[10][8];
	int intp=0;
	char value[10];
	char num1[8];
	char num2[8];
	if(argc>3)
	{
		printf("参数过多\n");
	}
	FILE *fp;
	if((fp=fopen(argv[1],"rt"))==NULL)
	{
		printf("不存在源文件\n");
		return -1;
	}
	int i,j,status;
	while(!feof(fp))
	{
		fgets(str[line],1024,fp);
		for(i=0;i<strlen(str[line]);i++)
			if(str[line][i]==' '||str[line][i]=='\t'||str[line][i]=='\n')
			{
				for(j=i;j<strlen(str[line]);j++)
					str[line][j]=str[line][j+1];
				i--;
			}
		line++;
	}
	/*
	char msg[200000];
	for(i=0;i<line;i++)
	{
		strcat(msg,str[i]);
	}
	*/
	fclose(fp);
	
	/*
	for(i=0;i<line;i++)
	{
		printf("%s",str[i]);
	}
	*/
	regex_t reg;
	const char *pattern;
	regmatch_t pmatch[10];
	char temp[8];
	int k;
	char code_str[40];
	enter_ds("data segment");
	enter_cs("code segment");
	enter_cs("assume cs:code,ds:data");
	enter_cs("start:");
	enter_cs("mov ax,data");
	enter_cs("mov ds,ax");
	for(i=0;i<line;i++)
	{
		//变量声明判断(支持char和int)
		if(str[i][0]=='c' && str[i][1]=='h' && str[i][2]=='a' && str[i][3]=='r')
		{
			k=0;
			for(j=4;j<strlen(str[i]);j++)
			{
				if((str[i][j]>='A'&&str[i][j]<='Z')||(str[i][j]>='a' && str[i][j]<='z')||str[i][j]=='_')
				{
					temp[k++]=str[i][j];
				}
				else if(str[i][j]==','||str[i][j]==';')
				{
					temp[k]='\0';
					strcpy(var_char[charp],temp);
					charp++;
					k=0;
				}
				else
				{
					push_error(i+1);
					break;
				}
			}
		}
		if(str[i][0]=='i' && str[i][1]=='n' && str[i][2]=='t')
		{
			k=0;
			for(j=3;j<strlen(str[i]);j++)
			{
				if((str[i][j]>='A'&&str[i][j]<='Z')||(str[i][j]>='a' && str[i][j]<='z')||str[i][j]=='_')
				{
					temp[k++]=str[i][j];
				}
				else if(str[i][j]==','||str[i][j]==';')
				{
					temp[k]='\0';
					strcpy(var_int[intp],temp);
					intp++;
					k=0;
				}
				else
				{
					push_error(i+1);
					break;
				}
			}
		}
		pattern="^([a-zA-Z]+)=([0-9]+);$";
		regcomp(&reg,pattern,REG_EXTENDED);
		if(regexec(&reg,str[i],3,pmatch,0)==0)
		{
			k=0;
			for(j=pmatch[1].rm_so;j<pmatch[1].rm_eo;j++)
				temp[k++]=str[i][j];
			temp[k]='\0';
			if(stack_in(temp,var_char,charp))
			{
				k=0;
				for(j=pmatch[2].rm_so;j<pmatch[2].rm_eo;j++)
					value[k++]=str[i][j];
				value[k]='\0';
				sprintf(code_str,"%s db %d",temp,StrToInt(value));
				enter_ds(code_str);
			}
			else if(stack_in(temp,var_int,intp))
			{
				k=0;
				for(j=pmatch[2].rm_so;j<pmatch[2].rm_eo;j++)
					value[k++]=str[i][j];
				value[k]='\0';
				//printf("%s\n",value);
				sprintf(code_str,"%s db %d",temp,StrToInt(value));
				enter_ds(code_str);
			}
			else
				push_error(i+1);
		}
		regfree(&reg);
		pattern="^([a-zA-Z]+)=([a-zA-Z]+)[/]([a-zA-Z]+);$";
		regcomp(&reg,pattern,REG_EXTENDED);
		if(regexec(&reg,str[i],4,pmatch,0)==0)
		{
			k=0;
			for(j=pmatch[1].rm_so;j<pmatch[1].rm_eo;j++)
				temp[k++]=str[i][j];
			temp[k]='\0';
			if(stack_in(temp,var_char,charp) ||stack_in(temp,var_int,intp))
			{
				sprintf(code_str,"%s db ?",temp);
				enter_ds(code_str);
			}
			else
				push_error(i+1);
			k=0;
			for(j=pmatch[2].rm_so;j<pmatch[2].rm_eo;j++)
				num1[k++]=str[i][j];
			num1[k]='\0';
			k=0;
			for(j=pmatch[3].rm_so;j<pmatch[3].rm_eo;j++)
				num2[k++]=str[i][j];
			num2[k]='\0';

			if((stack_in(num1,var_char,charp) ||stack_in(num1,var_int,intp)) && (stack_in(num2,var_char,charp) ||stack_in(num2,var_int,intp)))
			{
				//_add(num1,num2,temp);
				//_div(num1,num2,temp);
				_mul(num1,num2,temp);
				//_sub(num1,num2,temp);

			}
		}
		regfree(&reg);
		pattern="^printf\\(\"(.*)%d\",([A-Za-z]+)\\);$";
		regcomp(&reg,pattern,REG_EXTENDED);
		if(regexec(&reg,str[i],3,pmatch,0)==0)
		{
			k=0;
			for(j=pmatch[1].rm_so;j<pmatch[1].rm_eo;j++)
				temp[k++]=str[i][j];
			temp[k]='\0';
			print_str(temp);
			k=0;
			for(j=pmatch[2].rm_so;j<pmatch[2].rm_eo;j++)
				temp[k++]=str[i][j];
			temp[k]='\0';
			printf("%s\n",temp);
			print_result(temp);
		}
	}
	enter_ds("data ends");
	enter_cs("mov ah,4ch");
	enter_cs("int 21h");
	enter_cs("code ends");
	enter_cs("end start");
	write_file(argv[2]);	
	printf("编译完毕！\n");
	for(i=0;i<errornum;i++)
	{
		printf("%s\n",error[i]);
	}
	return 0;
	
}
