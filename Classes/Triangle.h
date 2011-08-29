//
//  Triangle.h
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
@end

static NSString *TriangleDidComputeTriangleNotification = @"TriangleDidComputeTriangleNotification";
static NSString *TriangleDidFailToComputeTriangleNotification = @"TriangleDidFailToComputeTriangleNotification";

@protocol KTTriangleDelegate;    

typedef enum {
    KTTriangleExcessWidthTypeLeft,
    KTTriangleExcessWidthTypeNone,
    KTTriangleExcessWidthTypeRight
} KTTriangleExcessWidthTypes;

@interface Triangle : NSObject {

}

@property (retain) Corner *cornerA;
@property (retain) Corner *cornerB;
@property (retain) Corner *cornerC;
@property (assign) float area;

@property (nonatomic, assign) KTTriangleExcessWidthTypes widthType;

@property (readonly, copy) NSMutableString *resultsString;
@property (assign) id <KTTriangleDelegate> delegate;

- (id)initWithDelegate:(id <KTTriangleDelegate>)delegate;
- (void)computeTriangleNumberOfValues:(int)v;
- (void)clearResults;

- (CGRect)enclosingRect;
- (NSArray *)cornerTextValues;
@end

@protocol KTTriangleDelegate <NSObject>
@required
- (void)triangleDidComputeTriangle:(id)sender;
- (void)triangleDidFailToComputeTriangle:(id)sender;
@optional
- (void)triangleDidHaveSecondSolution:(id)sender;
@end