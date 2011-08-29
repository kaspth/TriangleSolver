//
//  Triangle.m
//  TriangleSolver
//
//  Created by Kasper Timm on 26/08/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Triangle.h"

#pragma  mark - Corner Implementation
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

- (void)dealloc {
    [name release];
    
    [super dealloc];
}

@end

#pragma mark - Triangle
@interface Triangle(resultsString)
@property (readwrite, copy) NSString *resultsString;
- (void)clearResults;
- (void)noSolutionReason:(NSString *)reason informDelegateAndNotify:(BOOL)notify;
- (void)appendAreaToResults;
@end

@interface Triangle(calculations)
- (float)calculateSideFromItsAngle:(float)a usingSideWithAngle:(Corner *)s2;
- (float)calculateLastAngleFromFirstAngle:(float)angle1 secondAngle:(float)angle2;
- (float)calculateAngleFromItsSide:(float)s usingSideWithAngle:(Corner *)sa;
- (float)calculateAngleFromItsSide:(float)ownSide usingFirstSide:(float)s1 second:(float)s2;
- (void)areaForCompleteTriangle:(Triangle *)t;
- (float)areaForFirstSide:(float)s1 second:(float)s2 andAngleInRadians:(float)a;
@end

@interface Triangle(cases)
- (void)caseAngle:(Corner *)a1 withSide:(Corner *)s andAngle:(Corner *)a2;
- (void)caseSide:(Corner *)s1 withIncludedAngle:(Corner *)a andSide:(Corner *)s2;
- (void)caseAngleWithOppositeSide:(Corner *)s andAdjacentSide:(Corner *)a lastCorner:(Corner *)c;
- (void)caseThreeSides;
@end

#pragma mark - Implementation & Initialization 

@implementation Triangle
@synthesize cornerA, cornerB, cornerC, area, resultsString, delegate;
@synthesize widthType = _widthType;

- (id)initWithDelegate:(id<KTTriangleDelegate>)d {
    if ((self = [super init])) {
        cornerA = [[Corner alloc] initWithName:@"A"];
        cornerB = [[Corner alloc] initWithName:@"B"];
        cornerC = [[Corner alloc] initWithName:@"C"];
        resultsString = [[NSMutableString alloc] init];
        [resultsString setString:@"Solution\n"];
        self.delegate = d;
        area = 0;
    }
    
    return self;
}

- (id)init {
    return [self initWithDelegate:nil];
}

#pragma mark - Width/Height + Text

- (KTTriangleExcessWidthTypes)widthType {
    if(!_widthType)
        [self enclosingRect];
    return _widthType;
}

- (CGRect)enclosingRect {
    CGFloat height = 0.0f;
    CGFloat width = self.cornerB.side;
    
    // The tip of the triangle is between A and C
    if( self.cornerA.angle <= 90 && self.cornerC.angle <= 90 ) 
    {
        height = self.cornerA.side * sinf(self.cornerC.angleInRadians);
        self.widthType = KTTriangleExcessWidthTypeNone;
    }
    // The tip is outside of the triangle and to the left
    else if( self.cornerA.angle > 90 ) 
    {
        float sin = sinf(2*M_PI - self.cornerA.angleInRadians);
        if( sin < 0 ) sin *= -1;
        height = self.cornerC.side * sin;
        width = sqrtf(powf(self.cornerA.side, 2) - powf(height, 2));
        self.widthType = KTTriangleExcessWidthTypeLeft;
    }
    // The tip is outside of the triangle and to the right
    else if( self.cornerC.angle > 90 ) 
    {
        float sin = sinf(2*M_PI - self.cornerC.angleInRadians);
        if( sin < 0 ) sin *= -1;
        height = self.cornerA.side * sin;
        width = sqrtf(powf(self.cornerC.side, 2) - powf(height, 2));
        self.widthType = KTTriangleExcessWidthTypeRight;
    }
    
    return CGRectMake(0, 0, width, height);
}

- (NSArray *)cornerTextValues {
    return [NSArray arrayWithObjects:self.cornerA.name, self.cornerB.name, self.cornerC.name, nil];
}

#pragma mark -
#pragma mark Conversions

- (float)angleInDegreesToRadians:(float)a {
    return ((a * M_PI) / 180);
}

- (float)angleInRadiansToDegrees:(float)a {
    return ((a * 180) / M_PI);
}

#pragma mark -
#pragma mark Calculations

- (float)calculateSideFromItsAngle:(float)a usingSideWithAngle:(Corner *)s2 {
    return (sinf(a) * (s2.side/sinf(s2.angleInRadians)));
}

- (float)calculateSideFromOwnAngle:(float)a usingFirstSide:(float)s1 second:(float)s2 {
    float result = (powf(s1, 2) + powf(s2, 2) - 2 * s1 * s2 * cosf(a));
    return sqrtf(result);
}

- (float)calculateLastAngleFromFirstAngle:(float)angle1 secondAngle:(float)angle2 {
    float result = 180 - angle1 - angle2;
    
    if (result == 0) return 0;
    
    return result;
}

