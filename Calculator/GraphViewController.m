//
//  GraphViewController.m
//  GraphCalculator
//
//  Created by Fred Gagnepain on 2012-12-29.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "ProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, ProgramsTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButton;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popoverController;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize titleButton = _titleButton;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize popoverController = popoverController;
@synthesize program = _program;

#define FAVORITES_KEY @"GraphViewController.Favorites"


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

// Puts the splitViewBarButton in our toolbar (and/or removes the old one).
// Must be called when our splitViewBarButtonItem property changes
//  (and also after our view has been loaded from the storyboard (viewDidLoad)).

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) {
        splitViewBarButtonItem.target = self;
        splitViewBarButtonItem.action = @selector(barButtonPressed);
        
        [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    }
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;

}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

// viewDidLoad is callled after this view controller has been fully instantiated
//  and its outlets have all been hooked up.

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
    
    // Instantiate the UIPopoverController
    // but only if we are in an iPad
    if (self.splitViewController) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:
                             (self.splitViewController.viewControllers)[0]];
    }
}

- (void)barButtonPressed
{
    [self.popoverController presentPopoverFromBarButtonItem:self.splitViewBarButtonItem
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:NO];
}

- (IBAction)addToFavorites:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if(!favorites)favorites = [NSMutableArray array];
    
    [favorites addObject:self.program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) {
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

#pragma mark - ProgramsTableViewControllerDelegate
- (void)programsTableViewController:(ProgramsTableViewController *)sender choseProgram:(id)program
{
    self.program = program;
}

#pragma mark - UISplitViewControllerDelegate
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return YES; //UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    // Tell the detail view to put this button in the toolbar
    self.splitViewBarButtonItem = barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Tell the detail view to put the button away
    self.splitViewBarButtonItem = nil;
}

#pragma mark - GraphViewDataSource
- (double)computeYAxisValueFor:(double)xAxisValue
{
    return [CalculatorBrain runProgram:self.program
                   usingVariableValues:@{@"x": @(xAxisValue)}];
}

- (void) reloadUserPreferences
{
    NSString *currentProgram = [CalculatorBrain descriptionOfProgram:self.program];
    
    // Retrieve the scale property if saved
    float prefScale = [[NSUserDefaults standardUserDefaults] floatForKey:[@"scale." stringByAppendingString:currentProgram]];
    
    // Retrieve the origin X and Y values
    float prefOrigX = [[NSUserDefaults standardUserDefaults] floatForKey:[@"x." stringByAppendingString:currentProgram]];
    float prefOrigY = [[NSUserDefaults standardUserDefaults] floatForKey:[@"y." stringByAppendingString:currentProgram]];
    
    // Assign the prefered scale if it was saved
    if (prefScale) self.graphView.scale = prefScale;
    
    // Assign the prefered origin point if it was saved
    if (prefOrigX && prefOrigY) {
        CGPoint prefOrigin;
        
        prefOrigin.x = prefOrigX;
        prefOrigin.y = prefOrigY;
        
        self.graphView.origin = prefOrigin;
    }
}

- (void) saveUserPreferencesScale:(float)aScale
{
    // Save the scale in the user defaults
    [[NSUserDefaults standardUserDefaults] setFloat:aScale
                                             forKey:[@"scale." stringByAppendingString:
                                                     [CalculatorBrain descriptionOfProgram:self.program]]];
    // Force refresh of the user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveUserPreferencesOriginX:(float)xOrigin andOriginY:(float)yOrigin
{
    NSString *currentProgram = [CalculatorBrain descriptionOfProgram:self.program];
    
    // Save the X origin in the user defaults
    [[NSUserDefaults standardUserDefaults] setFloat:xOrigin
                                             forKey:[@"x." stringByAppendingString:currentProgram]];
    // Save the Y origin in the user defaults
    [[NSUserDefaults standardUserDefaults] setFloat:yOrigin
                                             forKey:[@"y." stringByAppendingString:currentProgram]];
    // Force refresh of the user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}


///////////////////////////////////////////////
// GraphView refresh
//
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
    
    // Reload user preferences since on iPhone, it hasn't been loaded yet
    [self reloadUserPreferences];
}

- (void)setProgram:(id)program
{
    _program = program;
    
    // Refresh the display when the program is changed
    [self refreshGraphView];
}

- (void)refreshGraphView
{
    // Print the program where it's visible
    if (self.splitViewController) {
        // In an iPad, show the program in the button inside the toolbar
        self.titleButton.title = [NSString stringWithFormat:@"y = %@",
                                  [CalculatorBrain descriptionOfProgram:self.program]];
    }
    else {
        // in an iPhone, show the program in the ViewControler title bar
        self.title = [NSString stringWithFormat:@"y = %@",
                      [CalculatorBrain descriptionOfProgram:self.program]];
    }
    
    // Reload user preferences
    [self reloadUserPreferences];
    
    // Refresh the Graph View
    [self.graphView setNeedsDisplay];
}




@end
