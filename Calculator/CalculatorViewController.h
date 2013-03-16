//
//  CalculatorViewController.h
//  RPNCalculator
//
//  Created by Fred Gagnepain on 2012-12-08.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@property (weak, nonatomic) IBOutlet UILabel *resultDisplay;
@property (weak, nonatomic) IBOutlet UILabel *xVariableDisplay;
@property (weak, nonatomic) IBOutlet UILabel *yVariableDisplay;

@end
