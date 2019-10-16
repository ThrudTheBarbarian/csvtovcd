//
//  VcdWriter.h
//  csvtovcd
//
//  Created by Simon Gornall on 15/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CsvReader;

@interface VcdWriter : NSObject

/*****************************************************************************\
|* Open a file for output
\*****************************************************************************/
- (bool) openOutputFile:(NSString *)pathToFile;

/*****************************************************************************\
|* Close the output file
\*****************************************************************************/
- (void) closeOutputFile;

/*****************************************************************************\
|* Write the VCD preamble
\*****************************************************************************/
- (void) writePreamble;

/*****************************************************************************\
|* Write the VCD data itself
\*****************************************************************************/
- (void) writeData:(BOOL)showProgress;

/*****************************************************************************\
|* Run through the CSV vars, and create appropriate vectors and scalars
\*****************************************************************************/
- (void) registerVars:(NSString *)vectorSpec;


@property (strong, nonatomic) CsvReader *			csv;
@property (strong, nonatomic) NSString *			syncCol;
@property (strong, nonatomic) NSString *			timeCol;
@property (assign, nonatomic) uint64_t 				fileSize;
@property (assign, nonatomic) int 					lineSize;
@property (assign, nonatomic) int 					nextId;
@property (assign, nonatomic) FILE * 				fp;
@property (strong, nonatomic) NSMutableDictionary *	values;
@end
