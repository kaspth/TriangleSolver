//
//  Corner.h
//  TriangleSolver
//
//  Created by Kasper Timm on 26/08/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Corner : NSObject {
    NSString *name;
    float side;
    float angle;
}
@property (copy) NSString *name;
@property (assign) float side;
@property (assign) float angle;
@property (readonly) float angleInRadians;

- (id)initWithName:(NSString *)aName side:(float)aSide angle:(float)anAngle;
- (id)initWithName:(NSString *)aName;
- (Corner *)cornerForName:(NSString *)aName;
@end
