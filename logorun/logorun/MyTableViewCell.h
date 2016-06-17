//
//  MyTableViewCell.h
//  logorun
//
//  Created by Jayesh Wadhwani on 2016-06-01.
//  Copyright © 2016 Krzysztof Kopytek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *distancelabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
