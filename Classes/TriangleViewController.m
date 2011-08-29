//
//  TriangleViewController.m
//  TriangleSolver
//
//  Created by Kasper Hansen on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TriangleViewController.h"
#import "Triangle.h"

@implementation TriangleViewController 
@synthesize triangle;

- (id)init {
    if (self = [super initWithNibName:nil bundle:nil]) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)dealloc {
    [triangle release];
    
    [super dealloc];
}

- (void)patchResponderChain {
    NSResponder *nextResponder = [self.view nextResponder];
    [self.view setNextResponder:self];
    [self setNextResponder:nextResponder];
}

- (void)awakeFromNib {
    [self patchResponderChain];
}

- (void)setTriangle:(Triangle *)theTriangle {
    [triangle release];
    triangle = [theTriangle retain];
    [(TriView *)self.view generateDrawingInformation];
}

#pragma mark - KTTriView Data Source Methods

- (NSDictionary *)triangleExcessWidthDictionary {
    NSNumber *excessWidth = [NSNumber numberWithFloat:([self widthForTriangle] - self.triangle.cornerB.side)];
    
    NSString *excessWidthType = @"ExcessWidthTypeNone";
    
    if( self.triangle.widthType == KTTriangleExcessWidthTypeLeft )
        excessWidthType = @"ExcessWidthTowardsA";
    else if( self.triangle.widthType == KTTriangleExcessWidthTypeRight )
        excessWidthType = @"ExcessWidthTowardsC";
    
    return [NSDictionary dictionaryWithObjectsAndKeys:excessWidth, excessWidthType, nil];
}

- (float)heightForTriangle {
    CGRect triRect = [self.triangle enclosingRect];
    return triRect.size.height;
}

- (float)widthForTriangle {
    CGRect triRect = [self.triangle enclosingRect];
    return triRect.size.width;
}

- (float)lengthOfSideA {
    return self.triangle.cornerA.side;
}

- (float)lengthOfSideB {
    return self.triangle.cornerB.side;
}

- (NSArray *)textValuesArray {
    return [self.triangle cornerTextValues];
}

@end
