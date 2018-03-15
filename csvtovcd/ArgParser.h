/*
 *  KArgParser.h
 *  sqld
 *
 *  Created by Simon G on 1/31/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface ArgParser : NSObject

+ (void) initialiseWith:(int)argc and:(const char **)argv;

+ (NSString *) stringFor:(char *)arg or:(char *)alt withDefault:(char *)dflt;
+ (int) intFor:(char *)arg or:(char *)alt withDefault:(int)dflt;
+ (float) floatFor:(char *)arg or:(char *)alt withDefault:(float)dflt;
+ (BOOL) flagFor:(char *)arg or:(char *)alt withDefault:(BOOL)dflt;

@end
