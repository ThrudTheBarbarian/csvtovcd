//
//  VcdVariable.h
//  mergecsv
//
//  Created by Simon Gornall on 3/6/18.
//  Copyright © 2018 Simon Gornall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VcdVariable : NSObject
	{
	uint64_t			_value;
	}

/*****************************************************************************\
|* set the value of the variable
\*****************************************************************************/
- (bool) setValue:(uint64_t)value;

/*****************************************************************************\
|* set the value of a bit within the variable
\*****************************************************************************/
- (bool) setBit:(int)bit to:(uint64_t)value;


@property (assign, nonatomic)	int 		bitWidth;
@property (assign, nonatomic)	int			identifier;
@property (assign, nonatomic)	bool		valid;
@end
