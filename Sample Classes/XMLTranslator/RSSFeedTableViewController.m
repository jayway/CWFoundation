//
//  RSSFeedTableViewController.m
//  CWXMLTranslator
//
//  Created by Fredrik Olsson on 2011-02-17.
//  Copyright 2011 Jayway. All rights reserved.
//

#import "RSSFeedTableViewController.h"
#import "NSObject+CWInvocationProxy.h"

@implementation RSSFeedTableViewController

#pragma mark --- Fetch RSS items on background thread

-(void)reloadTableViewWithRSSItems:(NSArray*)items;
{
    rssItems = [items copy];
	if ([self isViewLoaded]) {
    	[self.tableView reloadData];
    }
}

-(void)showError:(NSError*)error;
{
	[[[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                 message:[error localizedFailureReason]
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] autorelease] show];
}

-(void)fetchRSSItems;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSURL* url = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
	NSError* error = nil;
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	[formatter setLocale:locale];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
	
	[CWXMLTranslator setDefaultDateFormatter:formatter];
	[formatter release];
    NSArray* items = [CWXMLTranslator translateContentsOfURL:url
                                        withTranslationNamed:@"RSSFeed"
                                                    delegate:self
                                                       error:&error];
    if (items) {
		[self performSelectorOnMainThread:@selector(reloadTableViewWithRSSItems:)
                               withObject:items
                            waitUntilDone:NO];
    } else {
    	[self performSelectorOnMainThread:@selector(showError:)
                               withObject:error
                            waitUntilDone:NO];
    }
    [pool release];
}

#pragma mark --- CWXMLTranslatorDelegate conformance

- (id)translator:(CWTranslator *)translator didTranslateObject:(id)anObject fromSourceName:(NSString *)name attributes:(NSDictionary *)attributes toKeyPath:(NSString *)key ontoObject:(id)parentObject context:(NSString *)context;
{
	if (key == CWTranslationRootMarker && [name isEqualToString:@"title"]) {
        // If it is the feeds title then set the navigation title but skip adding the object.
        [[self.navigationItem mainThreadProxy] setTitle:anObject];
    	return nil;
    }
    return anObject;
}


#pragma mark --- Instance life cycle

-(void)awakeFromNib;
{
	[super awakeFromNib];
    [self performSelectorInBackground:@selector(fetchRSSItems)
                           withObject:nil];
}

- (void)dealloc;
{
    [rssItems release];
    [super dealloc];
}


#pragma mark --- UITableViewDataSource conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return [rssItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.numberOfLines = 3;
    }
    
	NSDictionary* item = [rssItems objectAtIndex:indexPath.row];
	cell.textLabel.text = [item objectForKey:@"title"];
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
	NSString* dateString = [formatter stringFromDate:[item objectForKey:@"date"]];
	[formatter release];
    NSString* preamble = [item objectForKey:@"preamble"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"\t%@\n%@", dateString, preamble];
    
    return cell;
}

#pragma mark --- UITableViewDelegate conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
	NSDictionary* item = [rssItems objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[item objectForKey:@"URL"]];
}


@end

