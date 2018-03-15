//
//  CSVReader.h
//  mergecsv
//
//  Created by Simon Gornall on 06/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CsvReader : NSObject
	{
	FILE *				_file;
	}

/*****************************************************************************\
|* Initialise an instance of the CSV reader
\*****************************************************************************/
- (id) initWithFile:(NSString *)filename;

/*****************************************************************************\
|* Read a line from the file and split it into components
\*****************************************************************************/
- (NSArray *) readLine;

/*****************************************************************************\
|* Convert a line into a dictionary of values
\*****************************************************************************/
- (NSDictionary *) nextLine;

/*****************************************************************************\
|* Push back a line for the next call to nextLine
\*****************************************************************************/
- (void) pushBack:(NSDictionary *)line;

@property (strong, nonatomic) NSArray * columns;
@property (assign, nonatomic) NSUInteger numColumns;
@property (strong, nonatomic) NSDictionary * last;
@end
