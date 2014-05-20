//
//  OWAViewController.m
//  OWA
//
//  Created by BJ Miller on 5/18/14.
//  Copyright (c) 2014 Six Five Software, LLC. All rights reserved.
//

#import "OWAViewController.h"
@import CoreMotion;

@interface OWAViewController ()
@property (weak, nonatomic) IBOutlet UILabel *motionAvailableStatus;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic) NSUInteger steps;
@end

@implementation OWAViewController

- (CMStepCounter *)stepCounter
{
    if ([CMStepCounter isStepCountingAvailable]) {
        self.motionAvailableStatus.text = @"Step counting is available!";
        _stepCounter = [CMStepCounter new];
    } else {
        self.motionAvailableStatus.text = @"No step data available.";
    }
    return _stepCounter;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.motionAvailableStatus.text = @"";
    self.stepsLabel.text = @"";

    [self getHistoricalMotionData];

    [self.stepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        [self getHistoricalMotionData];
    }];
}

- (NSDate *)midnight
{
    NSDate *midnight = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    midnight = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:midnight]];
    return midnight;
}

- (void)getHistoricalMotionData
{
    NSDate *endDate = [NSDate date];
    
    NSDate *midnight = [self midnight];
    
    [self.stepCounter queryStepCountStartingFrom:midnight to:endDate toQueue:[NSOperationQueue mainQueue] withHandler:^(NSInteger numberOfSteps, NSError *error) {
        self.steps = numberOfSteps;
        self.stepsLabel.text = [NSString stringWithFormat:@"%lu steps", self.steps];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.stepCounter stopStepCountingUpdates];
}
@end
