//
//  SimpleModel.m
//  CollectionMobile
//
//  Created by 惠上科技 on 2018/12/24.
//  Copyright © 2018 惠上科技. All rights reserved.
//

#import "SimpleModel.h"

@implementation SimpleModel

-(instancetype)init{
    self = [super init];
    if (self) {
        NSMutableArray *section = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
        _model = [NSMutableArray arrayWithObjects:section, nil];
    }
    return self;
}

@end
