//
//  TriView.h
//  TriangleSolver
//
//  Created by Kasper Hansen on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KTTriViewDataSource;

@interface TriView : NSView {
    
}

@property (assign) IBOutlet id <KTTriViewDataSource> dataSource;

@property (retain) NSBezierPath *trianglePath;
@property (retain) NSMutableArray *triangleCornerTextArray;

- (void)generateDrawingInformation;

@end

@protocol KTTriViewDataSource

- (NSDictionary *)triangleExcessWidthDictionary;
- (float)widthForTriangle;
- (float)heightForTriangle;
- (float)lengthOfSideA;
- (float)lengthOfSideB;
- (NSArray *)textValuesArray;

@end