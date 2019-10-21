//
//  Writer.m
//  csvtovcd
//
//  Created by Simon on 21/10/2019.
//  Copyright © 2019 Me, myself, and I. All rights reserved.
//

#import "Writer.h"
#import "NSString+Time.h"

#import "CsvReader.h"
#import "VcdWriter.h"
#import "VcdVariable.h"

@implementation Writer

/*****************************************************************************\
|* Initialise an instance of the writer
\*****************************************************************************/
- (id) init
	{
	if (self = [super init])
		{
		_nextId	= 33;							// identifiers start at 33
		_values	= [NSMutableDictionary new];
		}
	return self;
	}


/*****************************************************************************\
|* Open a file for output
\*****************************************************************************/
- (bool) openOutputFile:(NSString *)pathToFile
	{
	bool ok 			= YES;
	const char *path	= [pathToFile fileSystemRepresentation];
	_fp 				= fopen(path, "w");

	if (_fp == NULL)
		{
		fprintf(stderr, "Failed to open output file %s\n", path);
		ok = NO;
		}

	return ok;
	}

/*****************************************************************************\
|* Close the output file
\*****************************************************************************/
- (void) closeOutputFile
	{
	fclose(_fp);
	}

/*****************************************************************************\
|* Run through the CSV vars, and create appropriate vectors and scalars
\*****************************************************************************/
- (void) registerVars:(NSString *)vectorSpec
	{
	/*************************************************************************\
	|* Parse the vector spec into a dictionary format
	\*************************************************************************/
	NSMutableDictionary *V = [NSMutableDictionary new];
	NSArray *vecs = [vectorSpec componentsSeparatedByString:@","];
	for (NSString *vec in vecs)
		{
		NSArray *kv = [vec componentsSeparatedByString:@":"];
		if ([kv count] == 2)
			[V setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
		}

	/*************************************************************************\
	|* Now run through the CsvReader variables, creating VcdVariables from them
	\*************************************************************************/
	for (NSString *name in [_csv columns])
		{
		if ((_syncCol != nil) && ([name isEqualToString:_syncCol]))
			continue;
		if ((_timeCol != nil) && ([name isEqualToString:_timeCol]))
			continue;
		NSString *varWidth = [V objectForKey:name];
		int width = 1;
		if (varWidth != nil)
			width = [varWidth intValue];
		
		VcdVariable *var = [VcdVariable new];
		[var setName:name];
		[var setBitWidth:width];
		[var setIdentifier:_nextId++];
		[_values setObject:var forKey:name];
		}
	}

/*****************************************************************************\
|* Write any preamble
\*****************************************************************************/
- (void) writePrefix
	{}

/*****************************************************************************\
|* Write any data
\*****************************************************************************/
- (void) writeData:(BOOL)showProgress
	{}

/*****************************************************************************\
|* Write any posfix
\*****************************************************************************/
- (void) writePostfix
	{}


@end
