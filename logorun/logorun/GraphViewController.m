//
//  GraphViewController.m
//  logorun
//
//  Created by Jayesh Wadhwani on 2016-06-01.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import "GraphViewController.h"
#import "Run.h"
#import "MathController.h"

@interface GraphViewController ()
- (IBAction)actioonBack:(id)sender;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@property (nonatomic,strong)NSMutableArray *data;
@property NSManagedObjectContext *moc;

@property    AppDelegate *appDel;

- (IBAction)actiononSegment:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *total;


@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.myGraph.formatStringForValues = @"%.2f";
    self.myGraph.colorXaxisLabel=[UIColor whiteColor];
    self.myGraph.labelFont = [UIFont systemFontOfSize:15];
    self.myGraph.colorYaxisLabel=[UIColor whiteColor];
    
    
    _data=[[NSMutableArray alloc]init];
    self.appDel = [UIApplication sharedApplication].delegate;
    
    _moc = self.appDel.managedObjectContext;
    
    
    self.myGraph.enableBezierCurve = YES;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
    
    NSError *error = nil;
    NSArray *results = [self.moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }else {
        for (Run *r in results) {
            NSLog(@"%@", r.distance);
            
            NSNumber *temp = [NSNumber numberWithFloat:[MathController floatDistance:r.distance.floatValue]];
            
            [self.data addObject:temp];
            
        }
        
        NSLog(@" loged %@",self.data);
        
        
    }
    NSNumber *sum = [self.data valueForKeyPath:@"@sum.self"];
    
    _total.text=[NSString stringWithFormat:@"Total %.2f KM",sum.floatValue];
    
    _total.lineBreakMode = NSLineBreakByWordWrapping;
    _total.numberOfLines = 0;
    [_total sizeToFit];
    
    
    
    
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.data.count; // Number of po@pints in the graph.
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [(NSNumber*)self.data[index] floatValue]; // The value of the point on the Y-Axis for the index.
}

- (nullable NSString *)lineGraph:(nonnull BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index{
    
    
    return [NSString stringWithFormat:@"Run %ld",(long)index+1];
}


- (IBAction)actioonBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)actiononSegment:(id)sender;
{
    
    if ([sender selectedSegmentIndex]==0)
    {
        self.myGraph.enableBezierCurve = YES;
        
        
    }
    if ([sender selectedSegmentIndex]==1)
    {
        self.myGraph.enableBezierCurve =NO;
    }
    
    
    [self.myGraph reloadGraph];
}


//-(NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
//{
//    return 5;
//}

//- (NSInteger)baseIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph;
//{
//    return 10;
//}
//
//- (NSInteger)incrementIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph;
//{
//    return 1;
//}
- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph;
{
    return 10;
}
-(NSString *)yAxisSuffixOnLineGraph:(BEMSimpleLineGraphView *)graph;
{
    return @" KM";
}
//- (CGFloat)baseValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph;
//{
//    return 10;
//}
//- (CGFloat)incrementValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph;
//{
//    return 5;
//}
//
//- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index
//{
//    NSLog(@"test");
//}
//- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index
//{
//    NSLog(@"test");
//}
@end
