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
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> delegate;
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
    
    // TODO: put the gesture recognizers here
}


@end
