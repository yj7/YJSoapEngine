//
//  XmlHeaderHelper.m
//  FeeFactor
//
//  Created by Matri Ning on 15/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "XmlHeaderHelper.h"


@implementation XmlHeaderHelper

+ (NSString *)generateXmlHeader:(NSString *)tag and:(NSString *) nameSpace {
	NSString *xmlHeader = [NSString stringWithFormat:@"%@",@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	return xmlHeader;
}

@end
