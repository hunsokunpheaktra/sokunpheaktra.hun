//
//  MergeContacts.h
//  CRMiOS
//
//  Created by Mars on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Item.h"
#import "EntityManager.h"

@interface MergeContacts : NSObject {
    ABAddressBookRef addressbook;
}

@property(nonatomic, readwrite) ABAddressBookRef addressbook;

+ (MergeContacts *)getInstance;

- (ABRecordRef)checkExistingContact:(Item *)newContact;
- (int)updateContact:(Item *)newContact person:(ABRecordRef) existPerson;
- (void)insertContact:(Item *)newContact isUpdate:(BOOL)update;
- (void)importToContact;

@end
