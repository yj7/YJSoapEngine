//
//  YJSoapEngine.h
//  YJSoapEngine
//
//  Created by Yash Jhunjhunwala on 31/05/15.
//  Copyright (c) 2015 lastminutecode. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol YJSoapEngineDelegate;


@interface YJSoapEngine : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
- (void)setObject:(id)object andTag:(NSString *)tag andNamespace:(NSString *)nameSpace;
- (void)setInteger:(int)value andTag:(NSString *)tag;
- (void)setString:(NSString *)value andTag:(NSString *)tag;
- (void)setFloat:(float)value andTag:(NSString *)tag;
- (void)requestURL:(NSString *)reqURL withSoapAction:(NSString *)soapAction;
@property BOOL actionSlashNamespace;
@property id <YJSoapEngineDelegate> delegate;
@end


@protocol YJSoapEngineDelegate
@required
- (void)YJSoapEngine:(YJSoapEngine *)soapEngine didRecieveData:(NSString *)data inDictionary:(NSDictionary *)dataDictionary;
- (void)YJSoapEngine:(YJSoapEngine *)YJSoapEngine didRecieveError:error inDictionary:(NSDictionary *)errorDictionary;

@end