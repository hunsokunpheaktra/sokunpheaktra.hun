//
//  MergeContacts.m
//  CRMiOS
//
//  Created by Mars on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MergeContacts.h"


@implementation MergeContacts


               
static MergeContacts *_sharedSingleton = nil;

@synthesize addressbook;

+ (MergeContacts *)getInstance
{
    @synchronized([MergeContacts class])
    {
        if (!_sharedSingleton) {
            [[self alloc] init];
        }
        return _sharedSingleton;
    }
}

+(id) alloc
{
    @synchronized([MergeContacts class])
    {
        NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedSingleton = [super alloc];
        return _sharedSingleton;
    }
    
    return nil;
}

-(void) dealloc
{
    if(addressbook != NULL){
        CFRelease(addressbook);
    }
    [super dealloc];
}

- (id)init {
    self = [super init];
    addressbook = ABAddressBookCreate();
    return self;
}


- (ABRecordRef)checkExistingContact:(Item *)newContact
{
    CFArrayRef persons = ABAddressBookCopyArrayOfAllPeople(addressbook);
    CFIndex len = ABAddressBookGetPersonCount(addressbook);
    int i;
    for(i=0; i<len; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(persons, i);
        if(person == nil){
            NSLog(@"Person is null %i ", i);
            //CFRelease(person);
            return person;
        }else{
            CFStringRef note = ABRecordCopyValue(person, kABPersonNoteProperty);
            if(note != nil){
                CFStringRef noteOfItem = (CFStringRef)[newContact.fields objectForKey:@"Id"];
                NSLog(@"Person is not null %i ", i);
                if(CFStringCompare(note, noteOfItem, 0) == kCFCompareEqualTo){
                    //CFRelease(person);
                    return person;
                }
            }
            CFRelease(person);
        }
    }
    return nil;
}

- (int)updateContact:(Item *)newContact person:(ABRecordRef) existPerson {
    ABAddressBookRemoveRecord(addressbook, existPerson, nil);
    ABAddressBookSave(addressbook, nil);
    CFRelease(existPerson);
    [self insertContact:newContact isUpdate:YES];
    return 1;
}

//Insert new contact

- (void)insertContact:(Item *)newContact isUpdate:(BOOL)update
{
    ABRecordRef newPerson = ABPersonCreate();
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, [newContact.fields objectForKey:@"ContactFirstName"], nil);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, [newContact.fields objectForKey:@"ContactLastName"], nil);
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, [newContact.fields objectForKey:@"WorkPhone"]==nil?@"": [newContact.fields objectForKey:@"WorkPhone"], kABPersonPhoneMainLabel, nil);     
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    
    
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiEmail, [newContact.fields objectForKey:@"ContactEmail"]==nil?@"":[newContact.fields objectForKey:@"ContactEmail"], kABWorkLabel, nil);
    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, nil);
   
    ABRecordSetValue(newPerson, kABPersonJobTitleProperty, [newContact.fields objectForKey:@"JobTitle"], nil);
    ABRecordSetValue(newPerson, kABPersonNoteProperty, [newContact.fields objectForKey:@"Id"], nil);
    
    ABAddressBookAddRecord(addressbook, newPerson, nil);
    ABAddressBookSave(addressbook, nil);
    CFRelease(multiEmail);
    CFRelease(multiPhone);
    CFRelease(newPerson);

}

- (void)importToContact{
    CFArrayRef persons = ABAddressBookCopyArrayOfAllPeople(addressbook);
    CFIndex len = ABAddressBookGetPersonCount(addressbook);
    int countIndex = 0;
    int i;
    for(i=0; i<len; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(persons, i);
        if (person != nil) {
            NSArray *criterias;
            Item *result;
            CFStringRef note = ABRecordCopyValue(person, kABPersonNoteProperty);
            CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            if (note != nil) {
                criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"Id" value:(NSString *)note]];
            } else {
                
                if (firstName != nil && lastName != nil) {
                    criterias = [NSArray arrayWithObjects:[ValuesCriteria criteriaWithColumn:@"ContactFirstName" value:(NSString *)firstName], [ValuesCriteria criteriaWithColumn:@"ContactLastName" value:(NSString *)lastName], nil];
                } else if (firstName != nil) {
                    criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"ContactFirstName" value:(NSString *)firstName]];
                } else if(lastName != nil) {
                    criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:@"ContactLastName" value:(NSString *)lastName]];
                }
            }
            if (criterias != nil){
                result = [EntityManager find:@"Contact" criterias:criterias];
                if(result == nil){
                    ABMutableMultiValueRef multiPhone = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    CFIndex indexPhone = ABMultiValueGetCount(multiPhone);
                    CFStringRef phone;
                    if(indexPhone == 1)
                        phone = ABMultiValueCopyValueAtIndex(multiPhone, 0);
                    else
                        phone = nil;

                    ABMutableMultiValueRef multiMail = ABRecordCopyValue(person, kABPersonEmailProperty);
                    
                    CFIndex indexEmail = ABMultiValueGetCount(multiMail);
                    CFStringRef mail;
                    if(indexEmail == 1)
                        mail = ABMultiValueCopyValueAtIndex(multiMail, 0);
                    else
                        mail = nil;
                    CFStringRef jobtitle = ABRecordCopyValue(person, kABPersonJobTitleProperty);
                    
                    NSMutableDictionary *fields = [[NSMutableDictionary alloc] initWithCapacity:1];
                    [fields setObject:firstName == nil ? @"" : (NSString *)firstName forKey:@"ContactFirstName"];
                    [fields setObject:lastName == nil ? @"" : (NSString *)lastName forKey:@"ContactLastName"];
                    [fields setObject:phone == nil ? @"" : (NSString *)phone forKey:@"WorkPhone"];
                    [fields setObject:mail == nil ? @"" : (NSString *)mail forKey:@"ContactEmail"];
                    [fields setObject:jobtitle == nil ? @"" : (NSString *)jobtitle forKey:@"JobTitle"];
                    if(note != nil)
                        [fields setObject:(NSString *)note forKey:@"Id"];
                    Item *newItem = [[Item alloc] init:@"Contact" fields:fields];
                    [EntityManager insert:newItem modifiedLocally:YES];
                    countIndex ++;
                    if(jobtitle != nil)
                        CFRelease(jobtitle);
                    
                    if(mail != nil)
                        CFRelease(mail);
                    if(phone != nil)
                        CFRelease(phone);
                    
                    CFRelease(multiPhone);
                    CFRelease(multiMail);
                    [fields release];
                }
            }
            if(firstName != nil)
                CFRelease(firstName);
            if(lastName != nil)
                CFRelease(lastName);
            if(note != nil)
                CFRelease(note);

        }
    }
    NSString *message = @"contacts imported from address book.";
    if(countIndex == 0){
        message = [NSString stringWithFormat:@"No %@", message];
    }else{
        message =[NSString stringWithFormat:@"%i %@",countIndex,message];
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    [alert show];
    [alert release];
}

@end
