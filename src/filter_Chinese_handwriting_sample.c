/*******************************************************************************

Program to filter a Multiple Pattern Feature (MPF) file, a binary file format
used in the Chinese handwriting database. This program receives a MPF file
as input, filters its contents, and writes the results into standard output.

The MPF description can be found at the following link:

http://www.nlpr.ia.ac.cn/databases/download/feature_data/FileFormat-mpf.pdf

    Copyright (C) 2017 Marcelo S. Reis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http:www.gnu.org/licenses/>.

*******************************************************************************/


# include <malloc.h>
# include <stdio.h>
# include <string.h>

# define DIMENSIONALITY 512


/*

  This function receives a file name file_name for a MPF file. It returns 0 if
  it could successfully read, discretize and create an output featsel DAT file
  or returns 1 otherwise.

*/
int filter_MPF_file (char * file_name);


/*******************************************************************************

  Main function of the program.

*/
int main (int argc, char * argv [])
{
  if (argc != 2)
  {
    printf ("Syntax: %s same_file.mpf\n", argv[0]);
    return 0;
  }

  return filter_MPF_file (argv[1]);
}


/******************************************************************************/


int filter_MPF_file (char * file_name)
{
  FILE          * sample_file_pointer;
  int             i, j = 1;
  unsigned char   aux;
  long int        size_of_header;     /* 62 B + strlen (illustr) */
  unsigned char   format_code [8];    /* "MPF\0" */
  unsigned char * illustr = NULL;     /* "Character features ... \0" */
  unsigned char   code_type [20];     /* "ASCII\0", "GB\0", etc. */
  short int       code_length;        /* 1, 2, 4, etc. */
  char            data_type [20];     /* "unsigned char", "short", etc. */
  /* long int        sample_number; */
  long int        dimensionality = DIMENSIONALITY;
  short int       vector [DIMENSIONALITY * sizeof (unsigned char)];

  /* try to open file */
  sample_file_pointer = fopen (file_name, "r");
  if (sample_file_pointer == NULL)
  {
    printf ("Error while opening file %s\n!", file_name);
    return 1;
  }

  /* 4 bytes are reserved for the header size */
  fscanf (sample_file_pointer, "%c", &aux);
  size_of_header = (long int) aux;
  printf ("%li\n", size_of_header);
  for (i = 0; i < 3; i++)
  {
    fscanf (sample_file_pointer, "%c", &aux);
    if (aux != 0)
    {
      printf ("ERROR: the remaining bytes of header size are not zero!\n");
      fclose (sample_file_pointer);
      return 1;
    }
  }

  /* 8 bytes are reserved for the format code */
  for (i = 0; i < 8; i++)
    fscanf (sample_file_pointer, "%c", &format_code[i]);
  printf ("%s\n", format_code);

  /* (size_of_header - 62) bytes are reserved for the illustration */
  illustr = (unsigned char *) malloc ((size_of_header - 62) * sizeof (char));
  for (i = 0; i < (size_of_header - 62); i++)
    fscanf (sample_file_pointer, "%c", &illustr[i]);
  printf ("%s\n", illustr);

  /* 20 bytes are reserved for code type */
  for (i = 0; i < 20; i++)
    fscanf (sample_file_pointer, "%c", &code_type[i]);
  printf ("%s\n", code_type);

  /* 2 bytes are reserved for code length */
  fscanf (sample_file_pointer, "%c", &aux);
  code_length = (short int) aux;
  printf ("%hi\n", code_length);
  fscanf (sample_file_pointer, "%c", &aux);
  if (aux != 0)
  {
    printf ("ERROR: the remaining byte of header size is not zero!\n");
    fclose (sample_file_pointer);
    return 1;
  }

  /* 20 bytes are reserved for data type */
  for (i = 0; i < 20; i++)
    fscanf (sample_file_pointer, "%c", &data_type[i]);
  printf ("%s\n", data_type);

  /* 4 bytes are reserved for sample number */
  for (i = 0; i < 4; i++)
    fscanf (sample_file_pointer, "%c", &aux);
  
  /* 4 bytes are reserved for dimensionality */
  for (i = 0; i < 4; i++)
    fscanf (sample_file_pointer, "%c", &aux);

  /* now the remaining data are sample records (concatenated) */
  if (strcmp (data_type, "unsigned char") == 0)
  {
    while ((fscanf (sample_file_pointer, "%c", &aux)) && 
           (! feof (sample_file_pointer)))
    {
      /* Print the class label; for instance, the GB code of the
         current Chinese character. Link for a GB code table:

         http://www.ansell-uebersetzungen.com/gborder.html
      */ 
      printf ("%2x", aux);
      /* read remaining of the class label (code_length bytes) */
      for (i = 1; i < (int) code_length; i++)
      {
        fscanf (sample_file_pointer, "%c", &aux);
        printf ("%2x", aux);
      }
      j++;

      /* Read vector (dimensionality * sizeof (data_type) bytes) */
      for (i = 0; i < (int) dimensionality * sizeof (unsigned char); i++)
      {
        fscanf (sample_file_pointer, "%c", &aux);
        vector[i] = (short int) aux;
        printf (" %3hi", vector[i]);
      }
      printf ("\n");
    }
  }
  else
  {
    printf ("ERROR: unknown data type '%s'!\n", data_type);
    fclose (sample_file_pointer);
    free (illustr);
    return 1;
  }
 
  /* free illustr array and close file */
  if (illustr != NULL)
    free (illustr);
  fclose (sample_file_pointer);

  return 0;
}



