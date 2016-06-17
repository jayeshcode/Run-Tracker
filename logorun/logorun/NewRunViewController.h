//
//  NewRunViewController.h
//  logorun
//
//  Created by Krzysztof Kopytek on 2016-05-30.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewRunViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property int siriDistance;
@property int siriTime;

@end
