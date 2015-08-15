//
//  ViewController.m
//  SoapExample
//
//  Created by Yash Jhunjhunwala on 04/06/15.
//  Copyright (c) 2015 lastminutecode. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController
- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)sendRequest:(id)sender
{
    YJSoapEngine *soapEngine = [[YJSoapEngine alloc]init];
    soapEngine.delegate = self;
    soapEngine.actionSlashNamespace = YES;
    [soapEngine setFloat:[textCelcius.text doubleValue] andTag:@"Celsius"];
    [soapEngine requestURL:@"http://www.w3schools.com/webservices/tempconvert.asmx" withSoapAction:@"http://www.w3schools.com/webservices/CelsiusToFahrenheit"];
    
}
- (IBAction)sendWeatherRequest:(id)sender
{
    YJSoapEngine *soapEngine = [[YJSoapEngine alloc]init];
    soapEngine.tag = 1;
    soapEngine.delegate = self;
    soapEngine.actionSlashNamespace = NO;
    [soapEngine setActionNamespace:@"http://www.webserviceX.NET"];
    [soapEngine setString:@"Jodhpur" andTag:@"CityName"];
    [soapEngine setString:@"India" andTag:@"CountryName"];
    [soapEngine requestURL:@"http://www.webservicex.net/globalweather.asmx" withSoapAction:@"http://www.webserviceX.NET/GetWeather"];
    
}

- (void)YJSoapEngine:(YJSoapEngine *)soapEngine didRecieveData:(NSString *)data inDictionary:(NSDictionary *)dataDictionary
{
    NSLog(@"Soap Response:\n %@",data);
    if (soapEngine.tag == 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Weather Response" message:data delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *farenheit = [dataDictionary valueForKeyPath:@"CelsiusToFahrenheitResponse.CelsiusToFahrenheitResult"];
        lblFarenheit.text = farenheit;
    }

}
- (void)YJSoapEngine:(YJSoapEngine *)YJSoapEngine didRecieveError:(NSError *)error inDictionary:(NSDictionary *)errorDictionary
{
    NSLog(@"%@ : %ld",error.domain,(long)error.code);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
