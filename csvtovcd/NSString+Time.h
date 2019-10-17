//
//  TimeReader.h
//  csvtovcd
//
//  Created by Simon Gornall on 15/03/2018.
//  Copyright © 2018 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Time)

/*****************************************************************************\
|* Convert a string time-specification to picoseconds
\*****************************************************************************/
- (int64_t) picosecs;

@end
