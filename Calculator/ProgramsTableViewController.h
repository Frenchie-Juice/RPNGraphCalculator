//
//  ProgramsTableViewController.h
//  RPNCalculator
//
//  Created by Fred Gagnepain on 2013-01-11.
//  Copyright (c) 2013 Fred Gagnepain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgramsTableViewController;

@protocol ProgramsTableViewControllerDelegate <NSObject>
@optional
- (void)programsTableViewController:(ProgramsTableViewController *)sender
                       choseProgram:(id)program;
- (void)programsTableViewController:(ProgramsTableViewController *)sender
                               deletedProgram:(id)program;
@end

@interface ProgramsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *programs; // CalculatorBrain programs
@property (nonatomic, weak) id <ProgramsTableViewControllerDelegate> delegate;
@end
