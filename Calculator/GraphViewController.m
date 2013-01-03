//
//  GraphViewController.m
//  GraphCalculator
//
//  Created by Fred Gagnepain on 2012-12-29.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController () <GraphViewDataSource>
@property (weak, nonatomic) IBOutlet id <GraphViewDataSource> delegate;
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize delegate = _delegate;
@synthesize graphView = _graphView;

- (double)computeYAxisValueFor:(double)XAxisValue
{
    return [self.delegate computeYAxisValueFor:XAxisValue];
}

- (void) setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    self.graphView.dataSource = self;
    
    // enable pinch gestures in the GraphView using its pinch: handler
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView
                                                                                   action:@selector(pinch:)]];
    // recognize a pan gesture in the GraphView using its pan: handler
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView
                                                                                 action:@selector(pan:)]];
    
    // enable triple tap gesture in the GraphView using tripleTap: handler
    UITapGestureRecognizer *tapGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self.graphView
                                            action:@selector(tripleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapGestureRecognizer];
}


@end
