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
|* Write the VCD preamble
\*****************************************************************************/
- (void) writePrefix
	{
	NSString *now	= [NSDateFormatter localizedStringFromDate:[NSDate date]
													 dateStyle:NSDateFormatterShortStyle
													 timeStyle:NSDateFormatterShortStyle];
	
	FILE *fp 				= [self fp];
	NSDictionary *values	= [self values];
	
	fprintf(fp, "$date\n\t%s\n$end\n", [now UTF8String]);
	fprintf(fp, "$version\n\tcsvtovcd v1.0\n$end\n");
	fprintf(fp, "$timescale 1ps $end\n");
	
	fprintf(fp, "$scope module logic $end\n");

	for (NSString *name in [values allKeys])
		{
		VcdVariable *var = [values objectForKey:name];
		fprintf(fp, "$var wire %d %c %s $end\n",
					[var bitWidth],
					(char)[var identifier],
					[name UTF8String]);
		}
	fprintf(fp, "$upscope $end\n$dumpvars\n");
	
	for (VcdVariable *var in [values allValues])
		fprintf(fp, "%s\n", [[var description] UTF8String]);
	fprintf(fp, "$end\n");
	fflush(fp);
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
	// Hoist these out of the loop to reduce overhead a bit
	CsvReader *csv 			= [self csv];
	FILE *fp 				= [self fp];
	int lineSize			= [self lineSize];
	uint64_t fileSize		= [self fileSize];
	NSString *timeCol		= [self timeCol];
	NSDictionary *vals		= [self values];
	
	NSDictionary *line 		= [csv nextLine];
	NSMutableString *info 	= [NSMutableString new];
	uint64_t count 			= 0;
	int lastPercent 		= 0;
	
	if (showProgress)
		fprintf(stderr, "Progress:  0%%");
		
	while (line != nil)
		{
		@autoreleasepool
			{
			count += lineSize;
			if (showProgress)
				{
				if ((count * 100)/fileSize > lastPercent + 1)
					{
					lastPercent = (lastPercent < 99) ? lastPercent + 1 : 99;
					fprintf(stderr, "%c[D%c[D%c[D%2d%%", 27, 27,27, lastPercent);
					}
				}
				
			[info setString:@""];
			
			[info setString:@""];
			int64_t cron = [(NSString *)[line objectForKey:timeCol] picosecs];
			
			for (NSString *col in [line allKeys])
				{
				VcdVariable *var = [vals objectForKey:col];
				uint64_t newVal	 = [self _stateFor:[line objectForKey:col]];
				BOOL changed     = [var setValue:newVal];
				if (changed)
					[info appendFormat:@"%@\n", [var description]];
				}
			if ([info length])
				{
				fprintf(fp, "#%llu\n%s\n", cron, [info UTF8String]);
				fflush(fp);
				}
			line = [csv nextLine];
			}
		}
	if (showProgress)
		fprintf(stderr, "%c[D%c[D%c[D100%%\n", 27, 27, 27);
	}


@end
