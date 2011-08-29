//
//  TriangleSolverAppDelegate.h
//  TriangleSolver
//
//  Created by Kasper Timm on 25/08/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//
#import "Triangle.h"
@class TriangleViewController;

@interface TriangleSolverAppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, KTTriangleDelegate> {

    NSWindow *window;
    Triangle *triangle;
    IBOutlet NSForm *sidesForm;
    IBOutlet NSForm *anglesForm;
    IBOutlet NSTextView *resultsTextView;
    IBOutlet TriangleViewController *triView;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) Triangle *triangle;
@property (retain) IBOutlet NSForm *sidesForm;
@property (retain) IBOutlet NSForm *anglesForm;
@property (retain) IBOutlet NSTextView *resultsTextView;
@property (retain) IBOutlet TriangleViewController *triView;

- (IBAction)clearEverything:(id)sender;
- (IBAction)solveTriangle:(id)sender;
@end

