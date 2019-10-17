//
//  VcdWriter.m
//  csvtovcd
//
//  Created by Simon Gornall on 15/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import "NSString+Time.h"

#import "CsvReader.h"
#import "VcdWriter.h"
#import "VcdVariable.h"

@implementation VcdWriter


/*****************************************************************************\
|* Initialise an instance of the VCD writer
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
		[var setBitWidth:width];
		[var setIdentifier:_nextId++];
		[_values setObject:var forKey:name];
		}
	}


/*****************************************************************************\
|* Write the VCD preamble
\*****************************************************************************/
- (void) writePreamble
	{
	NSString *now	= [NSDateFormatter localizedStringFromDate:[NSDate date]
													 dateStyle:NSDateFormatterShortStyle
													 timeStyle:NSDateFormatterShortStyle];
		
	fprintf(_fp, "$date\n\t%s\n$end\n", [now UTF8String]);
	fprintf(_fp, "$version\n\tcsvtovcd v1.0\n$end\n");
	fprintf(_fp, "$timescale 1ps $end\n");
	
	fprintf(_fp, "$scope module logic $end\n");

	for (NSString *name in [_values allKeys])
		{
		VcdVariable *var = [_values objectForKey:name];
		fprintf(_fp, "$var wire %d %c %s $end\n",
					[var bitWidth],
					(char)[var identifier],
					[name UTF8String]);
		}
	fprintf(_fp, "$upscope $end\n$dumpvars\n");
	
	for (VcdVariable *var in [_values allValues])
		fprintf(_fp, "%s\n", [[var description] UTF8String]);
	fprintf(_fp, "$end\n");
	fflush(_fp);
	}


/*****************************************************************************\
|* Parse the state string into a numeric value
\*****************************************************************************/
- (uint64_t) _stateFor:(NSString *)val
	{
	uint64_t value = 0;
	if ([val isEqualToString:@"0"])
		;
	else if ([val isEqualToString:@"1"])
		value = 1;
	else
		{
		NSScanner *scanner = [NSScanner scannerWithString:val];
		[scanner scanHexLongLong:&value];
		}
	return value;
	}

/*****************************************************************************\
|* Write the VCD data
\*****************************************************************************/
- (void) writeData:(BOOL)showProgress
	{
	NSDictionary *line = [_csv nextLine];
	NSMutableString *info = [NSMutableString new];
	uint64_t count = 0;
	int lastPercent = 0;
	
	if (showProgress)
		fprintf(stderr, "Progress:  0%%");
		
	while (line != nil)
		{
		count += _lineSize;
		if (showProgress)
			{
			if ((count * 100)/_fileSize > lastPercent + 1)
				{
				lastPercent ++;
				fprintf(stderr, "%c[D%c[D%c[D%2d%%", 27, 27,27, lastPercent);
				}
			}
			
		[info setString:@""];
		int64_t cron = [(NSString *)[line objectForKey:_timeCol] picosecs];
		
		for (NSString *col in [line allKeys])
			{
			VcdVariable *var = [_values objectForKey:col];
			uint64_t newVal	 = [self _stateFor:[line objectForKey:col]];
			BOOL changed     = [var setValue:newVal];
			if (changed)
				[info appendFormat:@"%@\n", [var description]];
			}
		if ([info length])
			{
			fprintf(_fp, "#%llu\n%s\n", cron, [info UTF8String]);
			fflush(_fp);
			}
		line = [_csv nextLine];
		}
	if (showProgress)
		fprintf(stderr, "\n");
	}

@end
