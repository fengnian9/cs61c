/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
//Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
//and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
    Color *newpixel = malloc(sizeof *newpixel);
    if (newpixel == NULL) {
        return NULL;
    }
    
    // tracking alive neighbors for all 24 bit plane
    int alive_neighbors[3][8] = {0}; 
    
    // updates all 8 neighbor's living state
	for (int i = -1; i < 2; i++) {
        for (int j = -1; j < 2; j++) {
            if (i == 0 && j ==0) {
                continue;
            }
            int r = (row + i + (int)image->rows) % (int)image->rows;
            int c = (col + j + (int)image->cols) % (int)image->cols;
            
            Color neighbor = image->image[r][c];
            
            // comapres with the given neighbor's 24 color plane, 
            // updates the color state of the pixel
            for (int bit = 0; bit < 8; bit++) {
                alive_neighbors[0][bit] += (neighbor.R >> bit) &1;
                alive_neighbors[1][bit] += (neighbor.G >> bit) &1;
                alive_neighbors[2][bit] += (neighbor.B >> bit) &1;
            }      
        }
    }

    newpixel->R = 0;
    newpixel->G = 0;
    newpixel->B = 0;

    Color current = image->image[row][col];

    for (int bit = 0; bit < 8; bit++) {
        // calculates if each bit plane is alive
        int r_alive = (current.R >> bit) & 1;
        int g_alive = (current.G >> bit) & 1;
        int b_alive = (current.B >> bit) & 1;
        
        // adds 9 to the rule bits if they are alive, 
        // else the rule bits are the living neighbors
        int r_rule_bit = alive_neighbors[0][bit] + (r_alive ? 9 : 0);
        int g_rule_bit = alive_neighbors[1][bit] + (g_alive ? 9 : 0);
        int b_rule_bit = alive_neighbors[2][bit] + (b_alive ? 9 : 0);

        // apply the rule to every bit plane
        // this is done by first find out which rulebit to follow
        // then leftshift it to the right place
        newpixel->R |= ((rule >> r_rule_bit) & 1) << bit;
        newpixel->G |= ((rule >> g_rule_bit) & 1) << bit;
        newpixel->B |= ((rule >> b_rule_bit) & 1) << bit;
    }

    return newpixel;
}

//The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
//You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
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
            pixel = evaluateOneCell(image, row, col, rule);
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
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
	if (argc != 3) {
        return -1;
    }
	
    Image *image = readData(argv[1]);

    if (image == NULL) {
        return -1;
    }

    uint32_t rule;
    sscanf(argv[2], "%" SCNx32, &rule);
    
    Image *next_game_of_life = life(image, rule);
    if (next_game_of_life == NULL) {
        return -1;
    }
    
    freeImage(image);
    
    writeData(next_game_of_life);
    freeImage(next_game_of_life);

    return 0;
}
