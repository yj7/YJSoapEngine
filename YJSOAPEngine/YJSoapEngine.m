//
//  YJSoapEngine.m
//  YJSoapEngine
//
//  Created by Yash Jhunjhunwala on 31/05/15.
//  Copyright (c) 2015 lastminutecode. All rights reserved.
//

#import "YJSoapEngine.h"
#import "XmlParser.h"
#include "GDataXMLNode.h"
#import "objc/runtime.h"
#import "XMLDictionary.h"
NSMutableArray *values;
NSString *methodName;
GDataXMLElement *envelopeElement;
@implementation YJSoapEngine

- (YJSoapEngine *)init
{
    if (!values)
        values = [[NSMutableArray alloc]init];
    envelopeElement = [GDataXMLNode elementWithName:@"soap:Envelope"];
    [envelopeElement addNamespace:[GDataXMLNode namespaceWithName:@"soap" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [envelopeElement addNamespace:[GDataXMLNode namespaceWithName:@"xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
    [envelopeElement addNamespace:[GDataXMLNode namespaceWithName:@"xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
    [envelopeElement addAttribute:[GDataXMLNode elementWithName:@"soap:EncodingStyle" stringValue:@"http://www.w3.org/2001/12/soap-encoding"]];
    _actionSlashNamespace = NO;
    return self;
}
-(GDataXMLElement *)toXml:(id)object andTag:(NSString *)tag inNameSpace:(NSString *)nameSpace{
    
    const char *objectName = class_getName([object class]);
    NSString *objectNameStr = [[NSString alloc] initWithBytes:objectName length:strlen(objectName) encoding:NSASCIIStringEncoding];
    GDataXMLElement * objectElement;
    [objectElement addNamespace:[GDataXMLNode namespaceWithName:@"m" stringValue:nameSpace]];
    if (!tag)
        objectElement = [GDataXMLNode elementWithName:[@"m:" stringByAppendingString:objectNameStr]];
    else
        objectElement = [GDataXMLNode elementWithName:[@"m:" stringByAppendingString:tag]];
    
    [objectElement addNamespace:[GDataXMLNode namespaceWithName:@"m" stringValue:nameSpace]];
    NSMutableDictionary * propertyDic = [XmlParser propertDictionary:object];
    NSString *nodeValue = [NSString stringWithFormat:@"%@",@""];
    for (NSString *key in propertyDic)
    {
        if ([object valueForKey:key]!=nil)
        {
            if ([[propertyDic objectForKey:key] isEqualToString:@"l"])
                nodeValue = [NSString stringWithFormat:@"%llu",[[object valueForKey:key] unsignedLongLongValue]];
            else if ([[propertyDic objectForKey:key] isEqualToString:@"i"])
                nodeValue = [NSString stringWithFormat:@"%d",[object valueForKey:key]];
            else
                nodeValue = [NSString stringWithFormat:@"%@",[object valueForKey:key]];
            if (nodeValue.length != 0)
            {
                GDataXMLElement * childElement = [GDataXMLNode elementWithName:[@"m:" stringByAppendingString:key] stringValue:nodeValue];
                [objectElement addChild:childElement];
            }
        }
    }
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:objectElement];
    NSData *xmlData = document.XMLData;
    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *bodyString = [xmlString substringFromIndex:21];
    //NSString *headerString = [XmlHeaderHelper generateXmlHeader:tag and:nameSpace];
    xmlString = [NSString stringWithFormat:@"%@",bodyString];
    // NSLog(@"xml string is :: %@",xmlString);
    return objectElement;
}

- (void)setObject:(id)object andTag:(NSString *)tag andNamespace:(NSString *)nameSpace
{
    GDataXMLElement *temp = [self toXml:object andTag:tag inNameSpace:nameSpace];
    [values addObject:temp];
}
- (void)requestURL:(NSString *)reqURL withSoapAction:(NSString *)soapAction
{
    NSArray *pathArray = [soapAction componentsSeparatedByString:@"/"];
    GDataXMLElement *element;
    methodName = [pathArray lastObject];
    element = [GDataXMLNode elementWithName:methodName];
    if (_actionSlashNamespace)
    {
        NSString *tempNamespace = @"";
        for (int i = 0; i < pathArray.count - 1; i++)
        {
            NSString *temp = [pathArray objectAtIndex:i];
            tempNamespace = [tempNamespace stringByAppendingString:temp];
            tempNamespace = [tempNamespace stringByAppendingString:@"/"];
        }
        [element addNamespace:[GDataXMLNode namespaceWithName:nil stringValue:tempNamespace]];
    }
    for (GDataXMLElement *childs in values)
    {
        [element addChild:childs];
    }
    GDataXMLElement *soapBody = [GDataXMLNode elementWithName:@"soap:Body"];
    [soapBody addChild:element];
    [envelopeElement addChild:soapBody];
    NSString *headerString = [self generateXmlHeader];
    NSString *soapMessage = [headerString stringByAppendingString:envelopeElement.XMLString];
    NSURL *url = [NSURL URLWithString:reqURL];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self startImmediately:YES];
    [conn start];
    
}
- (NSString *)generateXmlHeader {
    NSString *xmlHeader = [NSString stringWithFormat:@"%@",@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    return xmlHeader;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    tempStr = [self getResult:tempStr];
    NSDictionary *tempDict = [[NSDictionary alloc]init];
    tempDict = [NSDictionary dictionaryWithXMLString:tempStr];
    NSDictionary *checkFault = [tempDict valueForKey:@"faultcode"];
    if ([checkFault count] < 1)
    {
        if (_delegate != nil)
            [_delegate YJSoapEngine:self didRecieveData:tempStr inDictionary:tempDict];
    }
    else
    {
        if (_delegate != nil)
            [_delegate YJSoapEngine:self didRecieveError:tempStr inDictionary:tempDict];
    }
   
}
- (NSString *)getResult:(NSString *)xmlString{
    
    NSString *xmlStr = xmlString;
    
    NSError *error;
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
    
    if (doc == nil) {
        NSLog(@"doc doesn't exist");
        return nil;
    }
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLNode *nameSpace = [rootElement.namespaces objectAtIndex:0];
    NSArray *temp = [doc nodesForXPath:[NSString stringWithFormat:@"//%@:Fault",nameSpace.name] error:nil];
    if (temp == nil)
    {
        temp = [doc nodesForXPath:[NSString stringWithFormat:@"//%@:Body",nameSpace.name] error:nil];
    }
    GDataXMLElement *anElement = temp[0];
    return anElement.XMLString;
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}
- (void)setInteger:(int)value andTag:(NSString *)tag
{
    GDataXMLElement *objectElement;
    objectElement  = [GDataXMLNode elementWithName:tag stringValue:[NSString stringWithFormat:@"%d",value]];
    [values addObject:objectElement];
}
- (void)setFloat:(float)value andTag:(NSString *)tag
{
    GDataXMLElement *objectElement;
    objectElement  = [GDataXMLNode elementWithName:tag stringValue:[NSString stringWithFormat:@"%f",value]];
    [values addObject:objectElement];
}
- (void)setString:(NSString *)value andTag:(NSString *)tag
{
    GDataXMLElement *objectElement;
    objectElement  = [GDataXMLNode elementWithName:tag stringValue:value];
    [values addObject:objectElement];
}
@end
