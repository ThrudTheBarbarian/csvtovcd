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
#import "TbWriter.h"

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
		NSString *ofile		= @"output.vcd";
		if ([file1 length] > 0)
			{
			ofile = [NSString stringWithFormat:@"%@.vcd",
							[file1 stringByDeletingPathExtension]];
			}
		char * oname = (char *)[ofile UTF8String];
		
		NSString *syncCol	= [ArgParser stringFor:"-s"
												or:"--sample-number"
									   withDefault:"Sample Number"];
		NSString *tsCol	 	= [ArgParser stringFor:"-t"
												or:"--timestamp-column"
									   withDefault:"Time"];
		NSString *output  	= [ArgParser stringFor:"-o"
												or:"--output-file"
									   withDefault:oname];
		NSString *vUser  	= [ArgParser stringFor:"-v"
												or:"--vectors"
									   withDefault:""];
		NSString *module  	= [ArgParser stringFor:"-m"
												or:"--module"
									   withDefault:""];
		BOOL prefix			= [ArgParser  flagFor:"-mp"
											   or:"--module-preamble"
									  withDefault:NO];
		BOOL postfix		= [ArgParser  flagFor:"-mP"
											   or:"--module-postfix"
									  withDefault:NO];
		BOOL hideProgress	= [ArgParser  flagFor:"-p"
											   or:"--hide-progress"
									  withDefault:NO];
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
		|* If we have no vectorSpec, generate it from the CSV file
		\*********************************************************************/
		NSString *vecs = vUser;
		if ([vUser length] == 0)
			{
			NSMutableString *vGen 	= [NSMutableString new];
			NSArray * cols		 	= [csv columns];
			NSDictionary *line		= [csv nextLine];
			[csv pushBack:line];
			
			int idx = -1;
			NSString *comma = @"";
			for (NSString *column in cols)
				{
				idx ++;
				if ([column isEqualToString:tsCol])
					continue;
				
				NSUInteger width = 1;
				NSString *entry = [line objectForKey:column];
				if ([entry length] > 1)
					width = 4 * [entry length];
				
				[vGen appendFormat:@"%@%@:%d", comma, column, (int)width];
				comma = @",";
				}
			
			vecs = vGen;
			}

		/*********************************************************************\
		|* Figure out the length of a line of data
		\*********************************************************************/
		NSDictionary *line = [csv nextLine];
		int lineLen = [csv lineLength];
		[csv pushBack:line];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		uint64_t fileSize = [[fm attributesOfItemAtPath:file1 error:nil] fileSize];
		

		/*********************************************************************\
		|* If we have a module name, then assume test-bench output
		\*********************************************************************/
		Writer *writer = nil;
		
		if ([module length] > 0)
			{
			TbWriter *tb=  [TbWriter new];
			[tb setModule:module];
			[tb setOutputPrefix:prefix];
			[tb setOutputPostfix:postfix];
			writer = tb;
			
			if ([output hasSuffix:@".vcd"])
				{
				output = [output stringByDeletingPathExtension];
				output = [NSString stringWithFormat:@"%@.v", output];
				}
			}
		else
			{
			/*********************************************************************\
			|* Create the VCD writer
			\*********************************************************************/
			VcdWriter *vcd = [VcdWriter new];
			writer = vcd;
			}
			
		[writer setTimeCol:tsCol];
		[writer setSyncCol:syncCol];
		[writer setCsv:csv];
		[writer registerVars:vecs];
		[writer setLineSize:lineLen];
		[writer setFileSize:fileSize];

		if ([writer openOutputFile:output])
			{
			[writer writePrefix];
			[writer writeData:!hideProgress];
			[writer closeOutputFile];
			}
		else
			fprintf(stderr, "Cannot open file '%s' for output\n",
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
		"  -m | --module           <module_name> for testbench output\n"
		"  -o | --output-file      <output.vcd>\n"
		"  -s | --sample column    <sample-id column name>   [Sample Number]\n"
		"  -t | --timestamp-column <timestamp column-name>   [Time]\n"
		"  -v | --vectors          <name:width>[,<name:width>,..]\n"
		);
	exit(0);
	}
