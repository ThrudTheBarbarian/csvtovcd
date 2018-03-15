//
//  TimeReader.m
//  csvtovcd
//
//  Created by Simon Gornall on 15/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import "NSString+Time.h"

@implementation NSString (Time)

/*****************************************************************************\
|* Convert a string time-specification to picoseconds
\*****************************************************************************/
- (uint64_t) picosecs
	{
	char 	unit[32];
	double	value;
	uint64_t ns = 0;
	
	if (sscanf([self UTF8String], "%lf %s", &value, unit) == 2)
		{
		uint64_t multiply = 1;
		
		switch (unit[0])
			{
			case 'u':
				multiply = 1000000;
				break;
			case 'm':
				multiply = 1000000000;
				break;
			case 's':
				multiply = 1000000000000;
				break;
			default:
				break;
			}
		
		ns = (uint64_t)(value * multiply);
		}
		
	return ns;
	}


@end
