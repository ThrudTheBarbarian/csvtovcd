//
//  VcdVariable.m
//  mergecsv
//
//  Created by Simon Gornall on 3/6/18.
//  Copyright © 2018 Simon Gornall. All rights reserved.
//

#import "VcdVariable.h"

@interface VcdVariable()
- (NSString *)binaryRep;
@end

#define ALLOW @"abcdefghijklmnopqrstuvwxyz" \
               "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"

@implementation VcdVariable

/*****************************************************************************\
|* Initialise
\*****************************************************************************/
- (id) init
	{
	if (self = [super init])
		{
		_valid = NO;
		}
	return self;
	}

/*****************************************************************************\
|* Return a representation of the variable suitable for dumping
\*****************************************************************************/
- (NSString *) description
	{
	NSString *result = nil;
	char c			 = (char)_identifier;
	
	switch (_bitWidth)
		{
		case 1:
			if (!_valid)
				result = [NSString stringWithFormat:@"x%c", c];
			else
				result = [NSString stringWithFormat:@"%d%c", (int)_value, c];
			break;
		
		default:
			if (!_valid)
				{
				NSString *rpt	 = [@"" stringByPaddingToLength:_bitWidth
									 withString:@"x"
								startingAtIndex:0];

				result = [NSString stringWithFormat:@"b%@ %c", rpt, c];
				}
			else
				result = [NSString stringWithFormat:@"b%@ %c",
							[self binaryRep], c];
			break;
		}
	return result;
	}

/*****************************************************************************\
|* set the value of the variable
\*****************************************************************************/
- (bool) setValue:(uint64_t)value
	{
	bool changed = (value != _value) || (_valid == NO);
	_value = value;
	_valid = YES;
	return changed;
	}

/*****************************************************************************\
|* set the value of a bit within the variable
\*****************************************************************************/
- (bool) setBit:(int)bit to:(uint64_t)value
	{
	uint64_t newValue = (value)
					  ? _value | (1<<bit)
					  : _value & (~(1<<bit));
		
	bool changed = (_value != newValue) || (_valid == NO);
	_value = newValue;
	_valid = YES;
	return changed;
	}

/*****************************************************************************\
|* Make sure the variable names are valid
\*****************************************************************************/
- (char *) saneName
	{
	NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:ALLOW];
	s				  = [s invertedSet];
	NSArray *regions  = [_name componentsSeparatedByCharactersInSet:s];
	
	NSString *newName = [regions componentsJoinedByString:@""];
	if ([_name rangeOfString:@"/"].location != NSNotFound)
		newName = [NSString stringWithFormat:@"%@_n", newName];
	return (char *) [newName UTF8String];
	}

#pragma mark -
#pragma mark Private Methods

/*****************************************************************************\
|* Convert a uint64_t into a binary representation of size 'bitWidth'
\*****************************************************************************/
- (NSString *)binaryRep
	{
    NSString *bits = @"";

    for (int i = 0; i < _bitWidth; i ++)
        bits = [NSString stringWithFormat:@"%i%@", _value & (1<<i) ? 1 : 0, bits];

    return bits;
	}

@end
