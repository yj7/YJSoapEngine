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
#import "OrderedDictionary.h"
NSMutableArray *values;
NSString *methodName;
GDataXMLElement *envelopeElement;
NSString *actionNamespace;
NSMutableData *responseData;
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
        //[objectElement addNamespace:[GDataXMLNode namespaceWithName:@"m" stringValue:nameSpace]];
    if (!tag)
        objectElement = [GDataXMLNode elementWithName:[@"" stringByAppendingString:objectNameStr]];
    else
        objectElement = [GDataXMLNode elementWithName:[@"" stringByAppendingString:tag]];
    
        //[objectElement addNamespace:[GDataXMLNode namespaceWithName:@"m" stringValue:nameSpace]];
    OrderedDictionary * propertyDic = [XmlParser propertDictionary:object];
    NSString *nodeValue = [NSString stringWithFormat:@"%@",@""];
    int order = 1;
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
                GDataXMLElement * childElement = [GDataXMLNode elementWithName:[[NSString stringWithFormat:@"m%d:",order] stringByAppendingString:key] stringValue:nodeValue];
                [childElement addNamespace:[GDataXMLNode namespaceWithName:[NSString stringWithFormat:@"m%d",order] stringValue:nameSpace]];
                [objectElement addChild:childElement];
                order++;
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

- (void)setActionNamespace:(NSString *)namespace
{
    actionNamespace = namespace;
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
    else
    {
        [element addNamespace:[GDataXMLNode namespaceWithName:nil stringValue:actionNamespace]];
    }
    for (GDataXMLElement *childs in values)
    {
        [element addChild:childs];
    }
    GDataXMLElement *soapBody = [GDataXMLNode elementWithName:@"soap:Body"];
    [soapBody addChild:element];
    [envelopeElement addChild:soapBody];
    NSString *headerString = [self generateXmlHeader];
    responseData = [[NSMutableData alloc] init];
    NSString *soapMessage = [headerString stringByAppendingString:envelopeElement.XMLString];
    NSURL *url = [NSURL URLWithString:reqURL];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: soapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
        // soapMessage = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" soap:EncodingStyle=\"http://www.w3.org/2001/12/soap-encoding\"><soap:Body><GetMMHICCustInfoUseMobiNumb xmlns=\"http://Datacomp.Web.Serv.WCFServicesAPP/\"><inputInfo><m1:Mobile1 xmlns:m1=\"http://Datacomp.Web.Serv.Info/\">8454094407</m1:Mobile1><m2:Mobile2 xmlns:m2=\"http://Datacomp.Web.Serv.Info/\">0</m2:Mobile2><m3:Mobile3 xmlns:m3=\"http://Datacomp.Web.Serv.Info/\">0</m3:Mobile3><m4:ProdID xmlns:m4=\"http://Datacomp.Web.Serv.Info/\">141</m4:ProdID><m5:DeviID1 xmlns:m5=\"http://Datacomp.Web.Serv.Info/\">2cfd55d89c4a49df</m5:DeviID1><m6:MMHICUSERID xmlns:m6=\"http://Datacomp.Web.Serv.Info/\">3OK92Dl/LwA0HqfC5+fCxw==</m6:MMHICUSERID><m7:MMHICPASSWORD xmlns:m7=\"http://Datacomp.Web.Serv.Info/\">BjLfd1dqTCyH1DQLhylKRQ==</m7:MMHICPASSWORD></inputInfo></GetMMHICCustInfoUseMobiNumb></soap:Body></soap:Envelope>";
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self startImmediately:YES];
    [conn start];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
        //Getting your response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    responseString = [self getResult:responseString];
    NSDictionary *tempDict = [[NSDictionary alloc]init];
    tempDict = [NSDictionary dictionaryWithXMLString:responseString];
    NSDictionary *checkFault = [tempDict valueForKey:@"faultcode"];
    if ([checkFault count] < 1)
    {
        if (_delegate != nil)
            [_delegate YJSoapEngine:self didRecieveData:responseString inDictionary:tempDict];
    }
    else
    {
        if (_delegate != nil)
            [_delegate YJSoapEngine:self didRecieveError:responseString inDictionary:tempDict];
    }

    responseData = nil;
}
- (NSString *)generateXmlHeader {
    NSString *xmlHeader = [NSString stringWithFormat:@"%@",@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    return xmlHeader;
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
    if ([temp count] == 0)
    {
        temp = [doc nodesForXPath:[NSString stringWithFormat:@"//%@:Body",nameSpace.name] error:nil];
    }
    if ([temp count] > 0)
    {
        GDataXMLElement *anElement = temp[0];
        return anElement.XMLString;
    }
    else return @"";
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