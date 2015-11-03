//
//  OSFastGraphics.h
//  CocoaImageHashing
//
//  Created by Andreas Meingast on 13/10/15.
//  Copyright © 2015 Andreas Meingast. All rights reserved.
//

#import "OSTypes.h"

#pragma mark - Matrix Greyscale Mapping

void greyscale_pixels_rgba_32_32(unsigned char *pixels, double result[32][32]);

#pragma mark - DCT

void fast_dct_rgba_32_32(double pixels[32][32], double result[32][32]);
void dct_rgba_32_32(double pixels[32][32], double result[32][32]);

double avg_greyscale_value_rgba_8_8(unsigned char *pixels);
double fast_avg_no_first_el_rgba_8_8(double pixels[32][32]);

#pragma mark - Perceptual Hashes

OSHashType phash_rgba_8_8(double pixels[32][32], double dctAverage);
OSHashType ahash_rgba_8_8(unsigned char *pixels);
OSHashType dhash_rgba_9_8(unsigned char *pixels);
