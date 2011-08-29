//
//  TriangleViewController.h
//  TriangleSolver
//
//  Created by Kasper Hansen on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TriView.h"
@class Triangle;

@interface TriangleViewController : NSViewController <KTTriViewDataSource>

@property (nonatomic, retain) Triangle *triangle;

@end
