//
//  YJSoapEngine.h
//  YJSoapEngine
//
//  Created by Yash Jhunjhunwala on 31/05/15.
//  Copyright (c) 2015 lastminutecode. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol YJSoapEngineDelegate;
typedef NS_ENUM(NSInteger, SoapErrorType) {
    RecievedFault = 0
};
typedef NS_ENUM(NSInteger, SoapAuthType) {
    SoapAuthNone = 0,
    SoapAuthBasic
};
@interface YJSoapEngine : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSString *ReqURL, *RegsoapAction;
}
- (void)setObject:(id)object andTag:(NSString *)tag andNamespace:(NSString *)nameSpace;
- (void)setInteger:(int)value andTag:(NSString *)tag;
- (void)setString:(NSString *)value andTag:(NSString *)tag;
- (void)setFloat:(float)value andTag:(NSString *)tag;
- (void)requestURL:(NSString *)reqURL withSoapAction:(NSString *)soapAction;
- (void)setActionNamespace:(NSString *)namespace;
@property BOOL actionSlashNamespace;
@property id <YJSoapEngineDelegate> delegate;
@property SoapAuthType authenticationMethod;
@property int tag;
@property NSString *username, *password;
extern const NSString *YJSoapEngineErrorDomain;
@end


@protocol YJSoapEngineDelegate
@required
- (void)YJSoapEngine:(YJSoapEngine *)soapEngine didRecieveData:(NSString *)data inDictionary:(NSDictionary *)dataDictionary;
- (void)YJSoapEngine:(YJSoapEngine *)YJSoapEngine didRecieveError:(NSError *)error inDictionary:(NSDictionary *)errorDictionary;

@end