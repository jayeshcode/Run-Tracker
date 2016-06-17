//
//  ViewController.m
//  logorun
//
//  Created by Krzysztof Kopytek on 2016-05-25.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import "SplashViewController.h"
#import "UIImage+ImageEffects.h"

@interface SplashViewController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *nowyRunButton;
@property (weak, nonatomic) IBOutlet UIButton *myStoryButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *labelsplash;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

//options
@property (weak, nonatomic) IBOutlet UILabel *currentPaceLabel;
@property (weak, nonatomic) IBOutlet UIButton *done2Button;
@property (weak, nonatomic) IBOutlet UISlider *sliderTime;
@property (weak, nonatomic) IBOutlet UISlider *sliderDistance;
@property (weak, nonatomic) IBOutlet UISwitch *switchTime;
@property (weak, nonatomic) IBOutlet UISwitch *switchDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;



@property int siriDistance;
@property int siriTime;


@end

@implementation SplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    /// === Jayesh ==================
    
    NSURL *URL = [NSURL URLWithString:@"http://quotes.rest/qod.json"];
    NSURLRequest *apiRequest = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *apiTask =
    [sharedSession
     dataTaskWithRequest:apiRequest
     completionHandler:^(NSData *_Nullable data,
                         NSURLResponse *_Nullable response,
                         NSError *_Nullable error) {
         
         //NSLog(@"completed response");
         
         if (!error) {
             NSError *jsonError;
             NSDictionary *parsedData =
             [NSJSONSerialization JSONObjectWithData:data
                                             options:0
                                               error:&jsonError];
             
             if (!jsonError) {
                 //NSLog(@"%@", parsedData);
                 
                 NSMutableArray *Array = [NSMutableArray
                                          array];
                 Array=parsedData[@"contents"][@"quotes"];
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     
                     
                     self.labelsplash.text=[NSString stringWithFormat:@"\" %@ \"",Array[0][@"quote"]];
                     self.labelsplash.lineBreakMode = NSLineBreakByWordWrapping;
                     self.labelsplash.numberOfLines = 0;
                     [self.labelsplash sizeToFit];
                     
                     
                 });
                 
             } else {
                 NSLog(@"Error parsing JSON: %@",
                       [jsonError localizedDescription]);
             }
             
         } else {
             NSLog(@"%@", [error localizedDescription]);
         }
         
     }];
    
    // NSLog(@"Before resume");
    [apiTask resume];
    //NSLog(@"After resume");
    
    // ====================================
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.nowyRunButton.layer.cornerRadius = 30;
    self.myStoryButton.layer.cornerRadius = 30;
    self.siriDistance = 100;
    self.siriTime = 60;
    self.optionsView.hidden = YES;
    self.optionsView.layer.cornerRadius = 30;
    self.currentPaceLabel.layer.cornerRadius = 30;
    self.done2Button.layer.cornerRadius = 30;
    
}

 #pragma mark - Options

- (IBAction)optionsPressed:(UIButton *)sender {
    
    UIImage *backgroundImage = [self takeSnapshotOfView:self.view];
    backgroundImage = [self blurWithImageEffects:backgroundImage];
    self.backgroundImageView = [[UIImageView  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.backgroundImageView.image = backgroundImage;
    [self.view addSubview:self.backgroundImageView];
    self.optionsView.layer.zPosition = 1;
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
        self.optionsView.hidden = NO;
    } completion:nil];
    
}
- (IBAction)doneOptions:(UIButton *)sender {
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
        self.optionsView.hidden = YES;
        [self.backgroundImageView removeFromSuperview];
    } completion:nil];
    
}

- (IBAction)sliderTime:(UISlider *)sender {
    
    self.siriTime = (int)self.sliderTime.value;
    self.labelTime.text = [NSString stringWithFormat:@"every %i seconds",self.siriTime];
    
}
- (IBAction)switchTime:(UISwitch *)sender {
    
    if([self.switchTime isOn]){
        
        self.sliderTime.userInteractionEnabled = YES;
        self.sliderTime.alpha = 1;
        self.labelTime.alpha = 1;
        
    }
    else{
        
        self.sliderTime.userInteractionEnabled = NO;
        self.sliderTime.alpha = 0.3f;
        self.labelTime.alpha = 0.3f;
    }
    
    
}


- (IBAction)sliderDistance:(UISwitch *)sender {
    
    self.siriDistance = ((int)(self.sliderDistance.value/10))*10;
    self.labelDistance.text = [NSString stringWithFormat:@"every %i meters",self.siriDistance];
    
}
- (IBAction)switchDistance:(UISwitch *)sender {
    
    if([self.switchDistance isOn]){
        
        self.sliderDistance.userInteractionEnabled = YES;
        self.sliderDistance.alpha = 1;
        self.labelDistance.alpha = 1;
        
    }
    else{
        
        self.sliderDistance.userInteractionEnabled = NO;
        self.sliderDistance.alpha = 0.3;
        self.labelDistance.alpha = 0.3f;
    }
}





- (UIView *)createOptionsView
{
    // creating container view background with blurr effect
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *backgroundImage = [self takeSnapshotOfView:self.view];
    backgroundImage = [self blurWithImageEffects:backgroundImage];
    UIImageView *backgroundImageView = [[UIImageView  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = backgroundImage;
    [containerView addSubview:backgroundImageView];
    
    // creating second container to set up options inside
    UIView *containerView2 = [[UIView alloc]
                              initWithFrame:CGRectMake(50, 50, self.view.frame.size.width - 100,
                                                       self.view.frame.size.height - 100)];
    containerView2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    containerView2.layer.cornerRadius = 30;

    
    // slider siriTime
    UISlider *siriTimeSlider = [[UISlider alloc]
                                initWithFrame:CGRectMake(20,
                                                         100,
                                                         containerView2.frame.size.width - 40,
                                                         50)];
    
    siriTimeSlider.userInteractionEnabled = NO;
    [containerView2 addSubview:siriTimeSlider];
    
    // done button
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(60,
                                                     200,
                                                     containerView2.frame.size.width - 120,
                                                     50)];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.layer.cornerRadius = 30;
    self.doneButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5f];
    [self.doneButton addTarget:self
               action:@selector(donePressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setExclusiveTouch:YES];
    [containerView2 addSubview:self.doneButton];
    
    [containerView addSubview:containerView2];
    
    return containerView;
}

-(void)donePressed:(UIButton*)sender{
    

    
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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"showNewRun"]){
        UIViewController *nextController = [segue destinationViewController];
        if ([nextController isKindOfClass:[NewRunViewController class]]) {
            ((NewRunViewController *) nextController).managedObjectContext = self.managedObjectContext;
            ((NewRunViewController *) nextController).siriTime = self.siriTime;
            ((NewRunViewController *) nextController).siriDistance = self.siriDistance;
        }
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

@end
