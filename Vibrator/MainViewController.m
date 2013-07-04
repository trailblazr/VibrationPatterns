//
//  MainViewController.m
//  Vibrator
//
//  Created by Lincoln Six Echo on 04.07.13.
//  Copyright (c) 2013 appdoctors. All rights reserved.
//

#import "MainViewController.h"

// PRIVATE API CONSTS
#define kVIBRATION_SYSTEM_SOUND_ID      4095
#define kVIBRATION_PATTERN_KEY          @"VibePattern"
#define kVIBRATION_INTENSITY_KEY        @"Intensity"

// DEFAULT VALUES FOR UI
#define DEFAULT_PATTERN             3
#define DEFAULT_INTENSITY           0.5f
#define DEFAULT_DURATION_VIBRATE    250.0f
#define DEFAULT_DURATION_PAUSE      100.0f

@implementation MainViewController

// NEED TO DEFINE THESE BECAUSE THEY ARE PRIVATE API AND OTHERWISE UNKNOWN TO COMPILER
FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, struct objc_object*, NSDictionary*);
FOUNDATION_EXTERN void AudioServicesStopSystemSound(unsigned long);

@synthesize stepperPattern;
@synthesize labelPattern;
@synthesize stepperIntensity;
@synthesize labelIntensity;
@synthesize sliderDurationVibrate;
@synthesize sliderDurationPause;
@synthesize labelDurationVibrate;
@synthesize labelDurationPause;
@synthesize labelDurationTotal;
@synthesize playItem;
@synthesize stopItem;
@synthesize warningLabel;
@synthesize loopInterval;
@synthesize switchAutoloop;
@synthesize timerLoop;

#pragma mark - device detection

- (NSString*) devicePlatform;
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (BOOL) isDevicePod;
{
    NSString *platformName = [[self devicePlatform] lowercaseString];
    return ( [platformName rangeOfString:@"ipod"].location != NSNotFound );
}

- (BOOL) isDevicePad;
{
    NSString *platformName = [[self devicePlatform] lowercaseString];
    return ( [platformName rangeOfString:@"ipad"].location != NSNotFound );
}

- (BOOL) isDevicePhone;
{
    NSString *platformName = [[self devicePlatform] lowercaseString];
    return ( [platformName rangeOfString:@"iphone"].location != NSNotFound );
}


- (void) issueWarnings;
{
    BOOL shouldHideWarning = YES;
    
    if( TARGET_IPHONE_SIMULATOR ) {
        shouldHideWarning = NO;
        warningLabel.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    }
    else if( [self isDevicePhone] ) {
        warningLabel.text = @"YAY, iPHONE DOES VIBRATE.";
        warningLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
        shouldHideWarning = NO;
    }
    else if( [self isDevicePod] ) {
        warningLabel.text = @"SORRY, iPOD DOES NOT VIBRATE.";
        shouldHideWarning = NO;
        warningLabel.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    }
    else if( [self isDevicePad] ) {
        warningLabel.text = @"SORRY, iPAD DOES NOT VIBRATE.";
        shouldHideWarning = NO;
        warningLabel.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    }
    warningLabel.hidden = shouldHideWarning;
}

#pragma mark - view handling

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad;
{
    [super viewDidLoad];
    // INIT UI
    [stepperPattern setValue:[[NSNumber numberWithInt:DEFAULT_PATTERN] doubleValue]];
    [self actionStepperChanged:stepperPattern];
    [stepperIntensity setValue:[[NSNumber numberWithFloat:DEFAULT_INTENSITY] doubleValue]];
    [self actionStepperChanged:stepperIntensity];
    [sliderDurationVibrate setValue:DEFAULT_DURATION_VIBRATE];
    [self actionSliderChanged:sliderDurationVibrate];
    [sliderDurationPause setValue:DEFAULT_DURATION_PAUSE];
    [self actionSliderChanged:sliderDurationPause];
    labelDurationTotal.text = @"-";
    stopItem.enabled = NO;
    warningLabel.layer.cornerRadius = 7.0;
    warningLabel.layer.masksToBounds = YES;
    [self issueWarnings];
}

- (void) didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user actions

- (NSInteger) intValueForStepper:(UIStepper*)stepper;
{
    NSNumber *num = [NSNumber numberWithDouble:stepper.value];
    return [num integerValue];
}

