//
//  ViewController.h
//  SoapExample
//
//  Created by Yash Jhunjhunwala on 04/06/15.
//  Copyright (c) 2015 lastminutecode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJSoapEngine.h"
@interface ViewController : UIViewController<YJSoapEngineDelegate>
{
    IBOutlet UITextField *textCelcius;
    IBOutlet UILabel *lblFarenheit;
    
}

@end

