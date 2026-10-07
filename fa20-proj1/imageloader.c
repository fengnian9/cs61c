/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				fengnian
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

//Opens a .ppm P3 image file, and constructs an Image object. 
//You may find the function fscanf useful.
//Make sure that you close the file with fclose before returning.
Image *readData(char *filename) 
{
	FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        return NULL;
    }
    Image *img = malloc(sizeof *img);
    if (img == NULL) {
        fclose(fp);
        return NULL;
    }

    char magic[3];
    int cols, rows;
    int maxval;

    fscanf(fp, "%2s", magic);
    fscanf(fp, "%d %d", &cols, &rows);
    fscanf(fp, "%d", &maxval);

    img->cols = (uint32_t) cols;
    img->rows = (uint32_t) rows;

    img->image = malloc(rows * sizeof *img->image);
    if (img->image == NULL) {
        free(img);
        fclose(fp);
        return NULL;
    } 
    for (int r=0; r < rows; r++) {
        img->image[r] = malloc(cols * sizeof *img->image[r]);
    }
    
    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
            int r,g,b;
            fscanf(fp, "%d %d %d", &r,&g,&b);
            img->image[row][col].R = (uint8_t)r;
            img->image[row][col].G = (uint8_t)g;
            img->image[row][col].B = (uint8_t)b;
        }
    }

    fclose(fp);

    return img;
}

//Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image) {
    printf("P3\n");
    printf("%u %u\n", image->cols, image->rows);
    printf("255\n");
    for (int row = 0; row < image->rows; row++) {
        for (int col = 0; col < image->cols; col++) {
            Color pixel = image->image[row][col];

            printf("%3u %3u %3u", pixel.R, pixel.G, pixel.B);

            if (col + 1 < image->cols) {
                printf("   ");
            } else {
                printf("\n");
            }
        }
    }

}

//Frees an image
void freeImage(Image *image) {
    if (image == NULL) {
        return;
    }

    for (uint32_t row = 0; row < image->rows; row++) {
        free(image->image[row]);
    } 

    free(image->image);
    free(image);
}