- (float)calculateAngleFromItsSide:(float)s usingSideWithAngle:(Corner *)sa {
    float insides = (s * (sinf(sa.angleInRadians)/sa.side));
    float result = asinf(insides);
    return [self angleInRadiansToDegrees:result];
}

- (float)calculateAngleFromItsSide:(float)ownSide usingFirstSide:(float)s1 second:(float)s2 {
    float upper = (powf(s1, 2) + powf(s2, 2) - powf(ownSide, 2));
    float under = (2 * s1 * s2);
    float result = acosf((upper / under));
    return [self angleInRadiansToDegrees:result];
}


- (void)areaForCompleteTriangle:(Triangle *)t {
    area = (0.5 * cornerB.side * cornerC.side * sinf(cornerA.angleInRadians));
}

- (float)areaForFirstSide:(float)s1 second:(float)s2 andAngleInRadians:(float)a {
    return (0.5 * s1 * s2 * sinf(a));
}

- (BOOL)knownAngle:(float)a isLessThan:(float)degree {
    if (a < degree)
        return YES;
    else
        return NO;
}

- (BOOL)knownAngle:(float)a isBiggerThanOrEqualTo:(float)degree {
    if (a >= degree)
        return YES;
    else
        return NO;
}

#pragma mark -
#pragma mark Cases

- (void)caseAngle:(Corner *)a1 withSide:(Corner *)s andAngle:(Corner *)a2 {
    s.angle = [self calculateLastAngleFromFirstAngle:a1.angle secondAngle:a2.angle];
    a1.side = [self calculateSideFromItsAngle:a1.angleInRadians usingSideWithAngle:s];
    a2.side = [self calculateSideFromItsAngle:a2.angleInRadians usingSideWithAngle:s];
    [resultsString appendFormat:@"%@: %f\n", s.name, s.angle];
    [resultsString appendFormat:@"%@: %f\n", [a1.name lowercaseString], a1.side];
    [resultsString appendFormat:@"%@: %f\n", [a2.name lowercaseString], a2.side];
    [self appendAreaToResults];
}

- (void)caseSide:(Corner *)s1 withIncludedAngle:(Corner *)a andSide:(Corner *)s2 {
    a.side = [self calculateSideFromOwnAngle:a.angleInRadians usingFirstSide:s1.side second:s2.side];
    s1.angle = [self calculateAngleFromItsSide:s1.side usingSideWithAngle:a];
    s2.angle = [self calculateLastAngleFromFirstAngle:a.angle secondAngle:s1.angle];
    [resultsString appendFormat:@"%@: %f\n", [a.name lowercaseString], a.side];
    [resultsString appendFormat:@"%@: %f\n", s1.name, s1.angle];
    [resultsString appendFormat:@"%@: %f\n", s2.name, s2.angle];
    [self appendAreaToResults];
}

- (void)caseAngleWithOppositeSide:(Corner *)s andAdjacentSide:(Corner *)a lastCorner:(Corner *)c {
    a.angle = [self calculateAngleFromItsSide:a.side usingSideWithAngle:s];
    c.angle = [self calculateLastAngleFromFirstAngle:s.angle secondAngle:a.angle];
    c.side = [self calculateSideFromItsAngle:c.angleInRadians usingSideWithAngle:s];
    [resultsString appendFormat:@"%@: %f\n", [c.name lowercaseString], c.side];
    [resultsString appendFormat:@"%@: %f\n", c.name, c.angle];
    [resultsString appendFormat:@"%@: %f\n", a.name, a.angle];
    [self appendAreaToResults];
    
    if ([self knownAngle:s.angle isLessThan:90]) {
        
        if (a.side > s.side) {
            float triangleHeight = a.side * sinf(s.angleInRadians);
            if (s.side < triangleHeight) {
                [self noSolutionReason:nil informDelegateAndNotify:YES];
            } else if (s.side > triangleHeight) {
                float alternateAngle1 = 180 - a.angle;
                float alternateAngle2 = [self calculateLastAngleFromFirstAngle:s.angle secondAngle:alternateAngle1];
                float alternateSide = [self calculateSideFromItsAngle:[self angleInDegreesToRadians:alternateAngle2] 
                                                   usingSideWithAngle:s];
                float alternateArea = [self areaForFirstSide:s.side second:alternateSide 
                                           andAngleInRadians:[self angleInDegreesToRadians:alternateAngle1]];
                // Make a delegate method that informs our view, that we have two solutions, then pass the values to let the view store and keep track of them.
                [resultsString appendString:@"\nSecond Solution\n"];
                [resultsString appendFormat:@"%@: %f\n", [c.name lowercaseString], alternateSide];
                [resultsString appendFormat:@"%@: %f\n", c.name, alternateAngle2];
                [resultsString appendFormat:@"%@: %f\n", a.name, alternateAngle1];
                [resultsString appendFormat:@"Area: %f\n", alternateArea];
            }
        }
    } else if ([self knownAngle:s.angle isBiggerThanOrEqualTo:90]) {
        if (a.side > s.side) {
            [self noSolutionReason:nil informDelegateAndNotify:YES];
        }
    }
}

