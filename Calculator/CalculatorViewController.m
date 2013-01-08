//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Fred Gagnepain on 2012-12-08.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (strong, nonatomic) NSMutableDictionary *variableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize programDisplay = _programDisplay;
@synthesize resultDisplay = _resultDisplay;
@synthesize xVariableDisplay = _xVariableDisplay;
@synthesize yVariableDisplay = _yVariableDisplay;

@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variableValues = _variableValues;

- (CalculatorBrain *)brain
{
    if(!_brain){
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (BOOL)isDecimalNumber:(NSString *)display
{
    NSRange decPointRange = [display rangeOfString:@"."];
    return (decPointRange.location != NSNotFound);
}

/////////////////////////////////////////////
// UI Button handlers
//

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // check if '.' has already been pressed
        if ([digit isEqualToString:@"."])
            if ([self isDecimalNumber:self.display.text])
                return;

        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        
        // Hides the "=" sign
        self.resultDisplay.text = @"";
    }
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    [self updateProgramDisplay];
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    [self updateDisplay];
}

- (IBAction)plusMinusPressed:(UIButton *)sender
{
    // TODO: check if the if/else is still necessary
    if (self.userIsInTheMiddleOfEnteringANumber) {
        double tempValue = [self.display.text doubleValue] * (-1);
        self.display.text = [NSString stringWithFormat:@"%g", tempValue];
    }
    else {
        [self operationPressed:sender];
    }
}

- (IBAction)clearPressed:(UIButton *)sender {
    // Clear the brain
    [self.brain clearAllOperations];

    // Clear the variables array
    self.variableValues = nil;
    
    // Refresh the display
    [self updateDisplay];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // interpret "undo" as a backspace and remove last digit
        NSUInteger length = [self.display.text length];
        self.display.text = [self.display.text substringToIndex:(length-1)];
    } else {
        [self.brain removeLastOperationFromProgram];
        [self updateDisplay];
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    
    [self.brain pushVariable:[sender currentTitle]];
    [self updateProgramDisplay];
    //[self updateVariableDisplay];
}

- (IBAction)setVariableValuePressed:(UIButton *)sender
{
    // Lazy instanciate the variable values if
    // none are entered so far
    if(!self.variableValues){
        self.variableValues = [@{@"x": @0.0,
                                 @"y": @0.0} mutableCopy];
    }
    
    // Check which variable was set
    NSString *pressedVar = [[sender currentTitle] substringToIndex:1];
    
    // Get the variable value from screen
    double varValue = [self.display.text doubleValue];
    
    // Replace the variable value inside the Dictionary
    self.variableValues[pressedVar] = [NSNumber numberWithDouble:varValue];
    
    // Make sure next digit resets the display
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    // Update the display
    [self updateDisplay];
}

- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (IBAction)graphPressed {
    GraphViewController *gvc = [self splitViewGraphViewController];
    if (gvc) {
        //[gvc setTitle:self.programDisplay.text];
        [gvc setProgram:self.brain.program];
    }
    else {
        // Call the segue
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Define a proper size for the popover view
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 420.0);
}


/////////////////////////////////////////////
// Display Refresh
//

- (void)updateDisplay {
    // Run the program with parameters if needed
    double result = [CalculatorBrain runProgram:self.brain.program
                            usingVariableValues:self.variableValues];
    // Update main display with the result of the program
    self.display.text = [NSString stringWithFormat:@"%g", result];
    // Update the program display
    [self updateProgramDisplay];
    
    // Update the "=" sign after the calculation is done
    if (result) {
        self.resultDisplay.text = @"=";
    } else {
        self.resultDisplay.text = @"";
    }
    
    // Update the variables display
    [self updateVariablesDisplay];
    
}

- (void)updateProgramDisplay {
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)updateVariablesDisplay {
    // Lazy instanciate the variable values if
    // none are entered so far
    if(!self.variableValues){
        self.variableValues = [@{@"x": @0.0,
                                 @"y": @0.0} mutableCopy];
    }
    
    // Display the x variable on screen
    self.xVariableDisplay.text = [NSString stringWithFormat:@"x= %@", self.variableValues[@"x"]];
    // Display the y variable on screen
    self.yVariableDisplay.text = [NSString stringWithFormat:@"y= %@", self.variableValues[@"y"]];
}


- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

// deprecated
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return NO;
//}

/////////////////////////////////////////////
// Prepare the Segue to the Graph View Controller
//
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        //[segue.destinationViewController setTitle:self.programDisplay.text];
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

@end
