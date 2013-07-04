//
//  MainViewController.h
//  Vibrator
//
//  Created by Lincoln Six Echo on 04.07.13.
//  Copyright (c) 2013 appdoctors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

// UIDevice detection
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>

@interface MainViewController : UIViewController {

    IBOutlet UIStepper *stepperPattern;
    IBOutlet UILabel *labelPattern;
    IBOutlet UIStepper *stepperIntensity;
    IBOutlet UILabel *labelIntensity;
    IBOutlet UISlider *sliderDurationVibrate;
    IBOutlet UISlider *sliderDurationPause;
    IBOutlet UILabel *labelDurationVibrate;
    IBOutlet UILabel *labelDurationPause;
    IBOutlet UILabel *labelDurationTotal;
    IBOutlet UIBarButtonItem *playItem;
    IBOutlet UIBarButtonItem *stopItem;
    IBOutlet UILabel *warningLabel;
    IBOutlet UISwitch *switchAutoloop;
    
    NSTimeInterval loopInterval;
    NSTimer *timerLoop;
}

@property( nonatomic, retain ) UIStepper *stepperPattern;
@property( nonatomic, retain ) UILabel *labelPattern;
@property( nonatomic, retain ) UIStepper *stepperIntensity;
@property( nonatomic, retain ) UILabel *labelIntensity;
@property( nonatomic, retain ) UISlider *sliderDurationVibrate;
@property( nonatomic, retain ) UISlider *sliderDurationPause;
@property( nonatomic, retain ) UILabel *labelDurationVibrate;
@property( nonatomic, retain ) UILabel *labelDurationPause;
@property( nonatomic, retain ) UILabel *labelDurationTotal;
@property( nonatomic, retain ) UIBarButtonItem *playItem;
@property( nonatomic, retain ) UIBarButtonItem *stopItem;
@property( nonatomic, retain ) UILabel *warningLabel;
@property( nonatomic, retain ) UISwitch *switchAutoloop;
@property( nonatomic, retain ) NSTimer *timerLoop;
@property( nonatomic, assign ) NSTimeInterval loopInterval;

- (IBAction) actionPlay:(id)sender;
- (IBAction) actionStop:(id)sender;
- (IBAction) actionStepperChanged:(UIStepper*)stepper;
- (IBAction) actionSliderChanged:(UISlider*)slider;

@end
