//
//  ViewController.h
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "DataModelController.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) TableViewController* tvc;
@property (strong, nonatomic) DataModelController* dataModelController;

@end
