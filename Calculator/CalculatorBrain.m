//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Fred Gagnepain on 2012-12-08.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

static NSSet *noOperandOperations;
static NSSet *singleOperandOperations;
static NSSet *twoOperandOperations;
static NSSet *variables;

-(NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

-(id)program
{
    return [self.programStack copy];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = @(operand);
    [self.programStack addObject:operandObject];
    
}

- (void)pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];    
    return [CalculatorBrain runProgram:self.program];
}

- (void)clearAllOperations
{
    [self.programStack removeAllObjects];
}

-(void)removeLastOperationFromProgram {
    // Remove last object from the stack
    id topOfStack = [self.programStack lastObject];
    if (topOfStack) [self.programStack removeLastObject];
}


+ (void)initialize {
    noOperandOperations = [NSSet setWithObjects:@"π",@"e", nil];
    singleOperandOperations = [NSSet setWithObjects:@"sin",@"cos",@"log",@"√",@"+/-", nil];
    twoOperandOperations = [NSSet setWithObjects:@"+",@"-",@"*",@"÷", nil];
    variables = [NSSet setWithObjects:@"x", nil];
    // previous version had 2 variables
    //variables = [NSSet setWithObjects:@"x",@"y", nil];
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]){
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([@"*" isEqualToString:operation]){
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if ([operation isEqualToString:@"-"]){
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        }
        else if ([operation isEqualToString:@"÷"]){
            double divisor = [self popOperandOffStack:stack];
            if(divisor) result = [self popOperandOffStack:stack] / divisor;
        }
        else if ([operation isEqualToString:@"π"]){
            result = M_PI;
        }
        else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"√"]){
            result = sqrt([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"log"]){
            result = log([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"e"]){
            result = exp([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"+/-"]){
            result = [self popOperandOffStack:stack] * (-1);
        }
        
    }
    
    return result;
    
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (double)runProgram:(id)program
  usingVariableValues:(NSDictionary *)variableValues
{
    // Ensure the program is an NSArray
    if (![program isKindOfClass:[NSArray class]]) return 0;
    
    NSMutableArray *stack = [program mutableCopy];
    
    // For each item in the program
    for (int i=0; i < [stack count]; i++) {
        id obj = stack[i];
        
        // Check if the item is a variable
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            id value = variableValues[obj];
            // If value is not an NSNumber, set it to 0
            if (![value isKindOfClass:[NSNumber class]]) {
                value = @0;
            }
            // Replace the program variable with a value
            stack[i] = value;
        }
    }
    
    // Start running the program
    return [self popOperandOffStack:stack];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    return [twoOperandOperations containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    return [singleOperandOperations containsObject:operation];
}

+ (BOOL)isNoOperandOperation:(NSString *)operation
{
    return [noOperandOperations containsObject:operation];
}

+ (BOOL)isOperation:(NSString *)operation
{
    return
    [self isNoOperandOperation:operation] ||
    [self isOneOperandOperation:operation]||
    [self isTwoOperandOperation:operation];
}

+ (BOOL)isVariable:(NSString *)variable
{
    return [variables containsObject:variable];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    // Ensure the program is an NSArray
    if (![program isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableSet *variables = [NSMutableSet set];
    
    // For each item in the program, get the variables
    for (id obj in program) {
        // Add variable to the set when we have one
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) {
            [variables addObject:obj];
        }
    }
    
    // Return nil if we don't have variables
    if ([variables count] == 0) return nil;
    else return [variables copy];
}

+ (BOOL)isValidProgram:(id)program {
    // It's valid if it's an NSArray
    return [program isKindOfClass:[NSArray class]];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = @"";
    
    // Check if the program is valid
    if ([program isKindOfClass:[NSArray class]]) {
        NSMutableArray *stack = [program mutableCopy];
        
        description = [self descriptionOfTopOfStack:stack PreviousOperator:@""];
        while ([stack count]!=0) {
            description = [NSString stringWithFormat:@"%@, %@",description,
                                    [self descriptionOfTopOfStack:stack PreviousOperator:@""]];
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
                     PreviousOperator:(NSString *)preOp
{
    NSString *description = @"0";
    
    // Retrieve and remove the object at the top of the stack
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    // If the top of the stack is a NSNumber, return it's value as a NSString
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack stringValue];
    }
    // If it's a NSString, we have to check the type of operation
    else if ([topOfStack isKindOfClass:[NSString class]]){
        // Two operands operation
        if ([self isTwoOperandOperation:topOfStack]) {
            NSString *rexpr = [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack];
            // Use recursion to get the rest of the stack
            description = [NSString stringWithFormat:@"%@ %@ %@", [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack], topOfStack, rexpr];
            
            // Check if we need to wrap the output with parenthesis
            NSSet *additionSubstraction = [NSSet setWithObjects:@"+", @"-", nil];
            BOOL requireParenthesis = [preOp isEqualToString:@"÷"]||
            ([preOp isEqualToString:@"*"]&&[additionSubstraction containsObject:topOfStack])||
            ([preOp isEqualToString:@"-"]&&[additionSubstraction containsObject:topOfStack]);
            // Apply the formatting
            if (requireParenthesis) description = [NSString stringWithFormat:@"(%@)",description];
        }
        // Single operand operator
        else if ([self isOneOperandOperation:topOfStack]) {
            description = [NSString stringWithFormat:@"%@(%@)",topOfStack, [self descriptionOfTopOfStack:stack PreviousOperator:topOfStack]];
        }
        // No operand operation or variable
        else{
            description = topOfStack;
        }
    }
    
    return description;
}
@end
