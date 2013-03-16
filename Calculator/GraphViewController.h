//
//  GraphViewController.h
//  RPNCalculator
//
//  Created by Fred Gagnepain on 2012-12-29.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) id program;

@end
