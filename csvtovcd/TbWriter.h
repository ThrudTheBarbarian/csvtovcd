//
//  TbWriter.h
//  csvtovcd
//
//  Created by Simon on 21/10/2019.
//  Copyright © 2019 Me, myself, and I. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Writer.h"

NS_ASSUME_NONNULL_BEGIN

@interface TbWriter : Writer


@property (strong, nonatomic) NSString *			module;
@property (assign, nonatomic) BOOL					outputPrefix;
@property (assign, nonatomic) BOOL					outputPostfix;
@end

NS_ASSUME_NONNULL_END
