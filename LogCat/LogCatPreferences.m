//
//  LogCatPreferences.m
//  LogCat
//
//  Created by Janusz Bossy on 21.11.2011.
//  Copyright (c) 2011 SplashSoftware.pl. All rights reserved.
//

#import "LogCatPreferences.h"
#import "LogCatAppDelegate.h"

@implementation LogCatPreferences

- (void)setupToolbar
{
    [self addView:adbView label:@"ADB" image:[NSImage imageNamed:NSImageNameQuickLookTemplate]];
    [self addView:appearanceView label:@"Appearance" image:[NSImage imageNamed:NSImageNameQuickLookTemplate]];
    [self addView:aboutView label:@"About" image:[NSImage imageNamed:NSImageNameInfo]];
    
    adbLocations = [NSMutableArray arrayWithObjects:  @"Built-in", @"Custom ...", nil];
   
    
    consumeFirstCombo = true;
    
    [adbList removeAllItems];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* adbCustomLocation =[defaults stringForKey:@"adbLocationCustom"];
    NSInteger adbLocationMode = [defaults integerForKey:@"adbLocationMode"];
    NSLog(@"adbLocationMode %d", adbLocationMode);
    
    if (adbLocationMode > 0) {
        [self buildItemsWithCustom:adbCustomLocation];
     }
    
    [adbList addItemsWithObjectValues:adbLocations];
    
    if (adbLocationMode > 0) {
        [adbList selectItemAtIndex:1];
    } else {
         [adbList selectItemAtIndex:0];
    }


}
- (void) buildItemsWithCustom:(NSString *)custom {
     adbLocations = [NSMutableArray arrayWithObjects:  @"Built-in", custom, @"Custom ...", nil];
}

- (IBAction)fontChanged:(id)sender
{
    LogCatAppDelegate* appDelegate = [NSApp delegate];
    [appDelegate fontsChanged];
}

- (IBAction)adbLocationChanged:(id)sender
{
    
    
}


- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if (consumeFirstCombo) {
        consumeFirstCombo = false;
        return;
    }
    NSLog(@"[%@ %@] value == %@", NSStringFromClass([self class]),
          NSStringFromSelector(_cmd), [adbLocations objectAtIndex:
                                       [(NSComboBox *)[notification object] indexOfSelectedItem]]);
    
    NSInteger changedRow = [(NSComboBox *)[notification object] indexOfSelectedItem];
    
    NSLog(@"here %d", changedRow);
    
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:changedRow forKey:@"adbLocationMode"];
    
    if (changedRow == [adbLocations count] - 1) {
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        
        // Enable the selection of files in the dialog.
        [openDlg setCanChooseFiles:YES];
        
        // Enable the selection of directories in the dialog.
        [openDlg setCanChooseDirectories:NO];
        
        [openDlg beginWithCompletionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                
                for (NSURL *fileURL in [openDlg URLs]) {
                    NSLog(fileURL.description );
                    
                    NSString *customLocation = [fileURL.description stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    [defaults setObject:customLocation forKey:@"adbLocationCustom"];
                    
                    consumeFirstCombo = true;
                    // add this to the dropdown and set it as selected
                    [self buildItemsWithCustom:customLocation];
                    
                    [adbList removeAllItems];
                    [adbList addItemsWithObjectValues:adbLocations];
                    
                    
                    break;
                }
            }
        }];
    }
    
    LogCatAppDelegate* appDelegate = [NSApp delegate];
    [appDelegate adbSettingsChanged];

    
}



@end
