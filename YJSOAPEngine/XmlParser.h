//
//  XmlParser.h
//  FeeFactor
//
//  Created by Luke Du on 19/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlParser : NSObject {

}
+(NSMutableDictionary *)propertDictionary:(NSObject *) objt;

+(NSString *)getResult:(NSString *)xmlString;


-(NSMutableArray *)fromXml:(NSString *)xmlString withObject:(id)obj;

-(NSString *)toXml:(id)object andTag:(NSString *)tag inNameSpace:(NSString *)nameSpace;





@end
