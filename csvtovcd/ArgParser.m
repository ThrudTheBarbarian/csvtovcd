/*
 *  KArgParser.c
 *  sqld
 *
 *  Created by Simon G on 1/31/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "ArgParser.h"

#include <string.h>
#include <stdlib.h>

static int _argc;
static char ** _argv;

@implementation ArgParser

/*****************************************************************************\
|* Store the initial values for argc, argv
\*****************************************************************************/
+ (void) initialiseWith:(int)argc and:(const char **)argv
	{
	_argc = argc;
	_argv = (char **)argv;
	}


/*****************************************************************************\
|* Search for a string argument
\*****************************************************************************/
+ (NSString *) stringFor:(char *)arg or:(char *)alt withDefault:(char *)dflt
	{
	for (int i=1; i<_argc-1; i++)
		if (strcmp(arg, _argv[i]) == 0 ||
		    strcmp(alt, _argv[i]) == 0)
			return [NSString stringWithUTF8String:_argv[i+1]];
	return [NSString stringWithUTF8String:dflt];
	}
	
/*****************************************************************************\
|* Search for an integer argument
\*****************************************************************************/
+ (int) intFor:(char *)arg or:(char *)alt withDefault:(int)dflt
	{
	for (int i=1; i<_argc-1; i++)
		if (strcmp(arg, _argv[i]) == 0 || strcmp(alt, _argv[i]) == 0)
			return atoi(_argv[i+1]);
	return dflt;
	}
	
/*****************************************************************************\
|* Search for a float argument
\*****************************************************************************/
+ (float) floatFor:(char *)arg or:(char *)alt withDefault:(float)dflt
	{
	for (int i=1; i<_argc-1; i++)
		if (strcmp(arg, _argv[i]) == 0 || strcmp(alt, _argv[i]) == 0)
			return atof(_argv[i+1]);
	return dflt;
	}
	
/*****************************************************************************\
|* Search for a flag argument
\*****************************************************************************/
+ (BOOL) flagFor:(char *)arg or:(char *)alt withDefault:(BOOL)dflt
	{
	for (int i=1; i<_argc; i++)
		if (strcmp(arg, _argv[i]) == 0 ||
		    strcmp(alt, _argv[i]) == 0)
			return TRUE;
	return dflt;
	}

@end