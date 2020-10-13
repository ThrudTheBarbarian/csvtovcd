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
	NSMutableDictionary *vals   = [NSMutableDictionary new];
	NSMutableDictionary *names	= [NSMutableDictionary new];

	NSArray *vecs = [vectorSpec componentsSeparatedByString:@","];
	for (NSString *vec in vecs)
		{
		NSString *spec		= vec;
		NSString *newName	= nil;
        
		NSArray *replace	= [spec componentsSeparatedByString:@"="];
		if ([replace count] == 2)
			{
			spec			= [replace objectAtIndex:0];
			newName         = [replace objectAtIndex:1];
			}

		NSString *bitWidth	= @"1";
		NSString *oldName   = spec;
		NSArray *kv         = [spec componentsSeparatedByString:@":"];

		if ([kv count] == 2)
			{
			oldName  = [kv objectAtIndex:0];
			bitWidth = [kv objectAtIndex:1];
			}
            
		if (newName == nil)
			newName = oldName;
			
		[vals setObject:bitWidth forKey:oldName];
		[names setObject:newName forKey:oldName];
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
		NSString *varWidth = [vals objectForKey:name];
		if (varWidth)
			{
			int width = 1;
			if (varWidth != nil)
				width = [varWidth intValue];
			
			VcdVariable *var = [VcdVariable new];
			[var setName:[names objectForKey:name]];
			[var setBitWidth:width];
			[var setIdentifier:_nextId++];
			[_values setObject:var forKey:name];
			}
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