- (void)caseThreeSides {
    cornerA.angle = [self calculateAngleFromItsSide:cornerA.side usingFirstSide:cornerB.side second:cornerC.side];
    cornerB.angle = [self calculateAngleFromItsSide:cornerB.side usingSideWithAngle:cornerA];
    cornerC.angle = [self calculateLastAngleFromFirstAngle:cornerA.angle secondAngle:cornerB.angle];
    [resultsString appendFormat:@"%@: %f\n", cornerA.name, cornerA.angle];
    [resultsString appendFormat:@"%@: %f\n", cornerB.name, cornerB.angle];
    [resultsString appendFormat:@"%@: %f\n", cornerC.name, cornerC.angle];
    [self appendAreaToResults];
}

#pragma mark -
#pragma mark Triangle computation algorithm

- (void)computeTriangleNumberOfValues:(int)v {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        switch(v) {
            default:
            case 0:
            case 1:
            case 2: return; break;
            case 3:
            case 4:
            case 5:
            case 6:
                if (cornerA.side > 0) {
                    
                    if (cornerB.side > 0) {
                        
                        if (cornerC.side > 0) {
                            [self caseThreeSides];
                        } else if (cornerC.angle > 0) {
                            [self caseSide:cornerA withIncludedAngle:cornerC andSide:cornerB];
                        } else if (cornerA.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerA andAdjacentSide:cornerB lastCorner:cornerC];
                        } else if (cornerB.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerB andAdjacentSide:cornerA lastCorner:cornerC];
                        }
                        
                    } else if (cornerB.angle > 0 && cornerC.angle > 0) {
                        [self caseAngle:cornerB withSide:cornerA andAngle:cornerC];
                        
                    } else if (cornerC.side > 0) {
                        if (cornerA.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerA andAdjacentSide:cornerC lastCorner:cornerB];
                        } else if (cornerB.angle > 0) {
                            [self caseSide:cornerA withIncludedAngle:cornerB andSide:cornerC];
                        } else if (cornerC.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerC andAdjacentSide:cornerA lastCorner:cornerB];
                        }
                    }
                    
                } else if (cornerB.side > 0) {
                    
                    if (cornerA.angle > 0 && cornerC.angle > 0) {
                        [self caseAngle:cornerA withSide:cornerB andAngle:cornerC];
                    } else if (cornerA.side > 0 && cornerB.angle > 0) {
                        [self caseAngleWithOppositeSide:cornerB andAdjacentSide:cornerA lastCorner:cornerC];
                    } else if (cornerC.side > 0) {
                        if (cornerA.angle > 0) {
                            [self caseSide:cornerB withIncludedAngle:cornerA andSide:cornerC];
                        } else if (cornerB.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerB andAdjacentSide:cornerC lastCorner:cornerA];
                        } else if (cornerC.angle > 0) {
                            [self caseAngleWithOppositeSide:cornerC andAdjacentSide:cornerB lastCorner:cornerA];
                        }
                    } 
                    
                } else if (cornerC.side > 0) {
                    
                    if (cornerC.angle) {
                        if (cornerA.side > 0) {
                            [self caseAngleWithOppositeSide:cornerC andAdjacentSide:cornerA lastCorner:cornerB];
                        } else if (cornerB.side > 0) {
                          [self caseAngleWithOppositeSide:cornerC andAdjacentSide:cornerB lastCorner:cornerA];
                        }
                    } else if (cornerA.angle > 0 && cornerB.angle > 0) {
                        [self caseAngle:cornerA withSide:cornerC andAngle:cornerB];
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self noSolutionReason:@"Couldn't compute a triangle, there's not enough information.\nDid you remember to enter at least one side?"informDelegateAndNotify:YES];
                        // Make sure we return, so we don't accidentally inform our delegate, that we did compute a triangle.
                    }); return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // At the very end, inform our delegate.
                    [self.delegate triangleDidComputeTriangle:self];
                    NSNotification *n = [NSNotification notificationWithName:TriangleDidComputeTriangleNotification object:self];
                    [[NSNotificationCenter defaultCenter] postNotification:n];
                }); break;
        }
    });
}

#pragma mark -
#pragma mark Results string manipulation

- (void)clearResults {
    [resultsString setString:@"Solution\n"];
}

- (void)noSolutionReason:(NSString *)reason informDelegateAndNotify:(BOOL)notify {
    [self clearResults];
    [resultsString setString:@"There was no solution to this triangle.\n"];
    if (reason) {
        [resultsString appendString:reason];
    }
    
    if( notify ) {
        [self.delegate triangleDidFailToComputeTriangle:self];
        NSNotification *n = [NSNotification notificationWithName:TriangleDidFailToComputeTriangleNotification
                                                          object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
}

- (void)appendAreaToResults {
    [self areaForCompleteTriangle:self];
    [resultsString appendFormat:@"Area: %f\n", area];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [cornerA release];
    [cornerB release];
    [cornerC release];
    
    [resultsString release];
    
    [super dealloc];
}

@end
