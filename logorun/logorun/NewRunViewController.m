//
//  NewRunViewController.m
//  logorun
//
//  Created by Krzysztof Kopytek on 2016-05-30.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import "NewRunViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Run.h"
#import "Location.h"
#import "MathController.h"
#import <AVFoundation/AVFoundation.h>


@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) Run *run;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;

@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property BOOL flag;
@property (strong, nonatomic) NSString *siriGo;
@property (weak, nonatomic) IBOutlet UIView *backParamView;


@end

@implementation NewRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self startLocationUpdates];

    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.startButton.layer.cornerRadius = 30;
    self.stopButton.layer.cornerRadius = 30;
    self.backParamView.layer.cornerRadius = 30;
    self.backParamView.hidden = YES;
    self.flag = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)eachSecond
{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    
    if(self.seconds%self.siriTime == 0) {
        self.siriGo = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist2:self.distance overTime:self.seconds]];
        [self startSpeaking:self.siriGo];
    }
}

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    //[self.locationManager startUpdatingLocation];
    if ([CLLocationManager authorizationStatus] ==
        kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [self.locationManager startUpdatingLocation];
        
        
    } else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@":(");
    }
}

-(IBAction)startPressed:(id)sender
{

    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self startSpeaking:@"Lets go!"];
    [UIView transitionWithView:self.view duration:2 options:UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
        self.startButton.hidden = YES;
        self.backParamView.hidden = NO;
        self.stopButton.hidden = NO;
    } completion:nil];

}



// stop button pressed
-(IBAction)stopPressed:(id)sender
    {
        
        UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
     
        // save action
        UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                                  
                                                                  
            if (self.locations.count > 0){
              [self saveRun];
              [self performSegueWithIdentifier:@"RunDetails" sender:nil];
            }
            else {
               
                
                UIAlertController* alertControler = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                        message:@"Sorry, this run has no locations saved."
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                    }];
                [alertControler addAction:alertAction];
                [self presentViewController:alertControler animated:YES completion:nil];
                
            }
                                                              
                                                              }];
        [actionSheet addAction:saveAction];
 
        
        // discard action
        UIAlertAction* discardAction = [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
               [self dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                           }];
        [actionSheet addAction:discardAction];
        
        
        // cancel action
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        [actionSheet addAction:cancelAction];
        
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
        
   
    }

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if(self.stopButton.hidden) {
        CLLocation *newLocation = locations.lastObject;
        MKCoordinateRegion region =
        MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
        [self.mapView setRegion:region animated:YES];
        return;
    }
    
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
                
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                
                
                // pace audio
                NSLog(@"%f",self.distance);
                
                if(((int)(self.distance)%self.siriDistance < 20) && self.flag == NO) {
                    
                    self.flag = YES;
                    self.siriGo = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist2:self.distance overTime:self.seconds]];
                    [self startSpeaking:self.siriGo];
                    
                    
                    NSLog(self.siriGo);
                    
                }
                else if (((int)(self.distance)%100 > 20) && self.flag == YES)
                    self.flag = NO;
                
            }
            
            [self.locations addObject:newLocation];
        }
    }
}


- (void)saveRun
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                 inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    [self.locationManager stopUpdatingLocation];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setRun:self.run];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

#pragma mark - Speech Management

- (void)startSpeaking: (NSString*) siriGo
{
    if (!self.synthesizer) {
        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    
    [self speakNextUtterance:siriGo];
}

- (void)speakNextUtterance: (NSString*) siriGo
{
    AVSpeechUtterance *nextUtterance = [[AVSpeechUtterance alloc]
                                        initWithString:siriGo];
    [self.synthesizer speakUtterance:nextUtterance];
}

@end
