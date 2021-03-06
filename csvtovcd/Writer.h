//
//  Writer.h
//  csvtovcd
//
//  Created by Simon on 21/10/2019.
//  Copyright © 2019 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CsvReader;

@interface Writer : NSObject


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
- (void) writePrefix;

/*****************************************************************************\
|* Write the VCD data itself
\*****************************************************************************/
- (void) writeData:(BOOL)showProgress;

/*****************************************************************************\
|* Write the VCD preamble
\*****************************************************************************/
- (void) writePostfix;

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

NS_ASSUME_NONNULL_END
