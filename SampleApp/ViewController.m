//
//  ViewController.m
//  SampleApp
//
//  Created by Evgeniy Sinev on 26/09/16.
//  Copyright © 2016 payneteasy. All rights reserved.
//

#import "ViewController.h"
#import "RemoteLogging.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonSendMessage:(id)sender {
    DLog(@"Test message %@", [[NSDate alloc] init]);
}

- (IBAction)buttonMarkLog:(id)sender {
    [RemoteLogging incrementSession];
}


@end
