//
//  NotesViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NotesViewController.h"
#import "DBFile.h"
#import "NoteDetailsViewController.h"
#import "Dropbox.h"

@interface NotesViewController ()<NoteDetailsViewControllerDelegate>

@property (nonatomic, strong) NSArray *notes;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NotesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // 1
        /*
         *  return a session with no persistent storage for caches, cookies, or credentials.
         */
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // 2
        /*
         *
         */
        [config setHTTPAdditionalHeaders:@{@"Authorization":[Dropbox apiAuthorizationHeader]}];
        
        // 3
        /*
         *  create the NSURLSession using the above configuration
         */
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self notesOnDropbox];
}

// list files found in the root dir of appFolder
- (void)notesOnDropbox
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // 1
    NSURL *url = [Dropbox appRootURL];
    
    // 2
    /*
     *  create a data task in order to perform a GET request to that URL.
     */
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     if (!error) {
                                                         NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
                                                         if (httpResp.statusCode == 200) {
                                                             NSError *jsonError;
                                                             
                                                             // 2
                                                             NSDictionary *notesJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                       options:NSJSONReadingAllowFragments
                                                                                                                         error:&jsonError];
                                                             NSMutableArray *notesFound = [[NSMutableArray alloc] init];
                                                             if (!jsonError) {
                                                                 // 1
//                                                                 NSArray *contentsOfRootDirectory = notesJSON[]
                                                             }
                                                         }
                                                     }
                                                 }];
    
    // 3
    [dataTask resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DBFile *note = _notes[indexPath.row];
    cell.textLabel.text = [[note fileNameShowExtension:YES]lowercaseString];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    NoteDetailsViewController *showNote = (NoteDetailsViewController*) [navigationController viewControllers][0];
    showNote.delegate = self;
    

    if ([segue.identifier isEqualToString:@"editNote"]) {
        
        // pass selected note to be edited //
        if ([segue.identifier isEqualToString:@"editNote"]) {
            DBFile *note =  _notes[[self.tableView indexPathForSelectedRow].row];
            showNote.note = note;
        }
    }
}

#pragma mark - NoteDetailsViewController Delegate methods

-(void)noteDetailsViewControllerDoneWithDetails:(NoteDetailsViewController *)controller
{
    // refresh to get latest
    [self dismissViewControllerAnimated:YES completion:nil];
    [self notesOnDropbox];
}

-(void)noteDetailsViewControllerDidCancel:(NoteDetailsViewController *)controller
{
    // just close modal vc
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
