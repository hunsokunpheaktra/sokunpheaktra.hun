//
//  CRM4MobileTests.m
//  CRM4MobileTests
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "CRM4MobileTests.h"

@implementation CRM4MobileTests

@synthesize item;

- (void)setUp
{
    [super setUp];
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] initWithCapacity:1];
    [fields setObject:@"Test" forKey:@"AccountName"];
    [fields setObject:@"Customer" forKey:@"AccountType"];
    [fields setObject:@"AAPA-1234" forKey:@"AccountId"];
    [fields setObject:@"Route Ride" forKey:@"CustomPickList0"];
    item = [[Item alloc] init:@"Activity" fields:fields];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testParameterHiding {
    NSString *result = [FormulaParser hideParams:@"function(param1, param2, param3)"];
    STAssertEqualObjects(result, @"function(      ,       ,       )", @"Parameter hiding failure");
}

- (void)testParsingConstants {
    for (NSString *s in [NSArray arrayWithObjects:@"Hello", @"'Hello'", @"'<Hello>'", nil]) {
        NSObject<Formula> *f1 = [FormulaParser parse:s];
        STAssertTrue([f1 isKindOfClass:[Constant class]], @"Formula should be a constant");
        Constant *c1 = (Constant *)f1;
        STAssertEqualObjects(c1.value, @"Hello", @"Constant should be set to 'Hello'");
        STAssertEqualObjects([f1 evaluateWithItem:self.item], @"Hello", @"Constant evaluation should be 'Hello'");
    }
}

- (void)testParsingFunctions {
    NSObject<Formula> *f1 = [FormulaParser parse:@"[<AccountId>]"];
    STAssertTrue([f1 isKindOfClass:[Function class]], @"Formula should be function");
    Function *u1 = (Function *)f1;
    STAssertEqualObjects(u1.name, @"FIELD", @"Function name should be 'FIELD'");
    STAssertEquals([u1.parameters count], 1U, @"Function should have 1 parameter");
    NSObject<Formula> *p1 = [u1.parameters objectAtIndex:0];
    STAssertTrue([p1 isKindOfClass:[Constant class]], @"First parameter should be a constant");
    Constant *c1 = (Constant *)p1;
    STAssertEqualObjects(c1.value, @"AccountId", @"First parameter value should be 'AccountId'");
    STAssertEqualObjects([f1 evaluateWithItem:self.item], @"AAPA-1234", @"Field evaluation should be 'AAPA-1234'");
}


- (void)testSplitting {
    NSArray *parts = [FormulaParser split:@"f(a(1), b, c)" with:@"(,)"];
    STAssertEquals([parts count], 4U, @"There should be 4 parts");
    STAssertEqualObjects([parts objectAtIndex:0], @"f", @"First string should be 'f'");
    STAssertEqualObjects([parts objectAtIndex:1], @"a(1)", @"Second string should be 'a(1)'");
}

- (void)testSum {
    NSObject<Formula> *f1 = [FormulaParser parse:@"[<AccountName>] + ' - ' + [<AccountType>]"];
    STAssertTrue([f1 isKindOfClass:[Function class]], @"Formula should be function");
    Function *u1 = (Function *)f1;
    STAssertEqualObjects(u1.name, @"CONCAT", @"Function name should be 'CONCAT'");
    STAssertEquals([u1.parameters count], 3U, @"Function should have 3 parameters");
    STAssertEqualObjects([f1 evaluateWithItem:self.item], @"Test - Customer", @"Sum evaluation is wrong");
}

- (void)testFunction {
    NSObject<Formula> *f1 = [FormulaParser parse:@"IIf([<AccountId>] IS NULL,'NULL','NOT NULL'"];
    STAssertTrue([f1 isKindOfClass:[Function class]], @"Formula should be function");
    Function *u1 = (Function *)f1;
    STAssertEqualObjects(u1.name, @"IIf", @"Function name should be 'IIf'");
    STAssertEquals([u1.parameters count], 3U, @"Function should have 3 parameters");
    STAssertEqualObjects([f1 evaluateWithItem:self.item], @"NOT NULL", @"Function evaluation is wrong");
}

- (void)testJoinFieldValue {
    NSObject<Formula> *f1 = [FormulaParser parse:@"JoinFieldValue('<Account>',[<AccountId>],'<AccountName>')"];
    STAssertTrue([f1 isKindOfClass:[Function class]], @"Formula should be function");
    Function *u1 = (Function *)f1;
    STAssertEqualObjects(u1.name, @"JoinFieldValue", @"Function name should be 'JoinFieldValue'");
    STAssertEquals([u1.parameters count], 3U, @"Function should have 3 parameters");
}

- (void)testComplex {
    NSObject<Formula> *f1 = [FormulaParser parse:@"IIf([<AccountId>] IS NULL,IIf([<LeadId>] IS NULL,[<plType_of_Activity_ITAG>],[<plType_of_Activity_ITAG>]+' - '+JoinFieldValue('<Lead>',[<LeadId>],'<Company>')+' - '+[<Lead>]),[<plType_of_Activity_ITAG>]+' - '+JoinFieldValue('<Account>',[<AccountId>],'<AccountName>')+' - '+JoinFieldValue('<Account>',[<AccountId>],'<PrimaryShipToCity>'))"];
    STAssertTrue([f1 isKindOfClass:[Function class]], @"Formula should be function");
    Function *u1 = (Function *)f1;
    STAssertEqualObjects(u1.name, @"IIf", @"Function name should be 'IIf'");
}

@end