- (IBAction) actionSliderChanged:(UISlider*)slider;
{
    if( slider == sliderDurationVibrate ) {
        labelDurationVibrate.text = [NSString stringWithFormat:@"Vibrate duration: %.0f ms", slider.value];
    }
    else if (slider == sliderDurationPause ) {
        labelDurationPause.text = [NSString stringWithFormat:@"Pause duration: %.0f ms", slider.value];
    }
}

- (IBAction) actionStepperChanged:(UIStepper*)stepper;
{
    if( stepper == stepperPattern ) {
        labelPattern.text = [NSString stringWithFormat:@"%i", [self intValueForStepper:stepper]];
    }
    else if (stepper == stepperIntensity ) {
        labelIntensity.text = [NSString stringWithFormat:@"%.1f", stepper.value];
    }
}

- (void) uiEnable:(BOOL)shouldEnable;
{
    if( !USE_RESTRICTIVE_UI ) return;
    NSArray *uiControls = [NSArray arrayWithObjects:stepperPattern,stepperIntensity,sliderDurationVibrate,sliderDurationPause,playItem, nil];
    for( UIControl *currentControl in uiControls ) {
        currentControl.enabled = shouldEnable;
    }
}

- (IBAction) actionPlay:(id)sender;
{
    if( sender == playItem ) {
        if( DEBUG ) NSLog( @"PLAY" );
    }
    else {
        if( DEBUG ) NSLog( @"AUTOPLAY" );
    }
    [self uiEnable:NO];
    playItem.enabled = NO;
    stopItem.enabled = !playItem.enabled;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *vibrationPattern = [NSMutableArray array ];
    NSTimeInterval accumulatedTime = 0.0;
    
    for( int i = 0; i < [self intValueForStepper:stepperPattern]; i++ ) {
        // VIBRATE
        [vibrationPattern addObject:[NSNumber numberWithBool:YES]];
        [vibrationPattern addObject:[NSNumber numberWithFloat:sliderDurationVibrate.value]];
        accumulatedTime += sliderDurationVibrate.value;
        // PAUSE
        [vibrationPattern addObject:[NSNumber numberWithBool:NO]];
        [vibrationPattern addObject:[NSNumber numberWithInt:sliderDurationPause.value]];
        accumulatedTime += sliderDurationPause.value;
    }
    
    self.loopInterval = (accumulatedTime+sliderDurationPause.value)/1000.0f; // ADD PAUSE ms and bring to SECONDS
    labelDurationTotal.text = [NSString stringWithFormat:@"%.2f s", loopInterval];
    
    [dict setObject:vibrationPattern forKey:kVIBRATION_PATTERN_KEY];
    [dict setObject:[NSNumber numberWithDouble:stepperIntensity.value] forKey:kVIBRATION_INTENSITY_KEY];
    @try {
        AudioServicesPlaySystemSoundWithVibration( kVIBRATION_SYSTEM_SOUND_ID, nil, dict );
    }
    @catch (NSException *exception) {
        warningLabel.text = @"PRIVATE API TO PLAY IS BROKEN.";
        warningLabel.backgroundColor = [UIColor orangeColor];
    }
    
    if( switchAutoloop.isOn ) {
        self.timerLoop = [NSTimer scheduledTimerWithTimeInterval:loopInterval target:self selector:@selector(actionPlay:) userInfo:nil repeats:NO];
    }
    else {
        self.timerLoop = [NSTimer scheduledTimerWithTimeInterval:loopInterval target:self selector:@selector(actionStop:) userInfo:nil repeats:NO];
    }
}

- (IBAction) actionStop:(id)sender;
{
    if( DEBUG ) NSLog( @"STOP" );
    if( timerLoop && [timerLoop isValid] ) {
        [timerLoop invalidate];
        self.timerLoop = nil;
    }
    [self uiEnable:YES];
    playItem.enabled = YES;
    stopItem.enabled = !playItem.enabled;
    @try {
        AudioServicesStopSystemSound( kVIBRATION_SYSTEM_SOUND_ID );
    }
    @catch (NSException *exception) {
        warningLabel.text = @"PRIVATE API TO STOP IS BROKEN.";
        warningLabel.backgroundColor = [UIColor orangeColor];
    }
}

@end
