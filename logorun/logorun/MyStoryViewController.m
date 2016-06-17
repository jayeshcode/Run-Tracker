//
//  MyStoryViewController.m
//  logorun
//
//  Created by Krzysztof Kopytek on 2016-05-30.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import "MyStoryViewController.h"
#import "AppDelegate.h"
#import "MyTableViewCell.h"
#import "Run.h"
#import "MathController.h"
#import "SplashViewController.h"
#import "BEMSimpleLineGraphView.h"
#import "DetailViewController.h"
#import "UIImage+ImageEffects.h"


@interface MyStoryViewController ()<NSFetchedResultsControllerDelegate, UITableViewDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedController;
@property (weak, nonatomic) IBOutlet UITableView *mytable;
- (IBAction)actiononBack:(id)sender;

- (IBAction)actiononDelete:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deletebutton;
- (IBAction)actiononGraph:(id)sender;
@property (strong, nonatomic) Run *run;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *totalRuns;
@property NSIndexPath *indexpath;


@end

@implementation MyStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *image = [UIImage imageNamed:@"background"];
    image=[self blurWithImageEffects:image];
    self.imageView.image = image;
    
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appDel.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Run"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    
    
       self.fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    self.fetchedController.delegate = self;
    [self.fetchedController performFetch:nil];
    
    NSNumber *totalDistance = [self.fetchedController.fetchedObjects valueForKeyPath:@"@sum.distance"];
    NSLog(@"total distance = %f", totalDistance.doubleValue);

  
   NSString *total =[NSString stringWithFormat:@"Total %.2f km", [MathController floatDistance:[totalDistance floatValue]]];
   
 [_totalRuns setTitle:total forState:UIControlStateNormal];




}
- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    return [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedController fetchedObjects] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    [self configureCell:cell atIndexPath:indexPath];
    self.indexpath= [tableView indexPathForCell:cell];
       return cell;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.mytable;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)configureCell:(MyTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    self.run = [self.fetchedController objectAtIndexPath:indexPath];
    
    cell.distancelabel.text = [MathController stringifyDistance:self.run.distance.floatValue];//distance
    cell.layer.cornerRadius=30;
    cell.distancelabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.distancelabel.numberOfLines = 0;
    [cell.distancelabel sizeToFit];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];//date
    cell.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    
    cell.dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.dateLabel.numberOfLines = 0;
    [cell.dateLabel sizeToFit];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];//time
    
     cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
     cell.timeLabel.numberOfLines = 0;
    [ cell.timeLabel sizeToFit];
    
    cell.paceLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue]];//pace
    
    cell.paceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.paceLabel.numberOfLines = 0;
    [cell.paceLabel sizeToFit];
    
}






- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Run *run;
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            run = [self.fetchedController objectAtIndexPath:indexPath];
            [moc deleteObject:run];
            [moc save:nil];
            break;
            
        default:
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    
    return @"History";

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actiononBack:(id)sender {           

    [self dismissViewControllerAnimated:YES completion:nil];
   

  
   }

- (IBAction)actiononDelete:(id)sender {

 
    if ([sender isSelected]) {
         [sender setTitle:@"Delete" forState:UIControlStateNormal];
        [self.mytable setEditing:NO animated:YES];

        [sender setSelected:NO];
    } else {
         [sender setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.mytable setEditing:YES animated:YES];

        [sender setSelected:YES];
    }

   
}




- (IBAction)actiononGraph:(id)sender {
    
    if ([[self.fetchedController fetchedObjects] count]<2) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"No Graphs If Less than Two Runs"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 //[view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
                             
                             
                             [alert addAction:ok];
    
    }else
    {
        [self performSegueWithIdentifier:@"graph" sender:self];}

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexpath=indexPath;
    [self performSegueWithIdentifier:@"detail" sender:tableView];


}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detail"]) {
        
        {
        DetailViewController *controller = (DetailViewController*)[segue destinationViewController];
            
           
            controller.run=[self.fetchedController objectAtIndexPath:self.indexpath];
        }
        
    }
}


@end
