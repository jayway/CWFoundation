//
//  RSSFeedTableViewController.h
//  CWXMLTranslator
//
//  Created by Fredrik Olsson on 2011-02-17.
//  Copyright 2011 Jayway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWXMLTranslator.h"


@interface RSSFeedTableViewController : UITableViewController <CWTranslatorDelegate> {
@private
    NSArray* rssItems;
}

@end
