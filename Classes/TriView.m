//
//  TriView.m
//  TriangleSolver
//
//  Created by Kasper Hansen on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TriView.h"
#import "Corner.h"

@implementation TriView
@synthesize dataSource = _dataSource;
@synthesize trianglePath = _trianglePath;
@synthesize triangleCornerTextArray = _triangleCornerTextArray;

#pragma mark - Initialization and destruction

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Drawing

- (void)generateDrawingInformation {
    if( _trianglePath ) {
        [_trianglePath release];
        _trianglePath = nil;
    }
    if( _triangleCornerTextArray ) {
        [_triangleCornerTextArray release];
        _triangleCornerTextArray = nil;
    }
    
    _triangleCornerTextArray = [[NSMutableArray alloc] init];
    
#define PADDING_AROUND_GRAPH 20.0
#define TEXT_PADDING 5.0
    
    CGRect viewBounds = self.bounds;
    CGRect graphRect = NSInsetRect(viewBounds, PADDING_AROUND_GRAPH, PADDING_AROUND_GRAPH);
    
    // Make the graphRect square and centered
    if( graphRect.size.width > graphRect.size.height )
	{
		double sizeDifference = graphRect.size.width - graphRect.size.height;
		graphRect.size.width = graphRect.size.height;
		graphRect.origin.x += (sizeDifference / 2);
	}
	
	if( graphRect.size.height > graphRect.size.width )
	{
		double sizeDifference = graphRect.size.height - graphRect.size.width;
		graphRect.size.height = graphRect.size.width;
		graphRect.origin.y += (sizeDifference / 2);
	}
    
    // Make the triangle centered in our graphRect
    float width = [self.dataSource widthForTriangle];
    float height = [self.dataSource heightForTriangle];
    
    float widthMultiplier = 1.0f;
    float heightMultiplier = 1.0f;
    
    if( width > height ) 
    {
        float aspectRatio = height / width;
        widthMultiplier = graphRect.size.width / width;
        heightMultiplier = widthMultiplier * aspectRatio;
    } 
    else if( width == height )
    {
        widthMultiplier = graphRect.size.width / width;
        heightMultiplier = widthMultiplier;
    }
    else 
    {
        float aspectRatio = width / height;
        heightMultiplier = graphRect.size.height / height;
        widthMultiplier = heightMultiplier * aspectRatio;
    }
    
    // get NSRects for the different quarters of the graph
	CGRect topLeftRect, topRightRect;
	NSDivideRect(viewBounds, &topLeftRect, &topRightRect, (viewBounds.size.width / 2), CGRectMinXEdge );
	CGRect bottomLeftRect, bottomRightRect;
	NSDivideRect(topLeftRect, &topLeftRect, &bottomLeftRect, (viewBounds.size.height / 2), CGRectMinYEdge );
	NSDivideRect(topRightRect, &topRightRect, &bottomRightRect, (viewBounds.size.height / 2), CGRectMinYEdge );
    
    // Set the text attributes to be used for each textual display
	NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSColor whiteColor], NSBackgroundColorAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:12], NSFontAttributeName, nil];
    
    CGPoint currentPosition = CGPointMake(graphRect.origin.x, graphRect.origin.y);
    
    NSDictionary *widthDict = [self.dataSource triangleExcessWidthDictionary];
    
    float excessWidth = [[widthDict valueForKey:@"ExcessWidthTowardsA"] floatValue];
    if( excessWidth > 0 )
        currentPosition.x += excessWidth * widthMultiplier;
    
    NSBezierPath *trianglePath = [NSBezierPath bezierPath];
    [trianglePath moveToPoint:currentPosition];
    CGPoint cornerATextPoint = [trianglePath currentPoint];
    
    CGFloat sideBLength = [self.dataSource lengthOfSideB];
    currentPosition.x += sideBLength * widthMultiplier;
    
    [trianglePath lineToPoint:currentPosition];
    CGPoint cornerCTextPoint = [trianglePath currentPoint];
    
    excessWidth = [[widthDict valueForKey:@"ExcessWidthTowardsC"] floatValue];
    if( excessWidth > 0 )
        currentPosition.x += excessWidth * widthMultiplier;
    else
        currentPosition.x -= sqrtf( powf([self.dataSource lengthOfSideA], 2) - powf(height, 2)) * widthMultiplier;
    
    currentPosition.y += height * heightMultiplier;
    [trianglePath lineToPoint:currentPosition];
    CGPoint cornerBTextPoint = [trianglePath currentPoint];
    
    [trianglePath closePath];
    [trianglePath setLineWidth:1.0];
    
    self.trianglePath = trianglePath;
    
    for( int count = 0; count <= 2; count++) {
        NSPoint textPoint = CGPointZero;
        
        if( count == 0 )
            textPoint = cornerATextPoint;
        else if ( count == 1 )
            textPoint = cornerBTextPoint;
        else
            textPoint = cornerCTextPoint;
        
        // Get the text to be displayed, if it exists, and see how big it is
        NSString *eachText = @"";
        eachText = [[self.dataSource textValuesArray] objectAtIndex:count];
        
        NSSize textSize = [eachText sizeWithAttributes:textAttributes];
        
        // Offset it by TEXTPADDING in direction suitable for whichever quarter of the view it is in
        if( NSPointInRect(textPoint, topLeftRect) )
        {
            textPoint.y -= (textSize.height + TEXT_PADDING);
            textPoint.x -= (textSize.width + TEXT_PADDING);
        }
        else if( NSPointInRect(textPoint, topRightRect) )
        {
            textPoint.y -= (textSize.height + TEXT_PADDING);
            textPoint.x += TEXT_PADDING;
        }
        else if( NSPointInRect(textPoint, bottomLeftRect) )
        {
            textPoint.y += TEXT_PADDING;
            textPoint.x -= (textSize.width + TEXT_PADDING);
        }
        else if( NSPointInRect(textPoint, bottomRightRect) )
        {
            textPoint.y += TEXT_PADDING;
            textPoint.x += TEXT_PADDING;
        }
        
        // Make sure the point isn't outside the view's bounds
        if( textPoint.x < viewBounds.origin.x )
            textPoint.x = viewBounds.origin.x;
        
        if( (textPoint.x + textSize.width) > (viewBounds.origin.x + viewBounds.size.width) )
            textPoint.x = viewBounds.origin.x + viewBounds.size.width - textSize.width;
        
        if( textPoint.y < viewBounds.origin.y )
            textPoint.y = viewBounds.origin.y;
        
        if( (textPoint.y + textSize.height) > (viewBounds.origin.y + viewBounds.size.height) )
            textPoint.y = viewBounds.origin.y + viewBounds.size.height - textSize.height;
        
        // Finally add the details as a dictionary to our array.
        // We include here the textAttributes lest we decide later to e.g. color the texts the same color as the segment fill
        [_triangleCornerTextArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:textPoint.x], @"textPointX", [NSNumber numberWithFloat:textPoint.y], @"textPointY", eachText, @"text", textAttributes, @"textAttributes", nil]];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    CGRect bounds = self.bounds;
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
    
    if( [self inLiveResize] )
        [self generateDrawingInformation];
    
    [[NSColor blackColor] set];
    [self.trianglePath stroke];
    [[NSColor blueColor] set];
    [self.trianglePath fill];
    
    for (int count = 0; count <= 2 ; count++) {
        NSDictionary *eachTextDictionary = [self.triangleCornerTextArray objectAtIndex:count];
		NSPoint textPoint = NSMakePoint( [[eachTextDictionary valueForKey:@"textPointX"] floatValue], [[eachTextDictionary valueForKey:@"textPointY"] floatValue] );
		
		NSDictionary *textAttributes = [eachTextDictionary valueForKey:@"textAttributes"];
		
		NSString *text = [eachTextDictionary valueForKey:@"text"];
		[text drawAtPoint:textPoint withAttributes:textAttributes];
    }
}

#pragma mark - Dragging of View
- (void)mouseDragged:(NSEvent *)theEvent {
    CGRect viewBounds = self.bounds;
    
    NSData *viewData = [self dataWithPDFInsideRect:viewBounds];
    NSPDFImageRep *pdfRep = [NSPDFImageRep imageRepWithData:viewData];
    
    NSImage *viewImage = [[NSImage alloc] initWithSize:viewBounds.size];
    [viewImage addRepresentation:pdfRep];
    
    NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pBoard clearContents];
    [pBoard writeObjects:[NSArray arrayWithObject:viewImage]];
    
    [self dragImage:viewImage at:viewBounds.origin offset:NSZeroSize event:theEvent pasteboard:pBoard source:self slideBack:YES];
    [viewImage release];
}

@end
