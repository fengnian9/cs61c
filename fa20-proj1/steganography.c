/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				fengnian
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
	uint8_t blue = image->image[row][col].B;
    
    Color *newpixel = malloc(sizeof *newpixel);
    if (newpixel == NULL) {
        return NULL;
    }

    //identify the LSB
    if (blue & 1) {
        newpixel->R = 255;
        newpixel->G= 255;
        newpixel->B = 255;
    } else {
        newpixel->R = 0;
        newpixel->G= 0;
        newpixel->B = 0;
    }

    return newpixel;
    
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{   
    // creating new image
    Image *newimg = malloc(sizeof *newimg);
    if (newimg == NULL) {
        return NULL;
    }

    newimg->image = malloc(image->rows * sizeof *newimg->image);
    if (newimg->image == NULL) {
        free(newimg);
        return NULL;
    } 
    
    newimg->cols = image->cols;
    newimg->rows = image->rows;

    // assigning the pixel slots
    for (int r=0; r < image->rows; r++) {
        newimg->image[r] = malloc(image->cols * sizeof *newimg->image[r]);
    }

    for (int row = 0; row < image->rows; row++) {
        for (int col = 0; col < image->cols; col++) {
            Color *pixel;
            pixel = evaluateOnePixel(image, row, col);
            if (pixel == NULL) {
                return NULL;
            }

            newimg->image[row][col] = *pixel;

            free(pixel);
        }
    }	
    
    return newimg;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image, 
where each pixel is black if the LSB of the B channel is 0, 
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
    if (argc != 2) {
        return -1;
    }
	
    Image *image = readData(argv[1]);

    if (image == NULL) {
        return -1;
    }
    
    Image *stegImage = steganography(image);
    if (stegImage == NULL) {
        return -1;
    }
    
    freeImage(image);
    
    writeData(stegImage);
    freeImage(stegImage);

    return 0;
}
