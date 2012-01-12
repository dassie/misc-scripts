/*
	This is a base64 decoder I wrote for a networking assignments.
	It works at the command line with the following format:
	./decoder -i [input-file] -o [output-file]
*/
#include <iostream>
#include <fstream>
#include <cstring>

using namespace std;

unsigned char debase(char c);
bool isvalid(char c);
void decode_block(unsigned char base64[4], unsigned char ascii[3]);

int main(int argc, char* argv[])
{
	ifstream fin;
	ofstream fout;
	
	//Parse the arguments to open both an input and output file stream
	if (argc < 5)
	{
		cout << "Error: need more arguments" << endl;
		return 0;
	}
	for (int i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-i") == 0)
		{
			fin.open(argv[i + 1]);
			if (fin.fail())
			{
				cout << "Error, unable to open file, " << argv[i + 1] << endl;
				return 0;
			}
		}
		else if (strcmp(argv[i], "-o") == 0)
		{
			fout.open(argv[i + 1]);
			if (fout.fail())
			{
				cout << "Error: unable to open file for output, " << argv[i + 1] << endl;
				return 0;
			}
		}
	}
	
	unsigned char inbuf[4];
	unsigned char outbuf[3];
	unsigned char t;
	
	//Go through the file, processing 4 characters at a time...
	while (!fin.eof())
	{
		for (int j = 0; j < 4 && !fin.eof(); j++)
		{
			t = fin.get();
			if (isvalid(t))
				inbuf[j] = debase(t);
			else
			{
				if (fin.eof())
					return 0;
				else if (t == '\n')
					j--;
				else if (t == '=')
					inbuf[j] = t = 0;
			}
		}
		decode_block(inbuf, outbuf);
		for (int k = 0; k < 3; k++)
			fout << outbuf[k];
	}
	
	fin.close();
	fout.close();
}


//Turn a character into it's corresponding base64 in decimal value
unsigned char debase(char c)
{
	if(c >='A' && c <='Z')
		return c - 'A';
	else if (c >='a' && c <='z')
		return c - 'a' + 26;
	else if (c >='0' && c <='9')
		return c - '0' + 52;
	else if (c == '+')
		return 62;
	else if (c == '/')
		return 63;
}

//Determines whether a given character is a valid base64 character
bool isvalid(char c)
{
	if (c >= 'A' && c <= 'Z')
		return true;
	else if (c >= 'a' && c <= 'z')
		return true;
	else if (c >= '0' && c <= '9')
		return true;
	else if (c == '+' || c == '/')
		return true;
	else
		return false;
}

//Decode a block of 4 base64 characters into 3 ascii characters
void decode_block(unsigned char base64[4], unsigned char ascii[3])
{
	ascii[0] = (unsigned char)(base64[0] << 2 | base64[1] >> 4);
	ascii[1] = (unsigned char)(base64[1] << 4 | base64[2] >> 2);
	ascii[2] = (unsigned char)(((base64[2] << 6) & 0xC0) | base64[3]);
}












