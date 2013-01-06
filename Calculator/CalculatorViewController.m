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
@property (strong, nonatomic) NSDictionary *variableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize programDisplay = _programDisplay;
@synthesize resultDisplay = _resultDisplay;

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
    }
    
//    self.historyDisplay.text = [self.historyDisplay.text stringByAppendingString:digit];
    
    // Hides the "=" sign
    self.resultDisplay.text = @"";

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
    // Shows the "=" sign after an operation
    self.resultDisplay.text = @"=";
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
    [self updateDisplay];
    
    // Clear the variables array
    self.variableValues = nil;
    
    // Hide the "=" sign
    self.resultDisplay.text = @"";
    
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

// Removed Test buttons
//- (IBAction)testButtonsPressed:(UIButton *)sender {
//    if (self.userIsInTheMiddleOfEnteringANumber) {
//        [self enterPressed];
//        self.userIsInTheMiddleOfEnteringANumber = NO;
//    }
//
//    NSString *testName = [sender currentTitle];
//    if ([testName isEqualToString:@"Test 1"]) {
//        self.testVariableValues = @{@"x": @3.0,
//                                    @"y": @4.0};
//    } else if ([testName isEqualToString:@"Test 2"]) {
//        self.testVariableValues = @{@"x": @10.0,
//                                    @"y": @100.0};
//    } else if ([testName isEqualToString:@"Test 3"]) {
//        self.testVariableValues = nil;
//    }
//    [self updateDisplay];
//}

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
    // Update the variables display
    //[self updateVariableDisplay];
}

- (void)updateProgramDisplay {
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

//- (void)updateVariableDisplay {
//    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:self.brain.program];
//    NSMutableArray *displayText;
//    for (NSString *variableKey in variablesUsed) {
//        if (displayText == nil) {
//            displayText = [[NSMutableArray alloc] initWithCapacity:variablesUsed.count];
//        }
//        [displayText addObject: [NSString stringWithFormat:@"%@=%g", variableKey, [[self.testVariableValues valueForKey:variableKey] doubleValue]]];
//    }
//    self.variableDisplay.text = [displayText componentsJoinedByString:@" "];
//}


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


// Test programs

    // Program 1
//    [self.brain pushVariable:@"x"];
//    [self.brain pushVariable:@"x"];
//    [self.brain pushOperation:@"*"];
//    [self.brain pushVariable:@"y"];
//    [self.brain pushVariable:@"y"];
//    [self.brain pushOperation:@"*"];
//    [self.brain pushOperation:@"+"];
//    [self.brain pushOperation:@"√"];

    // Program 2
//    [self.brain pushVariable:@"x"];
//    [self.brain pushVariable:@"y"];
//    [self.brain pushOperand:5.0];
//    [self.brain pushOperation:@"+"];
//    [self.brain pushOperation:@"-"];

    // Program 3
//    [self.brain pushOperand:5.0];
//    [self.brain pushOperand:6.0];
//    [self.brain pushOperand:9.0];
//    [self.brain pushOperation:@"÷"];
//    [self.brain pushOperation:@"÷"];

    // Program 4
//    [self.brain pushOperand:5.0];
//    [self.brain pushOperand:6.0];
//    [self.brain pushOperation:@"÷"];
//    [self.brain pushOperand:9.0];
//    [self.brain pushOperation:@"÷"];


@end
