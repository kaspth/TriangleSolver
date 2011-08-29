//
//  TriangleSolverAppDelegate.m
//  TriangleSolver
//
//  Created by Kasper Timm on 25/08/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "TriangleSolverAppDelegate.h"
#import "TriangleViewController.h"
#import "Triangle.h"

@implementation TriangleSolverAppDelegate

@synthesize window, triangle, sidesForm, anglesForm, resultsTextView, triView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    triangle = [[Triangle alloc] initWithDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:TriangleDidComputeTriangleNotification
                                                      object:nil
                                                       queue:nil 
                                                  usingBlock:^(NSNotification *note) {
                                                      self.triView.triangle = [note object];
                                                      [self.triView.view setNeedsDisplay:YES];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:TriangleDidFailToComputeTriangleNotification 
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.triView.triangle = nil;
                                                      [self.triView.view setNeedsDisplay:YES];
                                                  }];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)solveTriangle:(id)sender {
    NSFormCell *cell;
    int v = 0;
        for (cell in [sidesForm cells]) {
            if (![[cell stringValue] isEqualToString:@""]) {
                v++;
                switch([cell tag]) {
                    case 0: triangle.cornerA.side = [cell floatValue]; break;
                    case 1: triangle.cornerB.side = [cell floatValue]; break;
                    case 2: triangle.cornerC.side = [cell floatValue]; break;
                    default: NSLog(@"No cell with tag: %ld", [cell tag]); break;
                }
            } else {
                switch([cell tag]) {
                    case 0: triangle.cornerA.side = 0; break;
                    case 1: triangle.cornerB.side = 0; break;
                    case 2: triangle.cornerC.side = 0; break;
                }
            }
        }
        for (cell in [anglesForm cells]) {
            if (![[cell stringValue] isEqualToString:@""]) {
                v++;
                switch([cell tag]) {
                    case 0: triangle.cornerA.angle = [cell floatValue]; break;
                    case 1: triangle.cornerB.angle = [cell floatValue]; break;
                    case 2: triangle.cornerC.angle = [cell floatValue]; break;
                    default: NSLog(@"No cell with tag: %ld", [cell tag]); break;
                }
            } else {
                switch([cell tag]) {
                    case 0: triangle.cornerA.angle = 0; break;
                    case 1: triangle.cornerB.angle = 0; break;
                    case 2: triangle.cornerC.angle = 0; break;
                }
            }
        }
        
        [triangle computeTriangleNumberOfValues:v];
}

- (void)triangleDidComputeTriangle:(id)sender {
    [resultsTextView setString:[sender resultsString]];
    [sender clearResults];
}

- (void)triangleDidFailToComputeTriangle:(id)sender {
    [resultsTextView setString:[sender resultsString]];
    [sender clearResults];
}

- (IBAction)clearEverything:(id)sender {
    for (NSFormCell *cell in [sidesForm cells]) {
        [cell setStringValue:@""];
    }
    for (NSFormCell *cell in [anglesForm cells]) {
        [cell setStringValue:@""];
    }
    [triangle release];
    triangle = [[Triangle alloc] initWithDelegate:self];
    self.triView.triangle = nil;
    [resultsTextView setString:@""];
    [window becomeFirstResponder];
}

@end

