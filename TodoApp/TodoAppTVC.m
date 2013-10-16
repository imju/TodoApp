//
//  TodoAppTVC.m
//  TodoApp
//
//  Created by bgbb on 10/15/13.
//  Copyright (c) 2013 greensprout. All rights reserved.
//

#import "TodoAppTVC.h"
#import "CustomCell.h"

#define EDIT_MODE_CONST @"EDIT"
#define READ_MODE_CONST @"READ"


@interface TodoAppTVC ()
@property (nonatomic, strong) NSMutableArray *tasksList; // task list
@property (nonatomic, weak) NSString *actionMode;
@property (nonatomic, assign) NSUInteger editAtIndex;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation TodoAppTVC


- (void)viewDidLoad
{
    [super viewDidLoad];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"To Do Task";
    self.tasksList = [[NSMutableArray alloc] init];
    self.actionMode = READ_MODE_CONST;
    
  //  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    //register custom cell
    UINib *customNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"CustomCell"];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButton)];
    [self load];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tasksList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *msg = [self.tasksList objectAtIndex:indexPath.row];
    [cell.taskTextField setText:msg];
    cell.taskTextField.delegate = self;
    
    // show text field based on mode and enable editing if it was editable cell
    if ([self.actionMode  isEqualToString:EDIT_MODE_CONST]
        && indexPath.row == self.editAtIndex){
        cell.taskTextField.enabled = YES;
        [cell.taskTextField becomeFirstResponder];
        [cell.taskTextField setText:msg];
    }else{
        cell.taskTextField.enabled = YES;
    }
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{   //insert
    if (editingStyle == UITableViewCellEditingStyleInsert) {
       // NSString *CellIdentifier = @"CustomCell";

        NSArray *indexArray = [NSArray arrayWithObjects:indexPath,nil];
        [tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
        
        [self.tasksList insertObject:@"" atIndex:indexPath.row];
        [self save];
    }
    //delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tasksList removeObjectAtIndex:indexPath.row];
        [self save];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    //hide the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    self.actionMode = READ_MODE_CONST;
    CGRect location = [self.view convertRect:textField.frame toView:self.tableView];
    NSArray *indexPaths = [self.tableView indexPathsForRowsInRect:location];
    NSUInteger index = 0;
    if (indexPaths.count > 0){
       NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:location] objectAtIndex:0];
       index = indexPath.row;
    }

    //hide the keyboard
    if (textField.enabled == YES){
        [textField resignFirstResponder];
    }
    NSLog(@"Edit at:%d:%@",index,textField.text);
    [self.tasksList replaceObjectAtIndex:index withObject:textField.text];
    [self save];
    [self.tableView reloadData];
}
/**
 //conditionally allow edit
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGRect location = [self.view convertRect:textField.frame toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:location] objectAtIndex:0];
    NSLog(@"text field:%d",indexPath.row);
    if ([self.actionMode isEqualToString:EDIT_MODE_CONST]){
     if (indexPath.row == self.editAtIndex){
         NSLog(@"Yes");
        return YES;
     }
    }
    NSLog(@"No");
    return NO;
}**/

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing == YES)
    {
    } else {
        [self save];
        [self.tableView reloadData];
    }
}


#pragma mark - Private

- (void)onAddButton {
    
    self.actionMode = EDIT_MODE_CONST;
    [self.tasksList insertObject:@"" atIndex:0];
    self.editAtIndex = 0;
        
    // Animate the insertion of the new todo item
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

// Load to do items
- (void)load {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self toDoFilePath]]) {
         self.tasksList = [NSMutableArray arrayWithContentsOfFile:[self toDoFilePath]];
    }
}

// finding todo.plist
- (NSString *)toDoFilePath {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [rootPath stringByAppendingPathComponent:@"todo.plist"];
    //NSLog(@"filePath:%@",filePath);
    return filePath;
}
// save all to do items
- (void)save {
    [self.tasksList writeToFile:[self toDoFilePath] atomically:YES];
}


/**
- (void)setTasksList:(NSMutableArray *)tasksList
{
    self.tasksList = tasksList;
    [self.tableView reloadData];
}
**/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
