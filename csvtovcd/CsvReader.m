//
//  CSVReader.m
//  mergecsv
//
//  Created by Thrud the barbarian on 15/03/2018.
//  Copyright © 2018 Moebius Tech LLC. All rights reserved.
//

#import "CsvReader.h"

@implementation CsvReader

/*****************************************************************************\
|* Initialise an instance of the CSV reader
\*****************************************************************************/
- (id) initWithFile:(NSString *)filename
	{
	if (self = [super init])
		{
		/*********************************************************************\
		|* Open the file for read
		\*********************************************************************/
		const char *fname = [filename fileSystemRepresentation];
		_file = fopen (fname, "r");
		if (_file == NULL)
			{
			fprintf(stderr, "Cannot open file '%s'\n", fname);
			self = nil;
			}
		else
			{
			/*****************************************************************\
			|* Parse the first line for column names
			\*****************************************************************/
			_columns = [self readLine];
			}
		}
	return self;
	}

/*****************************************************************************\
|* Read a line from the file and split it into components
\*****************************************************************************/
- (NSArray *) readLine
	{
	char buf[65535];
	bool eof = (fgets(buf, 65535, _file) == NULL);
	
	NSMutableArray *array = [NSMutableArray array];
	if (!eof)
		{
		NSCharacterSet *set	= [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r\""];
		NSString *line 		= [NSString stringWithUTF8String:buf];
		NSArray *items 		= [line componentsSeparatedByString:@","];
		
		_numColumns = 0;
		for (NSString *item in items)
			{
			[array addObject:[item stringByTrimmingCharactersInSet:set]];
			_numColumns ++;
			}
		}
	
	if ([array count] == 0)
		array = nil;
		
	return array;
	}

/*****************************************************************************\
|* Convert a line into a dictionary of values
\*****************************************************************************/
- (NSDictionary *) nextLine
	{
	NSMutableDictionary *items = [NSMutableDictionary dictionary];
	if (_last)
		{
		items = [_last mutableCopy];
		_last = nil;
		}
	else
		{
		NSArray *values = [self readLine];
		if (values)
			{
			NSUInteger num	= [values count];
			if (num == _numColumns)
				{
				for (NSUInteger i=0; i<num; i++)
					{
					NSString *key = [_columns objectAtIndex:i];
					NSString *val = [values objectAtIndex:i];
					[items setObject:val forKey:key];
					}
				}
			else
				fprintf(stderr, "Mismatch between columns and header\n");
			}
		}
	if ([items count] == 0)
		items = nil;
		 
	return items;
	}

/*****************************************************************************\
|* Push back a line for the next call to nextLine
\*****************************************************************************/
- (void) pushBack:(NSDictionary *)line
	{
	_last = line;
	}

@end
