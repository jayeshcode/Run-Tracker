//
//  DetailViewController.m
//  logorun
//
//  Created by Krzysztof Kopytek on 2016-05-30.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//


#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"
#import "UIImage+ImageEffects.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *backParamView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewA;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewB;

@property (strong, nonatomic) UIImageView *backgroundImageView;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setRun:(Run *)run
{
    if (_run != run) {
        _run = run;
        [self configureView];
    }
}

- (void)configureView
{
    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];
    
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue]];
    
    [self loadMap];
}

- (MKCoordinateRegion)mapRegion
{
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
    
    return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MulticolorPolylineSegment class]]) {
        MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

- (MKPolyline *)polyLine {
    
    CLLocationCoordinate2D coords[self.run.locations.count];
    
    for (int i = 0; i < self.run.locations.count; i++) {
        Location *location = [self.run.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:self.run.locations.count];
}


- (void)loadMap
{
        // set the map bounds
        [self.mapView setRegion:[self mapRegion]];
        
        NSArray *colorSegmentArray = [MathController colorSegmentsForLocations:self.run.locations.array];
        [self.mapView addOverlays:colorSegmentArray];

}


- (IBAction)segmentedControlerChange:(UISegmentedControl *)sender {
    
    if(sender.selectedSegmentIndex == 1){
        self.imageViewA.hidden = NO;
        self.imageViewB.hidden = YES;
    }
    if(sender.selectedSegmentIndex == 0){
        self.imageViewA.hidden = YES;
        self.imageViewB.hidden = YES;
    }
    if(sender.selectedSegmentIndex == 2){
        self.imageViewA.hidden = YES;
        self.imageViewB.hidden = NO;
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.doneButton.layer.cornerRadius = 30;
    self.backParamView.layer.cornerRadius = 30;
    
}

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    return [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

@end

