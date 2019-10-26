//
//  CSVReader.m
//  mergecsv
//
//  Created by Thrud the barbarian on 15/03/2018.
//  Copyright © 2018 Moebius Tech LLC. All rights reserved.
//

#import "CsvReader.h"

#define BZIP2_CMD		@"bzip2 -dc %@"
#define GZIP_CMD		@"gzip -dc %@"
#define COMPRESS_CMD	@"uncompress -c %@"

@implementation CsvReader

/*****************************************************************************\
|* Initialise an instance of the CSV reader
\*****************************************************************************/
- (id) initWithFile:(NSString *)filename
	{
	if (self = [super init])
		{
		_lineLength = 0;
		_columns 	= nil;
		_usePipe	= NO;
		
		/*********************************************************************\
		|* Open the file for read
		\*********************************************************************/
		const char *fname = [filename fileSystemRepresentation];
		if ([filename hasSuffix:@".bz2"])
			{
			NSString *cmd = [NSString stringWithFormat:BZIP2_CMD, filename];
			_file 		  = popen([cmd fileSystemRepresentation], "r");
			_usePipe	  = YES;
			}
		else if ([filename hasSuffix:@".gz"])
			{
			NSString *cmd = [NSString stringWithFormat:GZIP_CMD, filename];
			_file 		  = popen([cmd fileSystemRepresentation], "r");
			_usePipe	  = YES;
			}
		else if ([filename hasSuffix:@".Z"])
			{
			NSString *cmd = [NSString stringWithFormat:COMPRESS_CMD, filename];
			_file 		  = popen([cmd fileSystemRepresentation], "r");
			_usePipe	  = YES;
			}
		else
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
			if (_columns == nil)
				{
				[self _close];
				self = nil;
				}
			}
		}
	return self;
	}

/*****************************************************************************\
|* Close down file access
\*****************************************************************************/
- (void) _close
	{
	if (_file != NULL)
		{
		if (_usePipe)
			pclose(_file);
		else
			fclose(_file);
		}
	_file 		= NULL;
	_usePipe 	= NO;
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
		if (_columns != nil)
			_lineLength = (int) strlen(buf);
			
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
	else
		[self _close];
		
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
