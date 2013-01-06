//
//  GraphView.m
//  GraphCalculator
//
//  Created by Fred Gagnepain on 2012-12-29.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize dataSource = _dataSource;

#define DEFAULT_SCALE 50


////////////////////////////////////
// Property accessors
//
- (CGFloat)scale {
    
    // Set the scale to the default scale if none already
    if (!_scale) _scale = DEFAULT_SCALE;
    
    return _scale;
}

- (void)setScale:(CGFloat)scale {
    
    // Do nothing if the scale hasn't changed
    if (_scale == scale) return;
    
    _scale = scale;
    
    // Ask the delegate to save the scale
    [self.dataSource saveUserPreferencesScale:self.scale];
    
    // Redraw whenever the scale is changed
    [self setNeedsDisplay];
}

- (void)setOrigin:(CGPoint)origin {
    
    // Do nothing is the axis origin hasn't changed
    if (_origin.x == origin.x && _origin.y == origin.y) return;
    
    _origin = origin;
    
    // Ask the delegate to save the origin
    [self.dataSource saveUserPreferencesOriginX:self.origin.x
                                     andOriginY:self.origin.y];
    
    // Redraw whenever the axis origin is changed
    [self setNeedsDisplay];
}

- (CGPoint)origin {
    
    // Set it to the middle of the graphBounds, if if the current origin is (0,0)
    if (!_origin.x && !_origin.y) {
        _origin.x = (self.bounds.origin.x + self.bounds.size.width) / 2;
        _origin.y = (self.bounds.origin.y + self.bounds.size.height) / 2;
    }
    return _origin;
}

////////////////////////////////////
// Setup
//
- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}

////////////////////////////////////
// Gestures Handlers
//
- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        // adjust our scale
        self.scale *= gesture.scale;
        // reset gestures scale to 1 (so future changes are incremental, not cumulative)
        gesture.scale = 1;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        CGPoint translation = [gesture translationInView:self];

        CGPoint newOrigin;
        newOrigin.x = self.origin.x + translation.x;
        newOrigin.y = self.origin.y + translation.y;
        
        self.origin = newOrigin;
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationOfTouch:0 inView:self];
    }
}


////////////////////////////////////
// Drawing and helpers
//
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    // Draw the X and Y axis
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];
    
    // Initialize drawing
    CGContextBeginPath(context);
    
    // Use the HD factor
    float increment = 1 / self.contentScaleFactor;
    
    // Iterate through the X-Axis
    for (float x = self.bounds.origin.x; x < self.bounds.origin.x + self.bounds.size.width; x += increment) {
        // Convert the x value to the graph coordinate space
        float graphX = [self convertXValueToGraphCoordinateSpace:x];
        // query the y value
        float graphY = [self.dataSource computeYAxisValueFor:graphX];
        // Convert the y value back to the view coordinate space
        float y = [self convertYValueToViewCoordinateSpace:graphY];
        
        // Plot the point
        CGFloat plotX = x;
        CGFloat plotY = y;
        
        if (x == self.bounds.origin.x) {
            CGContextMoveToPoint(context, plotX, plotY);
        }
        CGContextAddLineToPoint(context, plotX, plotY);
    }
    
    // Finish drawing
    CGContextStrokePath(context);
}

- (float)convertXValueToGraphCoordinateSpace:(float)xValue
{
    return (xValue - self.origin.x) / self.scale; //TODO add the scale factor
}

- (float)convertYValueToViewCoordinateSpace:(float)yValue
{
    if (yValue > 0) {
        return self.origin.y - (yValue * self.scale);
    }
    else {
        return self.origin.y + (-yValue * self.scale);
    }
}

@end
