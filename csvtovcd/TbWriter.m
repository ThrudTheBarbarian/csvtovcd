//
//  TbWriter.m
//  csvtovcd
//
//  Created by Simon on 21/10/2019.
//  Copyright © 2019 Me, myself, and I. All rights reserved.
//

#import "NSString+Time.h"
#import "CsvReader.h"
#import "VcdVariable.h"

#import "TbWriter.h"

@implementation TbWriter

/*****************************************************************************\
|* Write the Testbench preamble
\*****************************************************************************/
- (void) writePrefix
	{
	NSString *now	= [NSDateFormatter localizedStringFromDate:[NSDate date]
													 dateStyle:NSDateFormatterShortStyle
													 timeStyle:NSDateFormatterShortStyle];
	
	FILE *fp 				= [self fp];
	NSDictionary *values	= [self values];
	
	/*************************************************************************\
	|* Start the module definition
	\*************************************************************************/
	fprintf(fp, "// File generated: %s\n\n"
				"`timescale 1ns / 100ps\n\n"
				"module %s_tb();\n",
				[now UTF8String],
				[_module UTF8String]);
	
	/*************************************************************************\
	|* Inputs to the module are reg-type
	\*************************************************************************/
	fprintf(fp, "\t// testbench inputs are reg-type\n");
	for (NSString *name in [values allKeys])
		{
		VcdVariable *var = [values objectForKey:name];
		char *saneName = [var saneName];
		if ([var bitWidth] == 1)
			fprintf(fp, "\treg\t\t%s;\n", saneName);
		else
			fprintf(fp, "\treg [%d:0]\t%s;\n", [var bitWidth]-1, saneName);
			
		}

	/*************************************************************************\
	|* Create an initial block with everything undefined
	\*************************************************************************/
	fprintf(fp, "\n\n\t// Set all values to undefined\n"
				"\tinitial begin\n");
	for (VcdVariable *var in [values allValues])
		{
		char *saneName = [var saneName];
		if ([var bitWidth] == 1)
			fprintf(fp, "\t\t%s=1'bx;\n", saneName);
		else
			{
			int len = [var bitWidth];
			
			fprintf(fp, "\t\t%s\t=%d'b%s;\n",
							saneName,
							len,
							[[@"" stringByPaddingToLength:len
											  withString:@"x"
										 startingAtIndex:0] UTF8String]);
			}
		}

	/*************************************************************************\
	|* Include a file for the actual testing
	\*************************************************************************/
	fprintf(fp, "\n\n\t// Include test logic\n"
				"\t`include \"%s_test.v\"\n", [_module UTF8String]);
		
	fprintf(fp, "\tend\n");
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
|* Write the testbench signal data
\*****************************************************************************/
- (void) writeData:(BOOL)showProgress
	{
	// Hoist these out of the loop to reduce overhead a bit
	CsvReader *csv 			= [self csv];
	FILE *fp 				= [self fp];
	NSString *timeCol		= [self timeCol];
	NSDictionary *vals		= [self values];
	
	NSDictionary *line 		= [csv nextLine];
	NSMutableString *info 	= [NSMutableString new];

	fprintf(fp, "\n\n\t// Start iterating the values\n"
				"\tinitial begin\n");

	while (line != nil)
		{
		@autoreleasepool
			{
			[info setString:@""];
			int64_t cron = [(NSString *)[line objectForKey:timeCol] picosecs] / 1000;
			
			for (NSString *col in [line allKeys])
				{
				VcdVariable *var = [vals objectForKey:col];
				uint64_t newVal	 = [self _stateFor:[line objectForKey:col]];
				BOOL changed     = [var setValue:newVal];
				if (changed)
					{
					if ([var bitWidth] == 1)
						[info appendFormat:@"\t\t%s = %lld;\n", [var saneName], newVal];
					else
						[info appendFormat:@"\t\t%s = %d'h%llx;\n", [var saneName], [var bitWidth], newVal];
					}
				
				}
			if ([info length])
				{
				fprintf(fp, "\t#%llu\n%s\n", cron, [info UTF8String]);
				fflush(fp);
				}
			line = [csv nextLine];
			}
		}
	fprintf(fp, "\tend\nendmodule\n");
	
	}


@end