//
//  main.m
//  mergecsv
//
//  Created by Simon Gornall on 06/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArgParser.h"
#import "CsvReader.h"
#import "VcdWriter.h"

/*****************************************************************************\
|* Forward declarations
\*****************************************************************************/
void usage(void);

/*****************************************************************************\
|* Program entry point
\*****************************************************************************/
int main(int argc, const char * argv[])
	{
	@autoreleasepool
		{
		/*********************************************************************\
		|* Parse the arguments
		\*********************************************************************/
		[ArgParser initialiseWith:argc and:argv];
		
		NSString *file1		= [ArgParser stringFor:"-i"
												or:"--input-file"
									   withDefault:""];
		NSString *syncCol	= [ArgParser stringFor:"-s"
												or:"--sample-column"
									   withDefault:"Sample Number"];
		NSString *tsCol	 	= [ArgParser stringFor:"-t"
												or:"--timestamp-column"
									   withDefault:"Time"];
		NSString *output  	= [ArgParser stringFor:"-o"
												or:"--output-file"
									   withDefault:"output.vcd"];
		NSString *vecs  	= [ArgParser stringFor:"-v"
												or:"--vectors"
									   withDefault:""];
		BOOL needHelp		= [ArgParser  flagFor:"-h"
											   or:"--help"
									  withDefault:NO];
			
		/*********************************************************************\
		|* Check for help
		\*********************************************************************/
		if ([file1 length] == 0 || needHelp)
			usage();
			
		/*********************************************************************\
		|* Open the CSV file
		\*********************************************************************/
		CsvReader *csv 		= [[CsvReader alloc] initWithFile:file1];
		
		/*********************************************************************\
		|* If we have a sample-number column, skip to sample 0
		\*********************************************************************/
		if ([[csv columns] containsObject:syncCol])
			{
			while (YES)
				{
				NSDictionary *line = [csv nextLine];
				if ([[line objectForKey:syncCol] intValue] == 0)
					{
					[csv pushBack:line];
					break;
					}
				}
			}
		
		/*********************************************************************\
		|* Create the VCD writer
		\*********************************************************************/
		VcdWriter *vcd = [VcdWriter new];
		[vcd setTimeCol:tsCol];
		[vcd setSyncCol:syncCol];
		[vcd setCsv:csv];
		[vcd registerVars:vecs];

		if ([vcd openOutputFile:output])
			{
			[vcd writePreamble];
			[vcd writeData];
			[vcd closeOutputFile];
			}
		else
			fprintf(stderr, "Cannot open VCD file '%s' for output\n",
					[output fileSystemRepresentation]);
		}
	return 0;
	}

/*****************************************************************************\
|* Tell the world how we work
\*****************************************************************************/
void usage(void)
	{
	printf("Usage: csvtovcd [options] where options are:\n"
		"  -i | --input-file       <input.csv> \n"
		"  -h | --help             show this wonderful text\n"
		"  -o | --output-file      <output.vcd\n"
		"  -s | --sample column    <sample-id column name>   [Sample Number]\n"
		"  -t | --timestamp-column <timestamp column-name>   [Time]\n"
		"  -v | --vectors          <name:width>[,<name:width>,..]\n"
		);
	exit(0);
	}
