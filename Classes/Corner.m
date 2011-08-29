//
//  Corner.m
//  TriangleSolver
//
//  Created by Kasper Timm on 26/08/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Corner.h"

@implementation Corner
@synthesize name, side, angle;

- (id)initWithName:(NSString *)aName side:(float)aSide angle:(float)anAngle {
    if ((self = [super init])) {
        [self setName:aName];
        [self setSide:aSide];
        [self setAngle:anAngle];
    }
    return self;
}

- (id)initWithName:(NSString *)aName {
    return [self initWithName:aName side:0 angle:0]; 
}

- (float)angle {
    return (angle * 180)/M_PI;
}

- (void)setAngle:(float)newAngle {
    angle = (newAngle * M_PI)/180;
}

- (float)angleInRadians {
    return angle;
}

- (Corner *)cornerForName:(NSString *)aName {
    if ([aName isEqualToString:self.name]) {
        return self;
    } else {
        NSLog(@"No Corner found with name: %@", aName);
        return nil;
    }
}

- (void)dealloc {
    
    [name release];
    
    [super dealloc];
}

@end
