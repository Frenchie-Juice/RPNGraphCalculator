//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Fred Gagnepain on 2012-12-08.
//  Copyright (c) 2012 Fred Gagnepain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
@property (readonly) id program;

- (void)pushOperand:(double)operand;
- (void)pushOperation:(NSString *)operation;
- (void)pushVariable:(NSString *)variable;
-(void)removeLastOperationFromProgram;
- (double)performOperation:(NSString *)operation;
- (void)clearAllOperations;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (BOOL)isValidProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
