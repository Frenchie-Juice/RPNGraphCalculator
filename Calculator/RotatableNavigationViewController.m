//
//  RotatableNavigationViewController.m
//  GraphPopoverCalculator
//
//  Created by Fred Gagnepain on 2013-01-06.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import "RotatableNavigationViewController.h"

@interface RotatableNavigationViewController ()

@end

@implementation RotatableNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate;
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[self topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

@end
